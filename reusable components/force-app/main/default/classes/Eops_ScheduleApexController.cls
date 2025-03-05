public with sharing class Eops_ScheduleApexController {
    public Eops_ScheduleApexController() {

    }
    @AuraEnabled(cacheable=true)
    public static List<sObject> retriveScheduleClasses(String searchTerm, string myObject, String filter) {
        
           List<sObject> apexClassesList = new List<sObject>();
        System.debug('searchTerm:'+searchTerm);
       // if(String.isNotEmpty(searchTerm)){
            String searchQuery = null ;
        if(searchTerm != null && searchTerm != '' && searchTerm.length() > 0){
            searchTerm = string.escapeSingleQuotes(searchTerm);
            //searchQuery = 'Select Id, Body,Name from ApexClass Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' ORDER BY Name ASC  LIMIT  5';
            searchQuery = 'Select Id,Body,Name from ApexClass Where Name Like  \'%' + searchTerm + '%\' ORDER BY Name ASC  LIMIT  1000';
       
       
       for(ApexClass apexClass: database.query(searchQuery)){
                   String mystring = apexClass.Body;
                   mystring = mystring.toLowerCase();
                  //Modified this logic to fetch only schedule classes
                  if( !String.isBlank(mystring) && ( mystring.contains('schedulable') ) )
                  {
                    apexClassesList.add(apexClass);
                     
                  } 
            
        }
       }
     return apexClassesList;
    }


    @AuraEnabled(cacheable=true)
    public static Integer getCurrentJobCount(){
      //  return [SELECT COUNT() FROM AsyncApexJob WHERE JobType='ScheduledApex' AND Status IN ('Processing','Preparing','Queued')] ;
       return [SELECT count()  FROM CronTrigger WHERE CronJobDetail.JobType = '7' AND State = 'Waiting'];
    }

    @AuraEnabled
    public static string saveSchedule(Map<String, Object> jobinfo){
        String errMsg = '' ; 
        Scheduled_Job__c Schedule = new Scheduled_Job__c();
        String selectedClass = jobinfo.get('classid').ToString();
       
        try {  
            if(validateInput(selectedClass)){
                
                errMsg = 'Duplicate Job :'+[select id from Scheduled_Job__c 
                where Apex_Class__c =:selectedClass and Start_Date__c <=: system.today() 
                and End_Date__c >=: system.today() limit 1].Id; 
                return errMsg;
            }
                      
            System.debug(jobinfo.keySet());  
            for(String key:jobinfo.keySet()){
                
                System.debug('key:'+key+':Value:'+jobinfo.get(key));
            }  
            Schedule.Owner_Id__c = UserInfo.getUserId();
            Schedule.TimeZoneSidKey__c = Userinfo.getTimeZone().getID();
            Schedule.Preferred_Start_Time__c = (jobinfo.get('starttime') != null) ? 
            EOPS_JobSharedHelper.convertTime(jobinfo.get('starttime').ToString()) : Time.newInstance(00, 00, 00, 00);
            Schedule.Job_Frequency__c = (jobinfo.get('frequency') != null) ? String.escapeSingleQuotes(jobinfo.get('frequency').ToString()) : '';
            Schedule.Apex_Class__c = String.escapeSingleQuotes(jobinfo.get('classid').ToString());
            Schedule.Onday__c = (jobinfo.get('dayOfMonth') != null) ? String.escapeSingleQuotes(jobinfo.get('dayOfMonth').ToString()) : '';
            Schedule.Job_Name__c = String.escapeSingleQuotes(jobinfo.get('jobname').ToString());
            Schedule.Team_DL_Email__c = String.escapeSingleQuotes(jobinfo.get('teamdlemail').ToString());
            Schedule.Start_Date__c = Date.valueOf(jobinfo.get('startdate')+' '+'00:00:00');
            Schedule.End_Date__c = Date.valueOf(jobinfo.get('enddate')+' '+'00:00:00');
            Schedule.RunToday__c = boolean.valueOf(((jobinfo.get('runtype')) != null ? jobinfo.get('runtype') : false) );
            Schedule.MinInterval__c = (jobinfo.get('dailyDateValue')) != null ? Integer.valueOf(jobinfo.get('dailyDateValue')) : null;
            
           
            
            calculateNextFireTime(jobinfo,Schedule);
            system.debug('values before save****'+Schedule);
           	insert Schedule;  
               system.debug('Before Run Today');
                if(Schedule.RunToday__c == true){ //Run Today Occurrence
                    //update custom queue
                    List<Schedule_APEX_Jobs_Queue__c> li_queue = EOPS_JobSharedHelper.createCustomQueue(Schedule); // all of the code to create custom queue record is within shared UTIL method -ZP
                    Database.SaveResult[] srList = Database.insert(li_queue, false);
                }
                
            System.debug(jobinfo);
            return 'Success + 12232323';
        }
        catch (Exception e) {  
             System.debug('Error:'+e.getMessage());
            throw new AuraHandledException('Darn it! Something went wrong: '
                + e.getMessage());    
        }
    }
    private static boolean validateInput(String selectedClass){
      
        System.debug('selectedClass:'+selectedClass);
        
        //Validate if already Job is scheduled for the same selected class.
        if([select count() from Scheduled_Job__c where Apex_Class__c =:selectedClass
         and Start_Date__c <=: system.today() and End_Date__c >=: system.today()] > 0){
         	return true;
            } 
        return false ;
    }
    private static void calculateNextFireTime(Map<String, Object> jobinfo, Scheduled_Job__c Schedule){
        String jobFrequency = jobinfo.get('frequency').toString();
        
        
        //This logic sets the next fire time to tomorrow if start date is today to get ready for 12 AM scheduler
            											 //If its a later date then it will set to fire on the start date. -ZP
         If ( jobFrequency == 'Daily'){ 
             	Schedule.Next_Fire_Time__c = (Schedule.Start_date__c == system.today()) ? system.today().addDays(1) : Schedule.Start_Date__c;
		 }
        else if ( jobFrequency == 'Weekly'){
            date next_occur = WeeklyFireDate(jobinfo,Schedule);
            system.debug('value returned::: '+next_occur);
            Schedule.Next_Fire_Time__c = next_occur;
        }
        else if ( jobFrequency == 'Monthly'){
            String dayNum = jobinfo.get('dayOfMonth').toString();
            //NextFireTime for Monthly- Number of Day occurence 
            //Begin date of current month
            integer x;
            date currentday = Schedule.Start_Date__c;
            date StartDate = Date.newInstance(currentday.year(), currentday.month(), 1);
            if(dayNum == 'last'){  //Last day of month
                integer i = date.daysInMonth(currentday.year(), currentday.month());
                date LastDateOfMonth = Date.newInstance(StartDate.year(), StartDate.month(), i);
                Schedule.Next_Fire_Time__c = LastDateOfMonth;
                system.debug('Last day of month'+LastDateOfMonth);
            }else{
                x = Integer.valueOf(dayNum);
                if ( x > 1){
                    x = x - 1; 
                }
                else{
                    x = 0;
                }
                Schedule.Next_Fire_Time__c = StartDate + x;
                System.debug(Schedule.Next_Fire_Time__c);
            } 
            
            //If NextFireDate is less than current date, add one month
            If(Schedule.Next_Fire_Time__c <= system.today()){
                Date NextMonthDate = Schedule.Next_Fire_Time__c.addMonths(1);
                Schedule.Next_Fire_Time__c = NextMonthDate;
            }
        }
        else{
            Schedule.Next_Fire_Time__c = Schedule.Start_Date__c.addMonths(3);
        }
        
    }
    
private static date WeeklyFireDate(Map<String, Object> jobinfo,Scheduled_Job__c Schedule){
        date next_fire_date;
        
        Map<string,string> mapDaysSelected = new Map<string,string>();
        String selectedDays = jobinfo.get('days').toString();
    	 
    if(selectedDays != null && selectedDays.length() > 0){
        
        for(String weekDay : selectedDays.split(',')){
            mapDaysSelected.put(weekDay,weekDay);
            if(weekDay == 'Sunday')
                Schedule.Sunday__c = true ;
             if(weekDay == 'Monday')
                Schedule.Monday__c = true ;
             if(weekDay == 'Tuesday')
                Schedule.Tuesday__c = true ;
             if(weekDay == 'Wednesday')
                Schedule.Wednesday__c = true ;
             if(weekDay == 'Thursday')
                Schedule.Thursday__c = true ;
             if(weekDay == 'Friday')
                Schedule.Friday__c = true ;
             if(weekDay == 'Saturday')
                Schedule.Saturday__c = true ;
	
        }
        for(Integer i = 0 ;i < 8 ;i++){ 
            Date newDate = Schedule.Start_Date__c.addDays(i);  //Check the current day first
            Datetime dt = datetime.newInstance(newDate.year(), newDate.month(),newDate.day());
            String dayOfWeek= dt.format('EEEE'); //get dayName
            system.debug('Day :'+i + ' ' +dayOfWeek);
            if(MapDaysSelected.containsKey(dayOfWeek) && newDate != system.today()){  //check the SelectedDay in MapDaysSelected                 
                next_fire_date = newDate;                //collect next firedate
                i = i + 7;
            }	
        }
        
    }
     return next_fire_date;
    }
    
}