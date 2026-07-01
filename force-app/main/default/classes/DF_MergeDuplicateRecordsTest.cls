@IsTest
private class DF_MergeDuplicateRecordsTest {
    
    @TestSetup
    static void createTestData() {
        Profile adminProfile = TestDataFatoryUser.getProfileByName('System Administrator');
        User adminUser = TestDataFatoryUser.createUser(adminProfile.Id);
        
        System.runAs(adminUser) {
            INSERT new List<Account>{
                TestDataFactoryAccount.buildAccount('Master Account', null, null),
                TestDataFactoryAccount.buildAccount('Duplicate 1', '9876543210', null, 'www.test1.com'),
                TestDataFactoryAccount.buildAccount('Duplicate 2', '9999999999', null, 'www.test2.com') 
            };
       }
    }
    
    @IsTest
    static void mergeDuplicates_itUpdatesMasterRecord_whenDuplicateContainsValues() {
        User adminUser = TestDataFatoryUser.getUserByProfileName('System Administrator');
        
        System.runAs(adminUser) {
            List<Account> accounts = TestDataFactoryAccount.getAll();
            
            Account masterAccount = accounts[0];
            Account firstDuplicateRecord = accounts[1];
            Account secondDuplicateRecord = accounts[2];
            
            DF_MergeDuplicateRecords.MergeDuplicateInput mergeDuplicateInput = new DF_MergeDuplicateRecords.MergeDuplicateInput();
            mergeDuplicateInput.objectName = 'Account';
            mergeDuplicateInput.masterId = masterAccount.Id;
            mergeDuplicateInput.duplicateIds = new List<Id>{firstDuplicateRecord.Id, secondDuplicateRecord.Id};
                
            Test.startTest();
            List<DF_MergeDuplicateRecords.MergeDuplicateOutput> mergeDuplicateOutput = DF_MergeDuplicateRecords.mergeDuplicates(new List<DF_MergeDuplicateRecords.MergeDuplicateInput>{mergeDuplicateInput});
            Test.stopTest();
            
            Account updatedMaster = TestDataFactoryAccount.getAccountById(masterAccount.Id);
            
            Assert.areEqual('9876543210', updatedMaster.Phone);
            Assert.areEqual('www.test1.com', updatedMaster.Website);
            Assert.isFalse(mergeDuplicateOutput.isEmpty());
            Assert.areEqual(masterAccount.Id, mergeDuplicateOutput[0].masterRecordId);
            Assert.areEqual('Master Record Updated Successfully', mergeDuplicateOutput[0].message);
        }
    }
    
    @IsTest
    static void mergeDuplicates_itCreatesHistoryRecords_whenMasterFieldsAreUpdated() {
        User adminUser = TestDataFatoryUser.getUserByProfileName('System Administrator');
        
        System.runAs(adminUser) {
            List<Account> masterAccounts =  TestDataFactoryAccount.getAccountByName('Master Account');
            List<Account> duplicateRecords = getAccountsByNameLike('Duplicate%');
            
            DF_MergeDuplicateRecords.MergeDuplicateInput mergeDuplicateInput = new DF_MergeDuplicateRecords.MergeDuplicateInput();
            mergeDuplicateInput.objectName = 'Account';
            mergeDuplicateInput.masterId = masterAccounts[0].Id;
            mergeDuplicateInput.duplicateIds = new List<Id>{duplicateRecords[0].Id, duplicateRecords[1].Id};
                
            Test.startTest();
            DF_MergeDuplicateRecords.mergeDuplicates(new List<DF_MergeDuplicateRecords.MergeDuplicateInput>{mergeDuplicateInput});
            Test.stopTest();
            
            List<Custom_Field_History_Tracking__c> historyRecords = getCustomFieldHistoryRecordsByAccountId(masterAccounts[0].Id);
            
            Assert.isTrue(historyRecords.size() > 0);    
        }
    }
    
