/* Title      : Apex Schedulable jobs redesign
*  Vertical   : EOPS Core Services
*  Developer  : Hemasundar Rada
*  Date       : 15/01/2019
*  Description: Test class for EOPS_SendJobsToStdQueue
*/
@isTest(SeeAllData=false)
public class EOPS_SendJobsToStdQueue_Test{
  @testSetup
  	static void setupTestData(){
    test.startTest();
        Scheduled_Job__c scheduled_job_Obj = new Scheduled_Job__c( Apex_Class__c = 'EOPS_JobsDailySchedulable', End_Date__c = Date.ValueOf(system.today()+10), Job_Frequency__c = 'Daily', Pref_Start_Time__c = '06:00', Start_Date__c = Date.ValueOf(system.today()-2), Job_Name__c = 'Test Job Run- Today 15mins', Sunday__c = false, Monday__c = false, Tuesday__c = false, Wednesday__c = false, Thursday__c = false, Friday__c = false, Saturday__c = false, RunToday__c = true);
        Insert scheduled_job_Obj; 
    Schedule_APEX_Jobs_Queue__c schedule_apex_jobs_queue_Obj = new Schedule_APEX_Jobs_Queue__c(Job_Name__c = scheduled_job_Obj.Id ,Apex_Class__c = 'EOPS_JobsDailySchedulable');
    Insert schedule_apex_jobs_queue_Obj; 
    // writing this for increate size of WaitingCount
    String CRON_EXP = '0 0 0 3 9 ? *';
    EOPS_JobsDailySchedulable eopsJobSchedule = new EOPS_JobsDailySchedulable();
    system.schedule('EOPS_JobsDailySchedulable_Test', CRON_EXP, eopsJobSchedule);
    test.stopTest();
  }
  	static testMethod void test_fetchQueueJobs_Method1(){
    List<Schedule_APEX_Jobs_Queue__c> schedule_apex_jobs_queue_Obj  =  [SELECT Apex_Class__c,QueueTime__c,ActualFireTime__c from Schedule_APEX_Jobs_Queue__c];
    EOPS_SendJobsToStdQueue eopsQjob = new EOPS_SendJobsToStdQueue();
    schedule_apex_jobs_queue_Obj[0] = Eops_ApexSchedular_TestUtility.createScheduledJobQueue(schedule_apex_jobs_queue_Obj[0],15);
    schedule_apex_jobs_queue_Obj[0].Scheduled_Date__c = system.today();
    schedule_apex_jobs_queue_Obj[0].Status__c = 'Not Started';
    schedule_apex_jobs_queue_Obj[0].QueueTime__c = system.now()+10; 
    update schedule_apex_jobs_queue_Obj[0];
    system.assertNotEquals(schedule_apex_jobs_queue_Obj[0].ActualFireTime__c,schedule_apex_jobs_queue_Obj[0].QueueTime__c,'Queuetime not equals to actual fire time');
    eopsQjob.fetchQueueJobs();
    system.assertEquals(eopsQjob.QJobsList[0].ActualFireTime__c,schedule_apex_jobs_queue_Obj[0].QueueTime__c,'Queuetime equals to actual fire time');
  }
    static testMethod void test_fetchQueueJobs_Method2(){
    List<Schedule_APEX_Jobs_Queue__c> schedule_apex_jobs_queue_Obj  =  [SELECT Apex_Class__c,QueueTime__c,Minute_Interval__c,ActualFireTime__c from Schedule_APEX_Jobs_Queue__c ];  
    EOPS_SendJobsToStdQueue eopsQjob = new EOPS_SendJobsToStdQueue();
    schedule_apex_jobs_queue_Obj[0] = Eops_ApexSchedular_TestUtility.createScheduledJobQueue(schedule_apex_jobs_queue_Obj[0],-30);
    schedule_apex_jobs_queue_Obj[0].Scheduled_Date__c = system.today();
    schedule_apex_jobs_queue_Obj[0].QueueTime__c = system.now()-30;
    schedule_apex_jobs_queue_Obj[0].Minute_Interval__c = null;
    schedule_apex_jobs_queue_Obj[0].Status__c = 'Not Started';
    update schedule_apex_jobs_queue_Obj[0];
    system.assertNotEquals(true,schedule_apex_jobs_queue_Obj[0].Status__c == 'In Process','Status is not In Process');
    eopsQjob.fetchQueueJobs();
	system.assertEquals(true,eopsQjob.QJobsList[0].Status__c == 'In Process','Status Updated to In Process');
  }
	static testMethod void test_fetchQueueJobs_Method3(){
    List<Schedule_APEX_Jobs_Queue__c> schedule_apex_jobs_queue_Obj  =  [SELECT Apex_Class__c,QueueTime__c,Minute_Interval__c,ActualFireTime__c,Status__c from Schedule_APEX_Jobs_Queue__c];
    EOPS_SendJobsToStdQueue eopsQjob = new EOPS_SendJobsToStdQueue();
    schedule_apex_jobs_queue_Obj[0] = Eops_ApexSchedular_TestUtility.createScheduledJobQueue(schedule_apex_jobs_queue_Obj[0],15);
   /* schedule_apex_jobs_queue_Obj[0].Scheduled_Date__c = system.today();
    schedule_apex_jobs_queue_Obj[0].Status__c = 'Not Started';
    schedule_apex_jobs_queue_Obj[0].QueueTime__c = system.today()-1;
    schedule_apex_jobs_queue_Obj[0].Minute_Interval__c = 15;*/
    update schedule_apex_jobs_queue_Obj[0];
    system.assertNotEquals(true,schedule_apex_jobs_queue_Obj[0].Status__c == 'Duplicate','Status is not duplicate');
    eopsQjob.fetchQueueJobs();
    system.assertEquals(true,eopsQjob.QJobsList[0].Status__c == 'Duplicate','Status Updated to duplicate');
  }
    
    
  static testMethod void test_updatejobStatus_Method1(){
    test.startTest();
    List<Schedule_APEX_Jobs_Queue__c> schedule_apex_jobs_queue_Obj  =  [SELECT Apex_Class__c from Schedule_APEX_Jobs_Queue__c];
    System.assertEquals(true,schedule_apex_jobs_queue_Obj.size()>0);
    EOPS_SendJobsToStdQueue obj01 = new EOPS_SendJobsToStdQueue();
    String ID = [SELECT Id  FROM CronTrigger WHERE CronJobDetail.JobType = '7' and State != 'WAITING'].id ; 
   // System.abortJob(ID) ;
    String ID1 =   [SELECT Id  FROM CronTrigger WHERE Id =:ID ].ID ;
    schedule_apex_jobs_queue_Obj[0].job_id__c = ID ;
    schedule_apex_jobs_queue_Obj[0].Status__c = 'Queued';
    schedule_apex_jobs_queue_Obj[0].Scheduled_Date__c = system.today() ;
    update schedule_apex_jobs_queue_Obj[0];
      
    obj01.QJobsList = new list<Schedule_APEX_Jobs_Queue__c>([SELECT Apex_Class__c,Minute_Interval__c,QueueTime__c from Schedule_APEX_Jobs_Queue__c]);
    obj01.QUpdateList = new list<Schedule_APEX_Jobs_Queue__c>([SELECT Apex_Class__c,Minute_Interval__c,QueueTime__c from Schedule_APEX_Jobs_Queue__c]);
    obj01.JobId = new List<Id>{ID};
    obj01.updatejobStatus();
    test.stopTest();
  }
    static testMethod void test_sendEmailToJobOwner_Method1(){
    test.startTest();
    List<Schedule_APEX_Jobs_Queue__c> schedule_apex_jobs_queue_Obj  =  [SELECT Apex_Class__c,Job_Name__c,Job_ID__c , Job_Name__r.OwnerId , Job_Name__r.CreatedBy.Name, name , Job_Frequency__c, Error_Message_Job__c, id from Schedule_APEX_Jobs_Queue__c];
    System.assertEquals(true,schedule_apex_jobs_queue_Obj.size()>0);
    EOPS_SendJobsToStdQueue obj01 = new EOPS_SendJobsToStdQueue();
    schedule_apex_jobs_queue_Obj[0].Minute_Interval__c = 15;
    update schedule_apex_jobs_queue_Obj[0];
    obj01.QJobsList = new list<Schedule_APEX_Jobs_Queue__c>([SELECT Apex_Class__c,Minute_Interval__c,QueueTime__c,job_name__c,job_id__c from Schedule_APEX_Jobs_Queue__c]);
    obj01.QUpdateList = new list<Schedule_APEX_Jobs_Queue__c>([SELECT Apex_Class__c,Minute_Interval__c,QueueTime__c,job_name__c,job_id__c from Schedule_APEX_Jobs_Queue__c]);
    //obj01.QUpdateList = new list<Schedule_APEX_Jobs_Queue__c>();
    obj01.JobId = new List<Id>();
    obj01.sendEmailToJobOwner(schedule_apex_jobs_queue_Obj[0]);
    test.stopTest();
  }  
    
    
    
}