@IsTest
private class PrerequisitesComponentControllerTest {
    
    @IsTest
    static void testGetPrerequisitesStepStatus_returnsStepStatus_whenInvoked() {
        
        Test.startTest();
        PrerequisitesComponentController.PrerequisitesStatusWrapper result = PrerequisitesComponentController.getPrerequisitesStepStatus();
        Test.stopTest();
        
        Assert.isNotNull(result, 'The response wrapper should not be null.');
        Assert.isNotNull(result.isAgentActive, 'isAgentActive should be initialized.');
        Assert.isNotNull(result.isPermissionSetAssigned, 'isPermissionSetAssigned should be initialized.');
    }
}