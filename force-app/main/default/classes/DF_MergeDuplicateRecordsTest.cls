@IsTest
private class DF_MergeDuplicateRecordsTest {
    
    @TestSetup
    static void createTestData() {
        INSERT new List<Account>{
            new Account( Name = 'Master Account', Phone = null, Website = null ),
            new Account( Name = 'Duplicate 1', Phone = '9876543210', Website = 'www.test1.com' ),
            new Account( Name = 'Duplicate 2', Phone = '9999999999', Website = 'www.test2.com' )
        };
    }
    
    @IsTest
    static void mergeDuplicates_UpdatesMasterRecord_WhenDuplicateContainsValues() {
        
        List<Account> accounts = [SELECT Id, Phone, Website FROM Account ORDER BY CreatedDate ASC];
        
        Account masterAcc = accounts[0];
        Account duplicateAccount1 = accounts[1];
        Account duplicateAccount2 = accounts[2];
        
        DF_MergeDuplicateRecords.MergeDuplicateInput mergeDuplicateInput = new DF_MergeDuplicateRecords.MergeDuplicateInput();
        mergeDuplicateInput.objectName = 'Account';
        mergeDuplicateInput.masterId = masterAcc.Id;
        mergeDuplicateInput.duplicateIds = new List<Id>{duplicateAccount1.Id, duplicateAccount2.Id};
            
        Test.startTest();
        List<DF_MergeDuplicateRecords.MergeDuplicateOutput> mergeDuplicateOutput = DF_MergeDuplicateRecords.mergeDuplicates(new List<DF_MergeDuplicateRecords.MergeDuplicateInput>{mergeDuplicateInput});
        Test.stopTest();
        
        Account updatedMaster = [SELECT Id, Phone, Website FROM Account WHERE Id = :masterAcc.Id];
        
        System.assertEquals('9876543210', updatedMaster.Phone);
        System.assertEquals('www.test1.com', updatedMaster.Website);
        System.assertEquals(masterAcc.Id, mergeDuplicateOutput[0].masterRecordId);
        System.assertEquals('Master Record Updated Successfully', mergeDuplicateOutput[0].message);
    }
    
    @IsTest
    static void mergeDuplicates_CreatesHistoryRecords_WhenMasterFieldsAreUpdated() {
        
        Account masterAccount = [SELECT Id FROM Account WHERE Name = 'Master Account' LIMIT 1];
        List<Account> duplicateRecords = [SELECT Id FROM Account WHERE Name LIKE 'Duplicate%'];
        
        DF_MergeDuplicateRecords.MergeDuplicateInput mergeDuplicateInput = new DF_MergeDuplicateRecords.MergeDuplicateInput();
        mergeDuplicateInput.objectName = 'Account';
        mergeDuplicateInput.masterId = masterAccount.Id;
        mergeDuplicateInput.duplicateIds = new List<Id>{duplicateRecords[0].Id, duplicateRecords[1].Id};
            
        Test.startTest();
        DF_MergeDuplicateRecords.mergeDuplicates(new List<DF_MergeDuplicateRecords.MergeDuplicateInput>{mergeDuplicateInput});
        Test.stopTest();
        
        List<Custom_Field_History_Tracking__c> historyRecords = [SELECT Id, Field_Name__c, Master_Record_Id__c
                                                                 FROM Custom_Field_History_Tracking__c
                                                                 WHERE Master_Record_Id__c = :masterAccount.Id];
        
        System.assert(historyRecords.size() > 0);
    }
    
    @IsTest
    static void mergeDuplicates_DeletesDuplicateRecords_WhenMergeCompletesSuccessfully() {
        
        Account masterAcc = [SELECT Id FROM Account WHERE Name = 'Master Account' LIMIT 1];
        List<Account> duplicateRecords = [SELECT Id FROM Account WHERE Name LIKE 'Duplicate%'];
        
        DF_MergeDuplicateRecords.MergeDuplicateInput mergeDuplicateInput = new DF_MergeDuplicateRecords.MergeDuplicateInput();
        mergeDuplicateInput.objectName = 'Account';
        mergeDuplicateInput.masterId = masterAcc.Id;
        mergeDuplicateInput.duplicateIds = new List<Id>{duplicateRecords[0].Id, duplicateRecords[1].Id};
            
        Test.startTest();
        DF_MergeDuplicateRecords.mergeDuplicates(new List<DF_MergeDuplicateRecords.MergeDuplicateInput>{mergeDuplicateInput});
        Test.stopTest();
        
        Integer duplicateRecordCount = [SELECT Count() FROM Account WHERE Id IN :new List<Id>{duplicateRecords[0].Id, duplicateRecords[1].Id}];
        
        System.assertEquals(0, duplicateRecordCount);
    }
    
    @IsTest
    static void mergeDuplicates_IgnoresMasterId_WhenMasterIdExistsInDuplicateIds() {
        
        List<Account> accounts = [SELECT Id FROM Account ORDER BY CreatedDate ASC];
        
        Account masterAccount = accounts[0];
        Account duplicateAccount = accounts[1];
        
        DF_MergeDuplicateRecords.MergeDuplicateInput mergeDuplicateInput = new DF_MergeDuplicateRecords.MergeDuplicateInput();
        mergeDuplicateInput.objectName = 'Account';
        mergeDuplicateInput.masterId = masterAccount.Id;
        mergeDuplicateInput.duplicateIds = new List<Id>{masterAccount.Id, duplicateAccount.Id};
            
        Test.startTest();
        List<DF_MergeDuplicateRecords.MergeDuplicateOutput> mergeDuplicateOutput = DF_MergeDuplicateRecords.mergeDuplicates(new List<DF_MergeDuplicateRecords.MergeDuplicateInput>{mergeDuplicateInput});
        Test.stopTest();
        
        System.assertEquals(masterAccount.Id, mergeDuplicateOutput[0].masterRecordId);
    }
    
    @IsTest
    static void mergeDuplicates_DoesNotCreateHistoryRecords_WhenMasterAlreadyContainsValues() {
        
        Account masterAccount = new Account( Name = 'Filled Master', Phone = '1111111111', Website = 'www.master.com' );
        Account duplicateAccount = new Account( Name = 'Filled Duplicate', Phone = '2222222222', Website = 'www.duplicate.com' );
        INSERT new List<Account>{masterAccount, duplicateAccount};
            
        DF_MergeDuplicateRecords.MergeDuplicateInput mergeDuplicateInput = new DF_MergeDuplicateRecords.MergeDuplicateInput();
        mergeDuplicateInput.objectName = 'Account';
        mergeDuplicateInput.masterId = masterAccount.Id;
        mergeDuplicateInput.duplicateIds = new List<Id>{duplicateAccount.Id};
            
        Test.startTest();
        DF_MergeDuplicateRecords.mergeDuplicates(new List<DF_MergeDuplicateRecords.MergeDuplicateInput>{mergeDuplicateInput});
        Test.stopTest();
        
        List<Custom_Field_History_Tracking__c> lstCustomFieldHistoryRecord = [SELECT Id
                                                                              FROM Custom_Field_History_Tracking__c
                                                                              WHERE Master_Record_Id__c = :masterAccount.Id];
        
        System.assertEquals(0, lstCustomFieldHistoryRecord.size());
    }
}