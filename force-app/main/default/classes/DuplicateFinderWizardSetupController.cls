public with sharing class DuplicateFinderWizardSetupController {
    @AuraEnabled(cacheable=true)
    public static String getAgentId(String developerName) {
        BotDefinition bot = [SELECT Id FROM BotDefinition WHERE DeveloperName = :developerName LIMIT 1];
        return bot.Id;
    }
}