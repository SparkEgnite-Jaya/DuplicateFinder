@IsTest
public class DF_DeleteOldCustomFieldHistoryBatchTest {
    
    @TestSetup
    static void setup() {
        Profile adminProfile = TestDataFactoryUser.getProfileByName('System Administrator');
        User adminUser = TestDataFactoryUser.createUser(adminProfile.Id);
    }

    @IsTest
    static void execute_itDeletesRecords_whenRecordsAreOlderThanSevenDays() {
        User adminUser = TestDataFactoryUser.getUserByProfileName('System Administrator');
        
        System.runAs(adminUser) {
            Account account = TestDataFactoryAccount.buildAccount('Test Account', '1111111111', 'true');
            INSERT account;
            
            Custom_Field_History_Tracking__c oldCustomFieldHistoryRecord = new Custom_Field_History_Tracking__c(Name = 'Account', Master_Record_Id__c = account.Id, Field_Name__c = 'Phone');
            Database.insert(oldCustomFieldHistoryRecord, true, AccessLevel.SYSTEM_MODE);
            
            Test.setCreatedDate(oldCustomFieldHistoryRecord.Id, System.now().addDays(-10));
            
            Test.startTest();
            Database.executeBatch(new DF_DeleteOldCustomFieldHistoryBatch(), 200);
            Test.stopTest();
            
            Integer customFieldHistoryTrackingRecordCount = getcustomFieldHistoryTrackingRecordCount(oldCustomFieldHistoryRecord.Id);
            
            Assert.areEqual(0, customFieldHistoryTrackingRecordCount);
        }
    }
    
    @IsTest
    static void execute_itDoesNotDeleteRecords_whenRecordsAreWithinSevenDays() {
        User adminUser = TestDataFactoryUser.getUserByProfileName('System Administrator');
        
        System.runAs(adminUser) {
            Account account = new Account(Name = 'Test Account');
            INSERT account;
            
            Custom_Field_History_Tracking__c recentCustomFieldHistoryRecord = new Custom_Field_History_Tracking__c(Name = 'Account', Master_Record_Id__c = account.Id, Field_Name__c = 'Phone');
            Database.insert(recentCustomFieldHistoryRecord, true, AccessLevel.SYSTEM_MODE);
            
            Test.startTest();
            Database.executeBatch(new DF_DeleteOldCustomFieldHistoryBatch(), 200);
            Test.stopTest();
            
            Integer customFieldHistoryTrackingRecordCount = getcustomFieldHistoryTrackingRecordCount(recentCustomFieldHistoryRecord.Id);
            
            Assert.areEqual(1, customFieldHistoryTrackingRecordCount);
        }
    }
    
    private static Integer getcustomFieldHistoryTrackingRecordCount(String customFieldHistoryTrackingRecordId) {
        return [SELECT Count() 
                FROM Custom_Field_History_Tracking__c 
                WHERE Id =: customFieldHistoryTrackingRecordId];
    }
    
    private static User getAdminUser() {
        return [SELECT Id
                FROM User
                WHERE Alias = 'tadmin'
                LIMIT 1];
    }
}