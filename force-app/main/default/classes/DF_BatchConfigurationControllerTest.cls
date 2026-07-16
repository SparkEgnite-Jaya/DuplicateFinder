@IsTest
private class DF_BatchConfigurationControllerTest {
    
     @IsTest
    static void getScheduleStatus_shouldReturnNotScheduled_whenNoJobExists() {
        Test.startTest();
        DF_BatchConfigurationController.JOB_NAME = 'Duplicate Finder Weekly Cleanup Test';
        DF_BatchConfigurationController.ScheduleStatusWrapper result = DF_BatchConfigurationController.getScheduleStatus();
        Test.stopTest();

        Assert.isFalse(result.isScheduled);
        Assert.areEqual('Weekly cleanup has not been scheduled.', result.message);
        Assert.isNull(result.jobId);
        Assert.isNull(result.nextFireTime);
    }

    @IsTest
    static void scheduleWeeklyCleanup_shouldScheduleJob_whenJobDoesNotExist() {
        Test.startTest();
        DF_BatchConfigurationController.JOB_NAME = 'Duplicate Finder Weekly Cleanup Test';
        DF_BatchConfigurationController.ScheduleStatusWrapper result = DF_BatchConfigurationController.scheduleWeeklyCleanup();
        Test.stopTest();

        Assert.isTrue(result.isScheduled);
        Assert.areEqual('Weekly cleanup is scheduled.', result.message);
        Assert.isNotNull(result.jobId);
        Assert.isNotNull(result.nextFireTime);
    }

    @IsTest
    static void scheduleWeeklyCleanup_shouldReturnExistingJob_whenAlreadyScheduled() {
        Test.startTest();
        DF_BatchConfigurationController.JOB_NAME = 'Duplicate Finder Weekly Cleanup Test';
        DF_BatchConfigurationController.ScheduleStatusWrapper firstResult = DF_BatchConfigurationController.scheduleWeeklyCleanup();
        DF_BatchConfigurationController.ScheduleStatusWrapper secondResult = DF_BatchConfigurationController.scheduleWeeklyCleanup();
        Test.stopTest();

        Assert.isTrue(secondResult.isScheduled);
        Assert.areEqual('Weekly cleanup is scheduled.', secondResult.message);
        Assert.areEqual(firstResult.jobId, secondResult.jobId);
    }

    @IsTest
    static void buildResponse_shouldReturnScheduled_whenWaiting() {
        DF_BatchConfigurationController.ScheduleStatusWrapper result = DF_BatchConfigurationController.buildResponse('WAITING', UserInfo.getUserId(), System.now());

        Assert.isTrue(result.isScheduled);
        Assert.areEqual('Weekly cleanup is scheduled.', result.message);
        Assert.areEqual(UserInfo.getUserId(), result.jobId);
        Assert.isNotNull(result.nextFireTime);
    }

    @IsTest
    static void buildResponse_shouldReturnRunning_whenAcquired() {
        DF_BatchConfigurationController.ScheduleStatusWrapper result = DF_BatchConfigurationController.buildResponse('ACQUIRED', null, null);

        Assert.isTrue(result.isScheduled);
        Assert.areEqual('Weekly cleanup is currently running.', result.message);
    }

    @IsTest
    static void buildResponse_shouldReturnPaused_whenPaused() {
        DF_BatchConfigurationController.ScheduleStatusWrapper result = DF_BatchConfigurationController.buildResponse('PAUSED', null, null);

        Assert.isTrue(result.isScheduled);
        Assert.areEqual('Weekly cleanup is currently paused. Resume or delete the scheduled job from Setup → Scheduled Jobs before scheduling it again.', result.message);
    }

    @IsTest
    static void buildResponse_shouldReturnError_whenError() {
        DF_BatchConfigurationController.ScheduleStatusWrapper result = DF_BatchConfigurationController.buildResponse('ERROR', null, null);

        Assert.isFalse(result.isScheduled);
        Assert.areEqual('An unexpected error occurred while scheduling the weekly cleanup job.', result.message);
    }

    @IsTest
    static void buildResponse_shouldReturnUnknownState_whenComplete() {
        DF_BatchConfigurationController.ScheduleStatusWrapper result = DF_BatchConfigurationController.buildResponse('COMPLETE', null, null);

        Assert.isFalse(result.isScheduled);
        Assert.areEqual('Weekly cleanup job status: COMPLETE.', result.message);
    }

    @IsTest
    static void buildResponse_shouldReturnUnknownState_whenDeleted() {
        DF_BatchConfigurationController.ScheduleStatusWrapper result = DF_BatchConfigurationController.buildResponse('DELETED', null, null);

        Assert.isFalse(result.isScheduled);
        Assert.areEqual('Weekly cleanup job status: DELETED.', result.message);
    }
    
}