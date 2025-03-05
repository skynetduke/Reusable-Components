/* Title      : Apex Schedulable jobs redesign
*  Description: This Program runs for every 15mins through batch mode and send jobs from Custom Queue to Std. Platfrom Queue.
*/
public with sharing class EOPS_SendJobsToStdQueue {
    
    public list<Schedule_APEX_Jobs_Queue__c> QJobsList;
    public list<Schedule_APEX_Jobs_Queue__c> QUpdateList = new list<Schedule_APEX_Jobs_Queue__c>();
    public List<Id> JobId = new List<Id>();
    
    integer WaitingCount = 0;
    //string WaitingCount1; //hema
    integer availableJobsLmt = 0;
    // 1. Check the count of 'Waiting' jobs in Std Schedule Queue
    // 2. Send jobs to Std Queue as per count
    // 3. Update the job status in Custom Obj which are sent to StdQueue 
	
    	// string qry = label.QueryReference1;
    //system.debug('Std.labeltest : '+ qry);
    
    public integer fetchStdQueue(){
        WaitingCount = [SELECT count() FROM CronTrigger WHERE CronJobDetail.JobType = '7' AND State = 'Waiting'];
		//WaitingCount1 = waitingCntQry.WaitingCount__c;
        //system.debug('Std.Queue size : '+ WaitingCount1);
        system.debug('Std.Queue size : '+ WaitingCount);
        return WaitingCount;
    }
    
    public void fetchQueueJobs(){
        
        //Object: Schedule_APEX_Jobs_Queue__c
        //Fetch the valid jobs from JobsQueue Which needs to be run today
        waitingCount = fetchStdQueue();
        //Get CustomLabel Governor Limit
        String str = Label.ScheduleApexGovLimit;
        Integer govLimit = integer.valueOf(str);
        if(WaitingCount >= govLimit){
            system.debug('Standard platform Queue is full, Total number of jobs in Queue currently :' +WaitingCount);
        }
        else{
            availableJobsLmt = govLimit - WaitingCount ;
            system.debug('Maximum jobs allowed to send Std.Platform Queue :'+availableJobsLmt );
        }
        System.debug('WaitingCount:'+ WaitingCount);
        if (WaitingCount >= 0 && WaitingCount < govLimit){
            //fetch jobs from Cust.Obj queue which are in 'Not Started' status
            //Modified query below to include ownerID & createdby name -ZP
           System.debug('Current Date :'+ System.today());
            QJobsList = [SELECT id,
                         CreatedBy.Name,
                         Name,
                         Job_Name__c,
                         Job_Name__r.Job_Name__c,
                         Job_Name__r.CreatedBy.Name,
                         Job_Name__r.OwnerId,
                         Apex_Class__c,
                         Scheduled_Date__c,
                         QueueTime__c,
                         Status__c,
                         Minute_Interval__c,
                         Start_Date__c,
                         End_Date__c,
                         Job_Frequency__c
                         FROM Schedule_APEX_Jobs_Queue__c
                         WHERE QueueTime__c <=: system.now().addMinutes(15)
                         AND   Status__c = 'Not Started'
                         ORDER BY QueueTime__c ,SeqNumber__c ASC
                         limit :availableJobsLmt ]; 
            
            
            System.debug('Total no of jobs fetched:' +QJobsList.size());
            if(QJobsList.size() > 0){
                    DateTime JobTime;
                    Integer hour; 
                    Integer min;
                for(Schedule_APEX_Jobs_Queue__c wa : QJobsList){
                    system.debug('Record det::'+wa);
                    system.debug('System time::'+system.now());
                    //if job time has already past, make the status of the job as "Duplicate" and ignore for 15/30/45/60 min.intervals
                  try{
                     if(wa.QueueTime__c < system.now().addMinutes(-15) && wa.Minute_Interval__c != null){
                         wa.Status__c = 'Duplicate';
                         wa.Error_Message_Framework__c = 'Job did not send to standard queue as there are multiple jobs exist for same class and This job Scheduled time is in the past'; 
                         QUpdateList.add(wa); 
                         Continue;
                      }//if any other job frequency, add 10mins from current time and send to std.queue
                      else if(wa.QueueTime__c < system.now()){
                          wa.ActualFireTime__c = system.now().addMinutes(2);
                          hour = wa.ActualFireTime__c.hour();
                          min  = wa.ActualFireTime__c.minute(); 
                      }else{
                          hour = wa.QueueTime__c.hour();
                          min  = wa.QueueTime__c.minute();
                          wa.ActualFireTime__c = wa.QueueTime__c;
                      }
                      System.debug('Class to Schedule :'+wa.Apex_Class__c);
                      //Create instance of Sch.apex class 
                      Type t = Type.forName(wa.Apex_Class__c); //create Type instance
                      System.debug('Class to Schedule 2:'+wa.Apex_Class__c);

                      Schedulable classInstance = null; //Create schedulable interface instance
                       
                      try {
                          classInstance = (Schedulable) t.newInstance();
                          
                      } 
                      catch(Exception e){
                          throw new InitializationException('The class scheduling is not Valid schedulable class.!');
                      }
                       System.debug('Class to Schedule 2:'+wa.Apex_Class__c);
                      integer day  = wa.Scheduled_Date__c.day();
                      integer mth  = wa.Scheduled_Date__c.month();
                      integer year = wa.Scheduled_Date__c.year();
                      string cron;
                      //Cron Expression for all frequency except min interval
                      cron = '0' + ' ' + string.valueOf(min) + ' ' + string.valueOf(hour) + ' '+ day + ' ' + mth + ' ' + '?' + ' ' + year;                       
                      system.debug('Cron Expression:: '+cron);                  
                      String dt = string.valueOf(wa.QueueTime__c);
                      String jobName = wa.Job_Name__r.job_name__c + ' '+ dt;
                      
                          String ScheduledJobID =  System.schedule( jobName , cron , classInstance); //schedulable interface instance
                          //Update Status in Custom Obj- Queue
                          wa.Job_ID__c = ScheduledJobID;
                          wa.status__c = 'In Process';
                          if(wa.ActualFireTime__c == null)
                          wa.ActualFireTime__c = system.now();
                    }catch(exception e){
                        String errMsg = '' ;   
                        errMsg = e.getMessage();
                        wa.Status__c = 'Error'; 
                        wa.Error_Message_Job__c = errMsg;
                        //Send email to notify the job failure to the Job Owner
                        sendEmailToJobOwner(wa);
                    }
                    QUpdateList.add(wa); 
                }
                
                //2. Update Schedule Object with NextFireDate & PreviousFireDate
                Database.SaveResult[] srUpdate = Database.update(QUpdateList, false);  
            }
        }  
        //Update job status which are in 'In process' status
        UpdatejobStatus();
    }
    
    public void updatejobStatus(){
        //get the today jobs which are in 'In Process' status
        //retrieve the status from CronTrigger 
        //Update job status in Cust.Obj Queue...
        Set<string> setClassNames = new Set<string>();
        MAP<Id,Schedule_APEX_Jobs_Queue__c> mapOfJobs = new MAP<Id,Schedule_APEX_Jobs_Queue__c>(); //Modified query below to include ownerID & createdby name -ZP
        for(Schedule_APEX_Jobs_Queue__c str : [SELECT id, CreatedBy.Name, Name, Job_Name__c, Job_Name__r.Job_Name__c,
         Job_Name__r.CreatedBy.Name, Job_Name__r.OwnerId, Apex_Class__c, Scheduled_Date__c,
                                                QueueTime__c, Status__c, Minute_Interval__c, Start_Date__c, End_Date__c, Job_Frequency__c, Job_id__c   
                                               FROM Schedule_APEX_Jobs_Queue__c
                                               WHERE Scheduled_Date__c =: System.today()
                                               AND  (Status__c = 'In Process' OR Status__c = 'EXECUTING' OR 
                                                     Status__c = 'Queued'     OR Status__c = 'ACQUIRED'  OR
                                                     Status__c = 'PAUSED'     OR Status__c = 'BLOCKED') ])
        {
            mapOfJobs.put(str.job_id__c, str);
            setClassNames.add(str.Apex_Class__c);
        }
        
        SET<ID> JobId = mapOfJobs.keyset();
        List<CronTrigger> JobStatus = new List<CronTrigger>();
        MAP<string,id> mapApex = new MAP<string,id>();
        //Get the class id for all sch.apex classes
        for(ApexClass ac : [SELECT id, Name from ApexClass Where Name IN :setClassNames and isValid = true and status = 'Active']){
            mapApex.put(ac.name,ac.id);
        }
        //Get the job status of completed jobs
        JObStatus = [SELECT Id,CreatedDate,CronJobDetailId,PreviousFireTime,NextFireTime,State,TimeZoneSidKey 
        FROM CronTrigger WHERE id IN : jobId AND  State != 'WAITING'];
        system.debug('CronTrigger details::'+JobStatus);
        QUpdateList.clear();
        Schedule_APEX_Jobs_Queue__c schedule = new Schedule_APEX_Jobs_Queue__c();
        string classId;
        
        for(CronTrigger cron : JobStatus ){
            if(mapOfJobs.containsKey(cron.id) ){
                schedule = mapOfJobs.get(cron.id);
                if(mapApex.containsKey(schedule.Apex_Class__c)){
                    classId = mapApex.get(schedule.Apex_Class__c);
                }
                for(AsyncApexJob asyncJobStatus: [select id,ExtendedStatus from AsyncApexJob 
                where ApexClassId =: classId and CreatedDate =:cron.CreatedDate 
                and jobType = 'ScheduledApex' and status = 'Failed' limit 1]){
                    schedule.Status__c = 'Failed';
                    schedule.Job_Finish_Time__c = cron.PreviousFireTime;
                    schedule.Error_Message_Job__c = asyncJobStatus.ExtendedStatus;
                }
                
                if(cron.State == 'DELETED' && schedule.Status__c != 'Failed'){
                    schedule.Status__c = 'Completed';
                    schedule.Job_Finish_Time__c = cron.PreviousFireTime;
                }else if(schedule.Status__c == 'Failed'){
                    schedule.Status__c = 'Failed';
                    schedule.Job_Finish_Time__c = cron.PreviousFireTime;
                    //Send email to notify the job failure to the Job Owner
                    sendEmailToJobOwner(schedule);
                }
                QUpdateList.add(schedule);
            }
        }
        
        //3. Update Schedule Object with NextFireDate & PreviousFireDate
        Database.SaveResult[] srUpdate = Database.update(QUpdateList, false);
        
        //4. Delete completed apex scheduled jobs for which state is DELETED
     /*   for( CronTrigger c:[Select State,Id,EndTime,CronExpression From CronTrigger  
                            where NextFireTime=null  AND State='DELETED' Limit 100]){
                                System.abortJob(c.id);
                            } */
    }
    
    public void sendEmailToJobOwner(Schedule_APEX_Jobs_Queue__c jobQueueRec){
		  List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
          Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
          //list of people who should get the email
          
        
          //Set email is sent from
          mail.setReplyTo('no-reply-apexjobs@salesforce.com');
          mail.setSenderDisplayName('no-reply');
		  //mail.setToAddresses(sendTo);
		
        //mail.setTargetObjectId(jobQueueRec.Job_Name__r.Owner_Id__c);
          mail.setTargetObjectId(jobQueueRec.Job_Name__r.OwnerId); //Changed to the standard field... other field is useless -ZP
          mail.setSaveAsActivity(false);
        
          //Set email contents
          String sub = 'Alert!: Scheduled Job ' + jobQueueRec.Name + ': Sch.Class: '+jobQueueRec.Apex_Class__c  + ' failed';
          mail.setSubject(sub);
        //String body = 'Dear ' + jobQueueRec.CreatedBy.Name +  ', <br/> ';
          String body = 'Dear ' + jobQueueRec.Job_Name__r.CreatedBy.Name +  ', <br/> '; //Modified to pull from underlying job since the queue record will be created in the name of whoever schedules the job -- ZP
          body += '<br/> ';
         
          body += 'An apex job you scheduled has failed, please assess the details below.' + '<br/> ';
          body += '<br/> ';
          body += '<b>Job Name :</b>' +jobQueueRec.Name + '<br/> ';
          body += '<b>Scheduled Class Name :</b>' +jobQueueRec.Apex_Class__c + '<br/> ';
          body += '<b>Job Frequency :</b>' +jobQueueRec.Job_Frequency__c + '<br/> ';
          body += '<b>Scheduled Time :</b>' +jobQueueRec.QueueTime__c + '<br/>';
          body += '<b>Error Message :</b>' +jobQueueRec.Error_Message_Job__c  + '<br/> ';    
          body += '<br/> ';
          String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+jobQueueRec.id;
          body += '<b>Queue Rec Link :</b>' +Recordlink + '<br/> ';
          body += '<br/> '; 
          body += '<br/> '; 
          body += '<b>Best Regards,</b>' + '<br/> ';  
          body += '<b>EOPS Core Services</b>'; 
          mail.setHtmlBody(body);
        
          //Add your email to the master list
          mails.add(mail); 
          //Send all emails in the master list
          if(mails.size()>0)
           Messaging.sendEmail(mails);
    }
    /**
         * Thrown custom Exception if there are any exceptions 
         */
        private class InitializationException extends Exception {
        }
}