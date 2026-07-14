public with sharing class DuplicateFinderWizardSetupController {
    
    @AuraEnabled(cacheable=true)
    public static String getAgentId(String developerName) {
        List<BotDefinition> bots = [SELECT Id
                                    FROM BotDefinition
                                    WHERE DeveloperName = :developerName
                                    LIMIT 1];
        
        return bots.isEmpty() ? null : bots[0].Id;
    }
}