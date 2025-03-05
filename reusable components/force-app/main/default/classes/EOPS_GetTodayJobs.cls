/* Title      : Apex Schedulable jobs redesign
* Vertical   : EOPS Core Services
* Description: This Program runs through batch once in daily @12A.M and send jobs to Cust.Obj Queue
*/
public with sharing class EOPS_GetTodayJobs {
    
    public List<Scheduled_Job__c> li_jobs;
    public List<Scheduled_Job__c> li_nextFireDate;
    public List<Schedule_APEX_Jobs_Queue__c> li_queue; 
    //public Schedule_APEX_Jobs_Queue__c ls_queue; //remove due to UTIL logic -ZP
    public List<string> QInsertErrorList;
    public List<string> ScheduleErrorList;
    
    /* Fetches all the current day jobs and insert jobs into Cust.Obj queue */
    public void getTodayJobs(){
        // get the valid jobs info as per the field 'NextFireDate' 
        li_jobs = [SELECT Id,
                   Name,
                   Job_Name__c,
                   Apex_Class__c,
                   Job_Frequency__c,
                   Cron_Expression__c,
                   Start_Date__c,
                   End_Date__c,
                  Preferred_Start_Time__c,
                   Next_Fire_Time__c,
                   Sunday__c,
                   Monday__c,
                   Tuesday__c,
                   Wednesday__c,
                   Thursday__c,
                   Friday__c,
                   Saturday__c,
                   Onday__c,
                   TimeZoneSidKey__c,
                   minInterval__c FROM Scheduled_Job__c
                   WHERE Freeze_Schedule_job__c = false and Next_Fire_Time__c =: system.today()
                   AND Start_Date__c <=: system.today()
                   AND End_Date__c >=: system.today() ORDER BY Job_Frequency__c];
        
        IF( li_jobs.size() > 0 && !li_jobs.isEmpty())
        {
            li_queue = new List<Schedule_APEX_Jobs_Queue__c>();
            li_nextFireDate = new List<Scheduled_Job__c>();
            system.debug('Total number of records retrieved :'+li_jobs.size());
            
            for( Scheduled_Job__c  wa: li_jobs){   //collect jobs for sending Queue Obj
                system.debug('Record ---->'+wa);
                li_queue.addAll(EOPS_JobSharedHelper.createCustomQueue(wa));
                //Update Next Fire date
                date Next_date = GetNextFireDate(wa);
                wa.Next_Fire_Time__c = Next_date;
                wa.Prev_Fire_Time__c = system.now();
                li_nextFireDate.add(wa);
            }
            // 1.Insert recrods to Queue Object
            Database.SaveResult[] srList = Database.insert(li_queue, false);
            // Iterate each record to get success and failure records
            integer i = 0;
            List<string> QInsertErrorList = new List<string>();
            for(Database.SaveResult sr : srList){
                
                if (sr.isSuccess()){
                    system.debug('Success record Id:' + sr.getId());
                }
                else{
                    //insert failed, get all errrors
                    for(Database.Error err : sr.getErrors()){
                        string mge = 'Error Message::' + err.getStatusCode() + ': ' + err.getMessage() + err.getFields();
                        string st = 'JobId : ' + li_jobs[i].Name + ' ' + mge;
                        QInsertErrorList.add(st);
                    }
                }
                i++; // To get the respective record
            }
            system.debug('QInsertErrorList::' +QInsertErrorList);
            
            //2. Update Schedule Object with NextFireDate & PreviousFireDate
            Database.SaveResult[] srUpdate = Database.update(li_nextFireDate, false);
            // Iterate each record to get success and failure records
            i = 0;
            List<string> ScheduleErrorList = new List<string>();
            for(Database.SaveResult sr : srUpdate){
                
                if (sr.isSuccess()){
                    system.debug('Success record Id:' + sr.getId());
                }
                else{
                    //insert failed, get all errrors
                    for(Database.Error err : sr.getErrors()){
                        string mge = 'Error Message::' + err.getStatusCode() + ': ' + err.getMessage() + err.getFields();
                        string st = 'JobId : ' + li_nextFireDate[i].Name + ' ' + mge;
                        ScheduleErrorList.add(st);
                    }
                }
                i++; // To get the corressponding record
            }
            system.debug('Schedule Update Error List::' +ScheduleErrorList);
            
        }else{
            system.debug('No records/jobs found for today from Obj Schedule__c');
        }
        
        //   system.assert(false);  //For RollBack the changes
    }
    
    /* To determine the next fire date and update in main cust. object */
    public date getNextFireDate(Scheduled_Job__c wa){
        
        date nextOccur;
        
        if(wa.Job_Frequency__c == 'Daily'){
            nextOccur = wa.Next_Fire_Time__c + 1; //next day
        }
        else if( wa.Job_Frequency__c == 'Weekly'){
            string weekday;
            
            Map<string,string> MapDaysSelected = new Map<string,string>();
            
            
            if (wa.Sunday__c == true){
                weekday = 'Sunday';
                MapDaysSelected.put('Sunday', 'Sunday');
            } if (wa.Monday__c == true){
                weekday = 'Monday';
                MapDaysSelected.put('Monday', 'Monday');
            } if (wa.Tuesday__c == true){
                weekday = 'Tuesday';
                MapDaysSelected.put('Tuesday', 'Tuesday');
            } if (wa.Wednesday__c == true){
                weekday = 'Wednesday';
                MapDaysSelected.put('Wednesday', 'Wednesday');
            } if (wa.Thursday__c == true){
                weekday = 'Thursday';
                MapDaysSelected.put('Thursday', 'Thursday');
            } if (wa.Friday__c == true){
                weekday = 'Friday';
                MapDaysSelected.put('Friday', 'Friday');
            } if (wa.Saturday__c == true){
                weekday = 'Saturday';
                MapDaysSelected.put('Saturday', 'Saturday');
            }
            
            //system.debug('GetNextFireDate-method: Days selected in a week :'+MapDaysSelected);
            for(Integer i = 0 ;i < 8 ;i++){ 
                Date newDate = wa.Next_Fire_Time__c.addDays(i);  //Check the current day first
                Datetime dt = datetime.newInstance(newDate.year(), newDate.month(),newDate.day());
                String dayOfWeek= dt.format('EEEE'); //get dayName
                if(MapDaysSelected.containsKey(dayOfWeek) && newDate != system.today()){  //check the SelectedDay in MapDaysSelected                 
                    nextOccur = newDate;                //collect next firedate
                    System.debug('Next weekly occurence --->' + dayOfWeek + ' ' + newDate);
                    i = i + 7;
                }	
            }    
            
        }
        else if( wa.Job_Frequency__c == 'Monthly'){
            //1.NextFireTime for Monthly- Number of Day occurence 
            integer x;
            date currentday = wa.Next_Fire_Time__c;
            date StartDate = Date.newInstance(currentday.year(), currentday.month(), 1); //1st of curr.month
            if(wa.Onday__c == 'last'){  //Last day of month
                integer i = date.daysInMonth(currentday.year(), currentday.month());
                date LastDateOfMonth = Date.newInstance(StartDate.year(), StartDate.month(), i);
                nextOccur = LastDateOfMonth;
                system.debug('Last day of month'+LastDateOfMonth);
            }else{
                x = Integer.valueOf(wa.Onday__c);
                if ( x > 1){
                    x = x - 1; 
                }
                else{
                    x = 0;
                }
                nextOccur = StartDate + x;
            } 
            //if NextFireDate is less than current date, add one month
            If(nextOccur <= system.today()){
                Date NextMonthDate = nextOccur.addMonths(1);
                nextOccur = NextMonthDate;
            }    
        }
        else if(wa.Job_Frequency__c == 'Quarterly'){
            nextOccur = wa.Next_Fire_Time__c.addMonths(3);
        }
        
        //check job validity date
        if (wa.End_Date__c < nextOccur){
            nextOccur = null;
            system.debug('End date < next fire date hence null :'+wa.Name);
        }
        return nextOccur;  
    }
    
}