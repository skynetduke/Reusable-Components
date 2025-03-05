/*
@ESAS-CoreService 

*/
public with sharing class EOPS_JobSchedule {
    
    public void  doInsert() {
       
        String user = String.isNotBlank(ApexPages.currentPage().getParameters().get('userid'))  ?  string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('userid')) :'';
        String wek = String.isNotBlank(ApexPages.currentPage().getParameters().get('wek')) ? string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('wek')) : '';
        String mon = String.isNotBlank(ApexPages.currentPage().getParameters().get('mont')) ? string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('mont')): '';
        String start = String.isNotBlank(ApexPages.currentPage().getParameters().get('pst0')) ? string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('pst0')) :'';
        String check = String.isNotBlank(ApexPages.currentPage().getParameters().get('pt1'))?string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('pt1')):'';
        System.debug('*******'+start);
        String sun =String.isNotBlank(ApexPages.currentPage().getParameters().get('sun')) ? string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('sun')):'';
        String mond=String.isNotBlank(ApexPages.currentPage().getParameters().get('mon')) ? string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('mon')):'';
        String tue=String.isNotBlank(ApexPages.currentPage().getParameters().get('tue')) ? string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('tue')):'';
        String wed=String.isNotBlank(ApexPages.currentPage().getParameters().get('wed')) ? string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('wed')):'';
        String thu=String.isNotBlank(ApexPages.currentPage().getParameters().get('thu')) ? string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('thu')):'';
        String fri=String.isNotBlank(ApexPages.currentPage().getParameters().get('fri')) ? string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('fri')):'';
        String sat=String.isNotBlank(ApexPages.currentPage().getParameters().get('sat')) ? string.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('sat')):'';
        //  DateTime dt = DateTime.parse(StartTime);
        String weeks = sun + mond + tue + wed + thu + fri + sat;
        //System.debug('weeks'+weeks);
        String before=weeks.replace('null','');
        String croncreate='* * * ? * '+before;
        Scheduled_Job__c objdlt = new Scheduled_Job__c();
        objdlt.Job_Name__c=name;
       // objdlt.Start_Date__c = StartTime.;
       // objdlt.End_Date__c=EndTime;
        objdlt.Cron_Expression__c = croncreate;
        // objdlt.Owner_Id__c=user;
        insert objdlt;
    }
    public void cancel(){}
    public String  OwnerId{ get; set; }
    public String  CronExp{ get; set; }
    public Datetime  EndTime{ get; set; }
    public Datetime  StartTime{ get; set; }
    public String name { get; set; }
    public String Apexclass { get; set; }
    public Boolean Week{get;set;}
    public Boolean Month{get;set;}
}