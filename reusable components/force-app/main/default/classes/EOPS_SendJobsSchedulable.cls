/*
 * This class is to Send jobs from CustomObject Queue to Standard Schedulable Apex Queue- For every 15mins
 * 
 * @Team   : ESAS-Core Services
https://org62--devpro106.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage# * @Date   : 04-06-2018 
 */
global class EOPS_SendJobsSchedulable implements Schedulable{
     global void execute(SchedulableContext SC) {
        EOPS_SendJobsToStdQueue controller = new EOPS_SendJobsToStdQueue();
        controller.FetchQueueJobs();
    }
}