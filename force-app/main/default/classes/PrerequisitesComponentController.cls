public class PrerequisitesComponentController {
    
    public class PrerequisitesStatusWrapper {
        @AuraEnabled public Boolean isAgentActive;
        @AuraEnabled public Boolean isPermissionSetAssigned;
    }
    
    @AuraEnabled(cacheable=true)
    public static PrerequisitesStatusWrapper getPrerequisitesStepStatus() {
        
        PrerequisitesStatusWrapper response = new PrerequisitesStatusWrapper();
        
        response.isAgentActive = ![ SELECT Id
                                    FROM BotVersion
                                    WHERE Status = 'Active'
                                    AND BotDefinition.DeveloperName = 'Duplicate_Finder_Employee_Agent'
                                    LIMIT 1 ].isEmpty();
        
        response.isPermissionSetAssigned = [ SELECT COUNT()
                                             FROM PermissionSetAssignment
                                             WHERE AssigneeId = :UserInfo.getUserId()
                                             AND PermissionSet.Name = 'Custom_Agent_PS'
                                        	] > 0;
        
        return response;
    }
    
}