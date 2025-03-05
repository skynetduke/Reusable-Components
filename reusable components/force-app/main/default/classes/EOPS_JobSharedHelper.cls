public with sharing class EOPS_JobSharedHelper {
    public static DateTime dtToday(DateTime dt, TimeZone tz) { //used positive offset by specified timezone
        integer offset = tz.getOffset(dt);
        return dt.addSeconds(-offset / 1000);
    }
    
    public static DateTime dtNow(DateTime dt, TimeZone tz) { //returns negative offset by specified timezone
        integer offset = tz.getOffset(dt);
        return dt.addSeconds(offset / 1000);
    }
    
    public static list<Schedule_APEX_Jobs_Queue__c> createCustomQueue(Scheduled_Job__c Schedule)
    {
        System.debug('Preferred StartTime :'+Schedule.Preferred_Start_Time__c);
       // string[] h = Schedule.Preferred_Start_Time__c.split(':');
        integer hour = Schedule.Preferred_Start_Time__c.hour();
        //Timezone tz = Timezone.getTimeZone(Schedule.TimeZoneSidKey__c);
        Timezone tz = Timezone.getTimeZone('America/Los_Angeles'); //Offsetting input time from GMT to PST
        datetime prefTime = dtToday(system.today(),tz); //returns DateTime starting at 7 AM
        
        list<Schedule_APEX_Jobs_Queue__c> li_queue = new list<Schedule_APEX_Jobs_Queue__c>();   
        Schedule_APEX_Jobs_Queue__c ls_queue = new Schedule_APEX_Jobs_Queue__c();
        ls_queue.Job_Name__c = Schedule.id;
        ls_queue.Apex_class__c = Schedule.Apex_Class__c;
       	ls_queue.Status__c = 'Not Started';
       	ls_queue.Scheduled_Date__c = System.today();
       	//ls_queue.Pref_Start_Time__c = Schedule.Pref_Start_Time__c;
        ls_queue.Preferred_Start_Time__c = Schedule.Preferred_Start_Time__c;
       	ls_queue.Job_Frequency__c = Schedule.Job_Frequency__c;
       	ls_queue.Start_Date__c = Schedule.Start_Date__c;
       	ls_queue.End_Date__c = Schedule.End_Date__c;
        ls_queue.QueueTime__c = prefTime.addHours(hour);
        
        if(schedule.MinInterval__c == null){
            li_queue.add(ls_queue);                        
        }
        else{
            prefTime = prefTime.addHours(hour);
            integer m = integer.valueOf(Schedule.MinInterval__c);
            for(integer i = (hour*60); i < 1439; i += m){ //logic to increment by min interval, take preferred start hour, multiply by 60 then increment by the specified min interval until it reaches the total minutes in a day 1440-1
                ls_queue = new Schedule_APEX_Jobs_Queue__c();
                
                ls_queue.Job_Name__c = Schedule.id;
                ls_queue.Apex_class__c = Schedule.Apex_Class__c;
                ls_queue.Status__c = 'Not Started';
                ls_queue.Scheduled_Date__c = System.today();
                //ls_queue.Pref_Start_Time__c = Schedule.Pref_Start_Time__c;
                ls_queue.Preferred_Start_Time__c = Schedule.Preferred_Start_Time__c;
                ls_queue.Job_Frequency__c = Schedule.Job_Frequency__c;
                ls_queue.Start_Date__c  = Schedule.Start_Date__c;
                ls_queue.End_Date__c   = Schedule.End_Date__c;
                ls_queue.Minute_Interval__c = Schedule.MinInterval__c;
                //ls_queue.OwnerId = Schedule.OwnerId;
                if(i != (hour*60)){
                    prefTime = prefTime.addMinutes(m); }
                ls_queue.QueueTime__c = prefTime;
                li_queue.add(ls_queue);                                                      
            }
        }
        return li_queue;
    }
    
    public static Time convertTime(String timeStr){
        String [] stime = timeStr.split(':');
        System.debug('Splitted Str:'+stime);
        Time formatedTime = Time.newInstance(Integer.valueOf(stime[0]), Integer.valueOf(stime[1]), 00, 00);
        return formatedTime ;
        
    }

}