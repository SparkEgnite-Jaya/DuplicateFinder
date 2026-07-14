@IsTest
public class DF_BatchConfigurationControllerTest {
   
    @IsTest
    static void testScheduleWeeklyCleanup_performsAllOperations_whenInvoked() {

        Test.startTest();
        DF_BatchConfigurationController.JOB_NAME = 'Duplicate Finder Weekly Cleanup Test';

        DF_BatchConfigurationController.ScheduleStatusWrapper status = DF_BatchConfigurationController.getScheduleStatus();
        Assert.isFalse(status.isScheduled, 'Job should not be scheduled.');
        Assert.areEqual('Not Scheduled', status.status, 'Status should be Not Scheduled.');

        status = DF_BatchConfigurationController.scheduleWeeklyCleanup();

        Assert.isTrue(status.isScheduled, 'Job should be scheduled.');
        Assert.areEqual('WAITING', status.status, 'Job should be in WAITING state.');
        Assert.isNotNull(status.jobId, 'Job Id should not be null.');
        Assert.isNotNull(status.nextFireTime, 'Next fire time should not be null.');

        DF_BatchConfigurationController.ScheduleStatusWrapper existingStatus = DF_BatchConfigurationController.scheduleWeeklyCleanup();

        Assert.isTrue(existingStatus.isScheduled, 'Job should already be scheduled.');
        Assert.areEqual(status.jobId, existingStatus.jobId, 'Existing scheduled job should be returned.');
        Test.stopTest();
    }
}