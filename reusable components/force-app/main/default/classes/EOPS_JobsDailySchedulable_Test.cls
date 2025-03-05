/* Title      : Apex Schedulable jobs redesign
*  Vertical   : EOPS Core Services
*  Developer  : Hemasundar Rada
*  Date       : 15/03/2019
*  Description: Test class for EOPS_SendJobsToStdQueue
*/
@isTest(SeeAllData=false)
private class EOPS_JobsDailySchedulable_Test{
    static testMethod void EOPS_JobsDailySchedulable_Test(){
    String CRON_EXP = '0 0 0 3 9 ? 2022';
    EOPS_JobsDailySchedulable eopsJobSchedule = new EOPS_JobsDailySchedulable();
            Scheduled_Job__c scheduled_job_Obj = new Scheduled_Job__c( Apex_Class__c = 'TestSchApxJob',
            End_Date__c = Date.ValueOf(system.today()+10),
            Job_Frequency__c = 'Daily', Pref_Start_Time__c = '06:00',
            Start_Date__c = Date.ValueOf(system.today()-2),
            Job_Name__c = 'Test Job Run- Today 15mins', 
            Sunday__c = false, Monday__c = false, Tuesday__c = false, Wednesday__c = false, Thursday__c = false, Friday__c = false, Saturday__c = false, RunToday__c = true);
        Insert scheduled_job_Obj;     
	Schedule_APEX_Jobs_Queue__c schedule_apex_jobs_queue_Obj = new Schedule_APEX_Jobs_Queue__c(Apex_Class__c = 'TestSchApxJob',Job_Name__c= scheduled_job_Obj.Id);
    Insert schedule_apex_jobs_queue_Obj;
    system.schedule('EOPS_JobsDailySchedulable_Test', CRON_EXP, eopsJobSchedule);
  }
}