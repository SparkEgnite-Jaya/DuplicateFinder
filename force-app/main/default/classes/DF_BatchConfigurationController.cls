public class DF_BatchConfigurationController {
    
    @TestVisible
    private static String JOB_NAME = 'Duplicate Finder Weekly Cleanup';
    private static String CRON_EXPRESSION = '0 0 10 ? * MON';

    public class ScheduleStatusWrapper {
        @AuraEnabled public Boolean isScheduled;
        @AuraEnabled public String status;
        @AuraEnabled public String jobId;
        @AuraEnabled public Datetime nextFireTime;
    }

    @AuraEnabled(cacheable=true)
    public static ScheduleStatusWrapper getScheduleStatus() {

        ScheduleStatusWrapper response = new ScheduleStatusWrapper();

        List<CronTrigger> jobs = [SELECT Id,State,NextFireTime
                                  FROM CronTrigger
                                  WHERE CronJobDetail.Name = :JOB_NAME
                                  AND State IN ('WAITING', 'ACQUIRED')
                                  LIMIT 1];

        if(jobs.isEmpty()){
            response.isScheduled = false;
            response.status = 'Not Scheduled';
            return response;
        }

        CronTrigger job = jobs[0];

        response.isScheduled = true;
        response.status = job.State;
        response.jobId = job.Id;
        response.nextFireTime = job.NextFireTime;

        return response;
    }

    @AuraEnabled
    public static ScheduleStatusWrapper scheduleWeeklyCleanup() {

        ScheduleStatusWrapper response = getScheduleStatus();

        // Prevent duplicate schedules
        if(response.isScheduled) {
            return response;
        }
		
        try {
            System.schedule(JOB_NAME, CRON_EXPRESSION,new DF_DeleteOldCustomFieldHistorySchedular());
        } catch(Exception ex) {
            response.isScheduled = false;
            response.status = 'An unexpected error occurred while scheduling the weekly cleanup job.';
            return response;
        }
        
        return getScheduleStatus();
    }
    
}