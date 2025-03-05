/* Title      : Apex Schedulable jobs redesign
*  Vertical   : EOPS Core Services

*  Description: Test class for EOPS_GetTodayJobs
*/
@isTest(SeeAllData=false)
public class EOPS_GetTodayJobs_Test{
    @testSetup
    static void setupTestData(){
        test.startTest();
        Scheduled_Job__c scheduled_job_Obj = new Scheduled_Job__c( Apex_Class__c = 'TestSchApxJob', End_Date__c = Date.ValueOf(system.today()+10), Job_Frequency__c = 'Daily', Pref_Start_Time__c = '06:00', Start_Date__c = Date.ValueOf(system.today()-2), Job_Name__c = 'Test Job Run- Today 15mins', Sunday__c = false, Monday__c = false, Tuesday__c = false, Wednesday__c = false, Thursday__c = false, Friday__c = false, Saturday__c = false, RunToday__c = true);
        Insert scheduled_job_Obj; 
        Schedule_APEX_Jobs_Queue__c schedule_apex_jobs_queue_Obj = new Schedule_APEX_Jobs_Queue__c(Job_Name__c = scheduled_job_Obj.Id,Apex_Class__c = 'TestSchApxJob');
        Insert schedule_apex_jobs_queue_Obj; 
        test.stopTest();
    }
    
    static testMethod void test_getTodayJobs_Method1(){
        List<Scheduled_Job__c> scheduled_job_Obj  =  [SELECT Id,Apex_Class__c,Cron_Expression__c,End_Date__c,Friday__c,Job_Frequency__c,Job_Name__c,MinInterval__c,Monday__c,Name,Next_Fire_Time__c,OnDay__c,Owner_Id__c,Pref_Start_Time__c,Prev_Fire_Time__c,RunToday__c,Saturday__c,Start_Date__c,Sunday__c,SystemModstamp,Thursday__c,TimeZoneSidKey__c,Tuesday__c,Wednesday__c FROM Scheduled_Job__c];
        List<Schedule_APEX_Jobs_Queue__c> schedule_apex_jobs_queue_Obj  =  [SELECT Id,ActualFireTime__c,Apex_Class__c,End_Date__c,Job_Frequency__c,Job_ID__c,Job_Name__c,Minute_Interval__c,Name,Pref_Start_Time__c,QueueTime__c,Status__c,Start_Date__c FROM Schedule_APEX_Jobs_Queue__c];
        EOPS_GetTodayJobs eopsJob = new EOPS_GetTodayJobs();
        scheduled_job_Obj[0] = Eops_ApexSchedular_TestUtility.createScheduledJob(scheduled_job_Obj[0]);
        Update scheduled_job_Obj[0];
        system.assertNotEquals(true,schedule_apex_jobs_queue_Obj[0].Start_Date__c == scheduled_job_Obj[0].Start_Date__c,'Start Date not updated');
        eopsJob.getTodayJobs();
        system.assertEquals(true,eopsJob.li_queue[0].Start_Date__c == scheduled_job_Obj[0].Start_Date__c,'Start Date updated');
    }
    static testMethod void test_getTodayJobs_Method2(){
        List<Scheduled_Job__c> scheduled_job_Obj  =  [SELECT Id,Apex_Class__c,Cron_Expression__c,End_Date__c,Friday__c,Job_Frequency__c,Job_Name__c,MinInterval__c,Monday__c,Name,Next_Fire_Time__c,OnDay__c,OwnerId,Owner_Id__c,Pref_Start_Time__c,Prev_Fire_Time__c,RunToday__c,Saturday__c,Start_Date__c,Sunday__c,SystemModstamp,Thursday__c,TimeZoneSidKey__c,Tuesday__c,Wednesday__c FROM Scheduled_Job__c];
        List<Schedule_APEX_Jobs_Queue__c> schedule_apex_jobs_queue_Obj  =  [SELECT Id,ActualFireTime__c,Apex_Class__c,End_Date__c,Job_Frequency__c,Job_ID__c,Job_Name__c,Minute_Interval__c,Name,Pref_Start_Time__c,QueueTime__c,Status__c FROM Schedule_APEX_Jobs_Queue__c];
        EOPS_GetTodayJobs eopsJob = new EOPS_GetTodayJobs();
        scheduled_job_Obj[0] = Eops_ApexSchedular_TestUtility.createScheduledJob(scheduled_job_Obj[0],15);
        Update scheduled_job_Obj[0];
        system.assertNotEquals(true,schedule_apex_jobs_queue_Obj[0].Job_Frequency__c == scheduled_job_Obj[0].Job_Frequency__c,'Job frequesncy not updated');
        eopsJob.getTodayJobs();
        system.assertEquals(true,eopsJob.li_queue[0].Job_Frequency__c == scheduled_job_Obj[0].Job_Frequency__c,'Job frequesncy updated');
    }
    static testMethod void test_getTodayJobs_Method3(){
        List<Scheduled_Job__c> scheduled_job_Obj  =  [SELECT Id,Apex_Class__c,Cron_Expression__c,End_Date__c,Friday__c,Job_Frequency__c,Job_Name__c,MinInterval__c,Monday__c,Name,Next_Fire_Time__c,OnDay__c,OwnerId,Owner_Id__c,Pref_Start_Time__c,Prev_Fire_Time__c,RunToday__c,Saturday__c,Start_Date__c,Sunday__c,SystemModstamp,Thursday__c,TimeZoneSidKey__c,Tuesday__c,Wednesday__c FROM Scheduled_Job__c];
        List<Schedule_APEX_Jobs_Queue__c> schedule_apex_jobs_queue_Obj  =  [SELECT Id,ActualFireTime__c,Apex_Class__c,End_Date__c,Job_Frequency__c,Job_ID__c,Job_Name__c,Minute_Interval__c,Name,Pref_Start_Time__c,QueueTime__c,Status__c FROM Schedule_APEX_Jobs_Queue__c];
        EOPS_GetTodayJobs eopsJob = new EOPS_GetTodayJobs();
        scheduled_job_Obj[0] = Eops_ApexSchedular_TestUtility.createScheduledJob(scheduled_job_Obj[0],60);
        
        Update scheduled_job_Obj[0];
        system.assertNotEquals(true,schedule_apex_jobs_queue_Obj[0].End_Date__c == scheduled_job_Obj[0].End_Date__c,'End date not updated');
        eopsJob.getTodayJobs();
        system.assertEquals(true,eopsJob.li_queue[0].End_Date__c == scheduled_job_Obj[0].End_Date__c,'End date updated');
    }
    static testMethod void test_getNextFireDate_Method1(){
        date nextOccurDate = null;
        List<Scheduled_Job__c> scheduled_job_Obj  =  [SELECT Apex_Class__c,End_Date__c,Job_Frequency__c,Next_Fire_Time__c,Pref_Start_Time__c,Start_Date__c,Job_Name__c,Sunday__c,Monday__c,Tuesday__c,Wednesday__c,Thursday__c,Friday__c,Saturday__c,RunToday__c from Scheduled_Job__c];
        EOPS_GetTodayJobs eopsJob = new EOPS_GetTodayJobs();
        scheduled_job_Obj[0] = Eops_ApexSchedular_TestUtility.createScheduledJob(scheduled_job_Obj[0],'Job_Name__c428');
        Update scheduled_job_Obj[0];
        system.assertNotEquals(true,scheduled_job_Obj[0].Next_Fire_Time__c+1 == nextOccurDate,'Next Fire time not updated');
        nextOccurDate = eopsJob.getNextFireDate(scheduled_job_Obj[0]);
        system.assertEquals(true,scheduled_job_Obj[0].Next_Fire_Time__c+1 == nextOccurDate,'Next Fire time updated');
    }
    
