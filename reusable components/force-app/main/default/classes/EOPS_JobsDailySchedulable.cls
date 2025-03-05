/*
 * This class is to fetch all current day jobs and insert into custom object queue, on 12AM Daily
 * @Author : Suman Porandla
 * @Team   : ESAS-Core Services
 * @Date   : 04-06-2018 
 */
global class EOPS_JobsDailySchedulable implements Schedulable{
    global void execute(SchedulableContext SC) {
        EOPS_GetTodayJobs controller = new EOPS_GetTodayJobs();
        controller.GetTodayJobs();
    }

}