    @IsTest
    static void mergeDuplicates_itDeletesDuplicateRecords_whenMergeCompletesSuccessfully() {
        User adminUser = TestDataFatoryUser.getUserByProfileName('System Administrator');
        
        System.runAs(adminUser) {
            List<Account> masterAccounts =  TestDataFactoryAccount.getAccountByName('Master Account');
            List<Account> duplicateRecords = getAccountsByNameLike('Duplicate%'); 
            
            DF_MergeDuplicateRecords.MergeDuplicateInput mergeDuplicateInput = new DF_MergeDuplicateRecords.MergeDuplicateInput();
            mergeDuplicateInput.objectName = 'Account';
            mergeDuplicateInput.masterId = masterAccounts[0].Id;
            mergeDuplicateInput.duplicateIds = new List<Id>{duplicateRecords[0].Id, duplicateRecords[1].Id};
                
            Test.startTest();
            DF_MergeDuplicateRecords.mergeDuplicates(new List<DF_MergeDuplicateRecords.MergeDuplicateInput>{mergeDuplicateInput});
            Test.stopTest();
            
            Integer duplicateRecordCount = getAccountCount(new List<Id>{duplicateRecords[0].Id, duplicateRecords[1].Id});
            
            Assert.areEqual(0, duplicateRecordCount);
        }
    }
    
    @IsTest
    static void mergeDuplicates_itIgnoresMasterId_whenMasterIdExistsInDuplicateIds() {
        User adminUser = TestDataFatoryUser.getUserByProfileName('System Administrator');
        
        System.runAs(adminUser) {
            List<Account> accounts = TestDataFactoryAccount.getAll();
            
            Account masterAccount = accounts[0];
            Account duplicateAccount = accounts[1];
            
            DF_MergeDuplicateRecords.MergeDuplicateInput mergeDuplicateInput = new DF_MergeDuplicateRecords.MergeDuplicateInput();
            mergeDuplicateInput.objectName = 'Account';
            mergeDuplicateInput.masterId = masterAccount.Id;
            mergeDuplicateInput.duplicateIds = new List<Id>{masterAccount.Id, duplicateAccount.Id};
                
            Test.startTest();
            List<DF_MergeDuplicateRecords.MergeDuplicateOutput> mergeDuplicateOutput = DF_MergeDuplicateRecords.mergeDuplicates(new List<DF_MergeDuplicateRecords.MergeDuplicateInput>{mergeDuplicateInput});
            Test.stopTest();
            
            Assert.isFalse(mergeDuplicateOutput.isEmpty());
            Assert.areEqual(masterAccount.Id, mergeDuplicateOutput[0].masterRecordId);
        }
    }
    
    @IsTest
    static void mergeDuplicates_itDoesNotCreateHistoryRecords_whenMasterAlreadyContainsValues() {
        User adminUser = TestDataFatoryUser.getUserByProfileName('System Administrator');
        
        System.runAs(adminUser) {
            List<Account> accounts = new List<Account>{
                TestDataFactoryAccount.buildAccount('Filled Master', '1111111111', null, 'www.master.com'),
                TestDataFactoryAccount.buildAccount('Filled Duplicate', '2222222222', null, 'www.duplicate.com')
            };
            INSERT accounts;
            
            DF_MergeDuplicateRecords.MergeDuplicateInput mergeDuplicateInput = new DF_MergeDuplicateRecords.MergeDuplicateInput();
            mergeDuplicateInput.objectName = 'Account';
            mergeDuplicateInput.masterId = accounts[0].Id;
            mergeDuplicateInput.duplicateIds = new List<Id>{accounts[1].Id};
                
            Test.startTest();
            DF_MergeDuplicateRecords.mergeDuplicates(new List<DF_MergeDuplicateRecords.MergeDuplicateInput>{mergeDuplicateInput});
            Test.stopTest();
            
            List<Custom_Field_History_Tracking__c> customFieldHistoryRecords = getCustomFieldHistoryRecordsByAccountId(accounts[0].Id);
            
            Assert.areEqual(0, customFieldHistoryRecords.size());
        }
    }
    
    private static List<Account> getAccountsByNameLike(String namePattern) {
        return [SELECT Id, Name, Phone, Website
                FROM Account
                WHERE Name LIKE : namePattern];
    }
    
    private static List<Custom_Field_History_Tracking__c> getCustomFieldHistoryRecordsByAccountId(String masterAccountId) {
        return [SELECT Id
                FROM Custom_Field_History_Tracking__c
                WHERE Master_Record_Id__c = : masterAccountId];
    }
    
    private static Integer getAccountCount(List<Id> duplicateRecordIds) {
        return [SELECT Count() 
                FROM Account 
                WHERE Id IN : duplicateRecordIds];
    }
   
}