    static testMethod void test_getNextFireDate_Method2(){
        date nextOccurDate = null;
        List<Scheduled_Job__c> scheduled_job_Obj  =  [SELECT Apex_Class__c,End_Date__c,Job_Frequency__c,Next_Fire_Time__c,Onday__c,Pref_Start_Time__c,Start_Date__c,Job_Name__c,Sunday__c,Monday__c,Tuesday__c,Wednesday__c,Thursday__c,Friday__c,Saturday__c,RunToday__c from Scheduled_Job__c];
        EOPS_GetTodayJobs eopsJob = new EOPS_GetTodayJobs();
        scheduled_job_Obj[0] = Eops_ApexSchedular_TestUtility.createScheduledJob(scheduled_job_Obj[0],system.today()+35);     
        scheduled_job_Obj[0].Onday__c = '15'; 
        Update scheduled_job_Obj[0];
        system.assertNotEquals(true,Date.newInstance(scheduled_job_Obj[0].Next_Fire_Time__c.year(), scheduled_job_Obj[0].Next_Fire_Time__c.month(), 1)+14 == nextOccurDate,'Next Fire time has been defined');
        nextOccurDate = eopsJob.getNextFireDate(scheduled_job_Obj[0]);
        system.assertEquals(true,Date.newInstance(scheduled_job_Obj[0].Next_Fire_Time__c.year(), scheduled_job_Obj[0].Next_Fire_Time__c.month(), 1)+14 == nextOccurDate,'Next Fire time has been defined');
    }
    static testMethod void test_getNextFireDate_Method3(){  
        date nextOccurDate = null;
        List<Scheduled_Job__c> scheduled_job_Obj  =  [SELECT Apex_Class__c,End_Date__c,Job_Frequency__c,Next_Fire_Time__c,Onday__c,Pref_Start_Time__c,Start_Date__c,Job_Name__c,Sunday__c,Monday__c,Tuesday__c,Wednesday__c,Thursday__c,Friday__c,Saturday__c,RunToday__c from Scheduled_Job__c];
        EOPS_GetTodayJobs eopsJob = new EOPS_GetTodayJobs();
        scheduled_job_Obj[0] = Eops_ApexSchedular_TestUtility.createScheduledJob(scheduled_job_Obj[0],system.today()+35);
        scheduled_job_Obj[0].Onday__c = 'Last';   
        Update scheduled_job_Obj[0];
        system.assertNotEquals(true,Date.newInstance(Date.newInstance(scheduled_job_Obj[0].Next_Fire_Time__c.year(), scheduled_job_Obj[0].Next_Fire_Time__c.month(), 1).year(), Date.newInstance(scheduled_job_Obj[0].Next_Fire_Time__c.year(), scheduled_job_Obj[0].Next_Fire_Time__c.month(), 1).month(), date.daysInMonth(scheduled_job_Obj[0].Next_Fire_Time__c.year(), scheduled_job_Obj[0].Next_Fire_Time__c.month())) == nextOccurDate);
        nextOccurDate = eopsJob.getNextFireDate(scheduled_job_Obj[0]);
        system.assertEquals(true,Date.newInstance(Date.newInstance(scheduled_job_Obj[0].Next_Fire_Time__c.year(), scheduled_job_Obj[0].Next_Fire_Time__c.month(), 1).year(), Date.newInstance(scheduled_job_Obj[0].Next_Fire_Time__c.year(), scheduled_job_Obj[0].Next_Fire_Time__c.month(), 1).month(), date.daysInMonth(scheduled_job_Obj[0].Next_Fire_Time__c.year(), scheduled_job_Obj[0].Next_Fire_Time__c.month())) == nextOccurDate);
    }
    
    
    static testMethod void test_getNextFireDate_Method4(){
        date nextOccurDate = null;
        List<Scheduled_Job__c> scheduled_job_Obj  =  [SELECT Apex_Class__c,End_Date__c,Job_Frequency__c,Next_Fire_Time__c,Pref_Start_Time__c,Start_Date__c,Job_Name__c,Sunday__c,Monday__c,Tuesday__c,Wednesday__c,Thursday__c,Friday__c,Saturday__c,RunToday__c from Scheduled_Job__c];
        EOPS_GetTodayJobs eopsJob = new EOPS_GetTodayJobs();
        scheduled_job_Obj[0] = Eops_ApexSchedular_TestUtility.createScheduledJob(scheduled_job_Obj[0],system.today());  
        scheduled_job_Obj[0].Job_Frequency__c='Quarterly';
        scheduled_job_Obj[0].Start_Date__c = system.today()-1;
        Update scheduled_job_Obj[0];
        system.assertNotEquals(true, scheduled_job_Obj[0].Next_Fire_Time__c.addMonths(3) == nextOccurDate,'Next Fire time not defined');
        nextOccurDate = eopsJob.getNextFireDate(scheduled_job_Obj[0]);
        system.assertEquals(true, scheduled_job_Obj[0].Next_Fire_Time__c.addMonths(3) == nextOccurDate,'Next Fire time has been defined');
        system.assertEquals(true, scheduled_job_Obj[0].Next_Fire_Time__c.addMonths(3).month() == nextOccurDate.month());
    }
    
