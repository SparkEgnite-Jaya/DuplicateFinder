@IsTest
private class DuplicateFinderWizardSetupControllerTest {

    @IsTest
    static void testGetAgentId_returnsAgentId_whenDuplicateFinderAgentExists() {

        Test.startTest();
        String agentId = DuplicateFinderWizardSetupController.getAgentId('Duplicate_Finder_Employee_Agent');
        Test.stopTest();

        Assert.isNotNull(agentId, 'Agent Id should not be null.');
    }
}