@IsTest
private class PrerequisitesComponentControllerTest {
    
    @IsTest
    static void testGetPrerequisitesStepStatus_returnsStepStatus_whenInvoked() {
        
        Test.startTest();
        Map<String, Boolean> result = PrerequisitesComponentController.getPrerequisitesStepStatus();
        Test.stopTest();
        
        Assert.isTrue(result.containsKey('isAgentActive'));
        Assert.isTrue(result.containsKey('isPermissionSetAssigned'));
    }
}