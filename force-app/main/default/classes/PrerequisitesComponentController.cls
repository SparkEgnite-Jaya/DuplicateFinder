public class PrerequisitesComponentController {

    @AuraEnabled(cacheable=true)
    public static Map<String,boolean> getPrerequisitesStepStatus() {
        Map<String,boolean> stepStatus = new Map<String,boolean>();

        // Check if the Duplicate Finder Agent is active
        Boolean isAgentActive = ![SELECT Id
                                    FROM BotVersion
                                    WHERE Status = 'Active'
                                    AND BotDefinition.DeveloperName = 'Duplicate_Finder_Employee_Agent'
                                    LIMIT 1 ].isEmpty();

        stepStatus.put('isAgentActive', isAgentActive);

        // Check if the Permission Set is assigned to the current user
        Boolean isPermissionSetAssigned = [ SELECT COUNT() 
                                            FROM PermissionSetAssignment 
                                            WHERE AssigneeId = :UserInfo.getUserId() 
                                            AND PermissionSet.Name = 'Custom_Agent_PS'
                                          ] > 0;
        stepStatus.put('isPermissionSetAssigned', isPermissionSetAssigned);

        return stepStatus;
    }
    
}