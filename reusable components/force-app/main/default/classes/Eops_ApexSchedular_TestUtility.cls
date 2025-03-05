public class Eops_ApexSchedular_TestUtility {
    public static Scheduled_Job__c populateScheduleJob(){
        Scheduled_Job__c scheduled_job_Obj = new Scheduled_Job__c(Apex_Class__c = 'TestSchApxJob', 
                                              End_Date__c = system.today().addDays(3), 
                                                              Job_Frequency__c = 'Daily', Pref_Start_Time__c = '06:00',
                                                              Start_Date__c = Date.ValueOf(system.today()), 
                                                              Job_Name__c = 'Test Run1', Sunday__c = true, 
                                                              Monday__c = true, Tuesday__c = true, 
                                                              Wednesday__c = true, Thursday__c = true, 
                                                              Friday__c = true, Saturday__c = true, 
                                                              RunToday__c = false);
       return scheduled_job_Obj ;
    }
    public static List<Scheduled_Job__c> queryScheduledJobs(){
        return ([SELECT Apex_Class__c,End_Date__c,Job_Frequency__c,Pref_Start_Time__c,
                                                  Start_Date__c,Job_Name__c,Sunday__c,Monday__c,Tuesday__c,Wednesday__c,
                                                  Thursday__c,Friday__c,Saturday__c,RunToday__c from Scheduled_Job__c]);
    }
    public static Scheduled_Job__c createScheduledJob(Scheduled_Job__c sch){
        populateScheduledJob(sch);
        return sch ;
    }
    public static Scheduled_Job__c createScheduledJob(Scheduled_Job__c sch,Integer interval){
        populateScheduledJob(sch);
        sch.MinInterval__c = interval ;
        return sch ;
    }
    public static Scheduled_Job__c createScheduledJob(Scheduled_Job__c sch,String jobName){
        populateScheduledJob(sch);
        sch.Job_Name__c = jobName ;
        return sch ;
    }
    
    public static Scheduled_Job__c createScheduledJob(Scheduled_Job__c sch,Date nextFireTime){
        populateScheduledJob(sch);
        sch.End_Date__c = system.today().addDays(365);
        sch.Job_Frequency__c= 'Monthly';
        sch.Start_Date__c = system.today();
        sch.Next_Fire_Time__c = nextFireTime;
        sch.Job_Name__c = 'Job_Name__c428' ;
        return sch ;
    }
    private static Scheduled_Job__c populateScheduledJob(Scheduled_Job__c objScheduled){
        objScheduled.End_Date__c = system.today().addDays(10);
        objScheduled.Job_Frequency__c='Daily';
        objScheduled.Pref_Start_Time__c='00:00';
        objScheduled.Start_Date__c = system.today().addDays(-2);
        objScheduled.RunToday__c = false;
        objScheduled.Next_Fire_Time__c = system.today();
        return objScheduled;
    }   
    public static Schedule_APEX_Jobs_Queue__c createScheduledJobQueue(Schedule_APEX_Jobs_Queue__c schq){
        populateScheduledJobQueue(schq);
        return schq ;
    }
    public static Schedule_APEX_Jobs_Queue__c createScheduledJobQueue(Schedule_APEX_Jobs_Queue__c schq, datetime qtime){
        populateScheduledJobQueue(schq);
        schq.Minute_Interval__c = null ;
        schq.QueueTime__c = qtime;
        return schq ;
    }
    public static Schedule_APEX_Jobs_Queue__c createScheduledJobQueue(Schedule_APEX_Jobs_Queue__c schq, integer interval){
        populateScheduledJobQueue(schq);
        schq.Minute_Interval__c = interval ;
        schq.QueueTime__c = system.today().addDays(-1);
        return schq ;
    }    
    private static Schedule_APEX_Jobs_Queue__c populateScheduledJobQueue(Schedule_APEX_Jobs_Queue__c objScheduledQ){
        objScheduledQ.Scheduled_Date__c = system.today();
        objScheduledQ.Status__c = 'Not Started';
        objScheduledQ.QueueTime__c = system.now().addDays(10);
        return objScheduledQ;
    } 
    public static Scheduled_Job__c createJobSchedule(Scheduled_Job__c sch){
        populateJobSchedule(sch);
        return sch ;
    }
    public static Scheduled_Job__c createJobSchedule(Scheduled_Job__c sch,String jobfreq){
        populateJobSchedule(sch);
        sch.Job_Frequency__c = jobfreq ;
        return sch ;
    }
    public static Scheduled_Job__c createJobSchedule(Scheduled_Job__c sch,integer interval){
        populateJobSchedule(sch);
        sch.MinInterval__c = interval ;
        sch.RunToday__c = true;
   		sch.Start_Date__c = system.today();
    	sch.Pref_Start_Time__c = '23:00';
        return sch ;
    }
    public static Scheduled_Job__c createJobSchedule(Scheduled_Job__c sch,date startdt){
        populateJobSchedule(sch);
        sch.Start_Date__c = startdt ;
        sch.Job_Frequency__c = 'Monthly';
   		sch.Apex_Class__c ='Test_Not_Exist';
        return sch ;
    }
    private static Scheduled_Job__c populateJobSchedule(Scheduled_Job__c jobschedule){
        jobschedule.Job_Frequency__c ='Daily';
        return jobschedule;
    } 
}