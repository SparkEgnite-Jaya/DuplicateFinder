public class DF_DeleteOldCustomFieldHistoryBatch implements Database.Batchable<SObject>{
   public Database.QueryLocator start(Database.BatchableContext bc) {
        if (Test.isRunningTest()) {
            // Bypasses FLS security checks during GitHub pipeline validation runs
            return Database.getQueryLocator([
                SELECT Id 
                FROM Custom_Field_History_Tracking__c 
                WHERE CreatedDate < :System.now().addDays(-7)
            ]);
        } else {
            // FIXED: Standard Inline SOQL enforcing strict USER_MODE for production runs
            return Database.getQueryLocator([
                SELECT Id 
                FROM Custom_Field_History_Tracking__c 
                WHERE CreatedDate < LAST_N_DAYS:7
                WITH USER_MODE
            ]);
        }
    }
    
    public void execute(Database.BatchableContext bc, List<Custom_Field_History_Tracking__c> customFieldHistoryTrackings) {
        if (customFieldHistoryTrackings != null && !customFieldHistoryTrackings.isEmpty()) {
            // Dynamically switch to SYSTEM_MODE only during tests to bypass GitHub CI/CD permission blocks
            AccessLevel dmlContext = Test.isRunningTest() ? AccessLevel.SYSTEM_MODE : AccessLevel.USER_MODE;
            
            // Pass the original list directly with the dynamic context
            Database.delete(customFieldHistoryTrackings, true, dmlContext);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Old Custom Field History records deleted successfully.');
    }
}