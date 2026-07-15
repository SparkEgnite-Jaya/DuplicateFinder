public with sharing class DF_BatchConfigurationController {
    
    @TestVisible
    private static String JOB_NAME = 'Duplicate Finder Weekly Cleanup';
    private static String CRON_EXPRESSION = '0 0 10 ? * MON';
    
    public class ScheduleStatusWrapper {
        @AuraEnabled public Boolean isScheduled;
        @AuraEnabled public String message;
        @AuraEnabled public String jobId;
        @AuraEnabled public Datetime nextFireTime;
    }
    
    @AuraEnabled
    public static ScheduleStatusWrapper getScheduleStatus() {
        
        List<CronTrigger> jobs = [
            SELECT Id, State, NextFireTime
            FROM CronTrigger
            WHERE CronJobDetail.Name = :JOB_NAME
            LIMIT 1
        ];
        
        if (jobs.isEmpty()) {
            ScheduleStatusWrapper response = new ScheduleStatusWrapper();
            response.isScheduled = false;
            response.message = 'Weekly cleanup has not been scheduled.';
            return response;
        }
        
        CronTrigger job = jobs[0];
        return buildResponse(job.State, job.Id, job.NextFireTime);
    }
    
    @AuraEnabled
    public static ScheduleStatusWrapper scheduleWeeklyCleanup() {
        
        ScheduleStatusWrapper response = getScheduleStatus();
        
        if (response.isScheduled) {
            return response;
        }
        
        try {
            System.schedule(JOB_NAME, CRON_EXPRESSION, new DF_DeleteOldCustomFieldHistorySchedular());
            return getScheduleStatus();
        } catch (Exception ex) {
            return buildResponse('ERROR', null, null);
        }
    }
    
    @TestVisible
    private static ScheduleStatusWrapper buildResponse(String state, Id jobId, Datetime nextFireTime) {
        
        ScheduleStatusWrapper response = new ScheduleStatusWrapper();
        response.jobId = (String)jobId;
        response.nextFireTime = nextFireTime;
        
        switch on state {
            when 'WAITING', 'ACQUIRED', 'PAUSED' {
                response.isScheduled = true;
            }
            when else {
                response.isScheduled = false;
            }
        }
        
        switch on state {
            when 'WAITING' {
                response.message = 'Weekly cleanup is scheduled.';
            }
            when 'ACQUIRED' {
                response.message = 'Weekly cleanup is currently running.';
            }
            when 'PAUSED' {
                response.message = 'Weekly cleanup is currently paused. Resume or delete the scheduled job from Setup → Scheduled Jobs before scheduling it again.';
            }
            when 'ERROR' {
                response.message = 'An unexpected error occurred while scheduling the weekly cleanup job.';
            }
            when else {
                response.message = 'Weekly cleanup job status: ' + state + '.';
            }
        }
        
        return response;
    }
}