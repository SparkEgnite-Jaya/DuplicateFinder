@IsTest
private class PrerequisitesComponentControllerTest {
    
    @IsTest
    static void testGetPrerequisitesStepStatus_returnsStepStatus_whenInvoked() {
        
        Test.startTest();
        PrerequisitesComponentController.PrerequisitesStatusWrapper result = PrerequisitesComponentController.getPrerequisitesStepStatus();
        Test.stopTest();
        
        Assert.isTrue(result.isAgentActive);
        Assert.isTrue(result.isPermissionSetAssigned);
    }
}