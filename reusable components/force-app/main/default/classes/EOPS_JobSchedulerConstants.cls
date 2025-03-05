/* Title     : Apex Schedulable jobs redesign
* Vertical   : EOPS Core Services
* Description: Apex Class to keep all constants 
*/
public class EOPS_JobSchedulerConstants {
    public static final String JOB_DAILY = 'Daily';
    public static final String JOB_WEEKLY = 'Weekly';
    public static final String JOB_MONTHLY = 'Monthly';
    public static final String JOB_QUARTERLY = 'Quarterly'; 
    public static final String INVALID_CLASS_ERROR = 'Invalid Schedulable Class Name, Please verify';
    public static final String INVALID_START_DATE_ERROR = 'Job Start Date should not be the past date';
    public static final String INVALID_END_DATE_ERROR = 'Invalid Job End Date; Next fire date will be on ';
    public static final String INVALID_TIMEZONE_ERROR = 'Job is not valid for Today Occurrence, Please verify job Start date or Start time(PST)';
    public static final String INVALID_WEEKLY_ERROR = 'Please choose the frequency "Daily" instead of "Weekly"';
     public static final String JOB_DUPLICATE_ERROR = 'Job did not send to standard queue as there are multiple jobs exist for same class and This job Scheduled time is in the past'; 
                       
    
    public static final String DAY_SUNDAY = 'Sunday';
    public static final String DAY_MONDAY = 'Monday';
    public static final String DAY_TUESDAY = 'Tuesday';
    public static final String DAY_WEDNESDAY = 'Wednesday';
    public static final String DAY_THURSDAY = 'Thursday';
    public static final String DAY_FRIDAY = 'Friday';
    public static final String DAY_SATURDAY = 'Saturday';
    public static final String ORG_WIDE_EMAIL = 'noreply@salesforce.com';
    
    

}