public class DF_DeleteOldCustomFieldHistoryBatch implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id ' +
                                        'FROM Custom_Field_History_Tracking__c ' +
                                        'WHERE CreatedDate < LAST_N_DAYS:7'
                                       );
    }
    
    public void execute(Database.BatchableContext bc, List<Custom_Field_History_Tracking__c> customFieldHistoryTrackings) {
        if(!customFieldHistoryTrackings.isEmpty()) {
            DELETE customFieldHistoryTrackings ;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Old Custom Field History records deleted successfully.');
    }
}