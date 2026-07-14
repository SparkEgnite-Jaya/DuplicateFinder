@IsTest
private class DF_ConfigurationControllerTest {

    @IsTest
    static void testGetConfigurationStatus_returnsNotConfigured_whenCustomSettingDoesNotExist() {

        Test.startTest();
        DF_ConfigurationController.ConfigurationStatus result = DF_ConfigurationController.getConfigurationStatus();
        Test.stopTest();

        Assert.isFalse(result.isRecordLimitConfigured, 'Record limit should not be configured.');
        Assert.isNull(result.recordLimit, 'Record limit should be null.');
        Assert.isFalse(result.isReady, 'Configuration should not be ready.');
    }

    @IsTest
    static void testGetConfigurationStatus_returnsConfigured_whenRecordLimitExists() {

        insert new Duplicate_Finder_Setting__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Record_Limit__c = 100
        );

        Test.startTest();
        DF_ConfigurationController.ConfigurationStatus result = DF_ConfigurationController.getConfigurationStatus();
        Test.stopTest();

        Assert.isTrue(result.isRecordLimitConfigured, 'Record limit should be configured.');
        Assert.areEqual(100, result.recordLimit, 'Record limit should match the configured value.');
    }
}