    public static testMethod void test_getNextFireDate_Method5(){
        date nextOccurDate = null;
        List<Scheduled_Job__c> scheduled_job_Obj  =  [SELECT Apex_Class__c,End_Date__c,Job_Frequency__c,Next_Fire_Time__c,Pref_Start_Time__c,Start_Date__c,Job_Name__c,Sunday__c,Monday__c,Tuesday__c,Wednesday__c,Thursday__c,Friday__c,Saturday__c,RunToday__c from Scheduled_Job__c];
        EOPS_GetTodayJobs eopsJob = new EOPS_GetTodayJobs();
        scheduled_job_Obj[0] = Eops_ApexSchedular_TestUtility.createScheduledJob(scheduled_job_Obj[0],system.today()); 
        scheduled_job_Obj[0].End_Date__c = system.today()+30;
        scheduled_job_Obj[0].Job_Frequency__c='Weekly';
        scheduled_job_Obj[0].Start_Date__c = system.today()-1;
        scheduled_job_Obj[0].Sunday__c=true;
        scheduled_job_Obj[0].Monday__c=true;
        scheduled_job_Obj[0].Tuesday__c=true;
        scheduled_job_Obj[0].Wednesday__c=true;
        scheduled_job_Obj[0].Thursday__c=true;
        scheduled_job_Obj[0].Friday__c=true;
        scheduled_job_Obj[0].Saturday__c=true;
        Update scheduled_job_Obj[0];
        system.assertNotEquals(true,scheduled_job_Obj[0].Next_Fire_Time__c.addDays(1) == nextOccurDate,'Next Fire time has been defined');
        nextOccurDate = eopsJob.getNextFireDate(scheduled_job_Obj[0]);
        system.assertEquals(true,scheduled_job_Obj[0].Next_Fire_Time__c.addDays(1) == nextOccurDate,'Next Fire time has been defined');
    }
}