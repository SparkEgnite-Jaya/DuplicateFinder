@IsTest
public class DF_DeleteOldCustomFieldHistoryBatchTest {
    
    @IsTest
    static void execute_DeletesRecords_WhenRecordsAreOlderThanSevenDays() {
        
        Account account = new Account(Name = 'Test Account');
        INSERT account;
        
        Custom_Field_History_Tracking__c oldCustomFieldHistoryRecord = new Custom_Field_History_Tracking__c(Name = 'Account',Master_Record_Id__c = account.Id,Field_Name__c = 'Phone');
        INSERT oldCustomFieldHistoryRecord;
        
        Test.setCreatedDate(oldCustomFieldHistoryRecord.Id, System.now().addDays(-10));
        
        Test.startTest();
        Database.executeBatch(new DF_DeleteOldCustomFieldHistoryBatch(), 200);
        Test.stopTest();
        
        System.assertEquals(0,[SELECT Count() FROM Custom_Field_History_Tracking__c WHERE Id = :oldCustomFieldHistoryRecord.Id]);
    }
    
    @IsTest
    static void execute_DoesNotDeleteRecords_WhenRecordsAreWithinSevenDays() {
        
        Account account = new Account(Name = 'Test Account');
        Insert account;
        
        Custom_Field_History_Tracking__c recentCustomFieldHistoryRecord = new Custom_Field_History_Tracking__c(Name = 'Account',Master_Record_Id__c = account.Id,Field_Name__c = 'Phone');
        Insert recentCustomFieldHistoryRecord;
        
        Test.startTest();
        Database.executeBatch(new DF_DeleteOldCustomFieldHistoryBatch(), 200);
        Test.stopTest();
        
        System.assertEquals(1,[SELECT Count() FROM Custom_Field_History_Tracking__c WHERE Id = :recentCustomFieldHistoryRecord.Id] );
    }
}