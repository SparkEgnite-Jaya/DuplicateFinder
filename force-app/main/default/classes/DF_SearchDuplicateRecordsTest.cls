@IsTest
public class DF_SearchDuplicateRecordsTest {
    
    @TestSetup
    static void createTestData() {
        
        INSERT new List<Account>{
               new Account(Name = 'Duplicate Account', Phone = '1111111111', Active__c = 'true'),
               new Account(Name = 'Duplicate Account', Phone = '1111111111', Active__c = 'true'),
               new Account(Name = 'Unique Account', Phone = '2222222222', Active__c = 'false'),
               new Account(Name = 'Null Active Account', Phone = '3333333333'),
               new Account(Name = 'Null Active Account', Phone = '3333333333')
        };
   }
    
    @IsTest
    static void findDuplicates_ReturnsDuplicateRecords_WhenMatchingRecordsExist() {
        
        Account sourceRecord = [SELECT Id FROM Account WHERE Name = 'Duplicate Account' LIMIT 1];
        
        DF_SearchDuplicateRecords.DuplicateSearchInput duplicateSearchInput = new DF_SearchDuplicateRecords.DuplicateSearchInput();
        duplicateSearchInput.objectName = 'Account';
        duplicateSearchInput.recordId = sourceRecord.Id;
        duplicateSearchInput.fieldNames = new List<String>{'Name','Phone'};
            
        Test.startTest();
        List<DF_SearchDuplicateRecords.DuplicateSearchOutput> duplicateSearchOutput = DF_SearchDuplicateRecords.findDuplicates(new List<DF_SearchDuplicateRecords.DuplicateSearchInput>{duplicateSearchInput});
        Test.stopTest();
        
        System.assertEquals(true, duplicateSearchOutput[0].success);
        System.assert(duplicateSearchOutput[0].duplicateCount > 1);
        System.assertNotEquals(null, duplicateSearchOutput[0].duplicateRecords);
        System.assertEquals(duplicateSearchOutput[0].duplicateCount, duplicateSearchOutput[0].duplicateRecords.lstDuplicateRecordInfo.size());
    }
    
    @IsTest
    static void findDuplicates_ReturnsNoDuplicateMessage_WhenOnlyOneRecordMatches() {
        
        Account sourceRecord = [SELECT Id FROM Account WHERE Name = 'Unique Account' LIMIT 1];
        
        DF_SearchDuplicateRecords.DuplicateSearchInput duplicateSearchInput = new DF_SearchDuplicateRecords.DuplicateSearchInput();
        duplicateSearchInput.objectName = 'Account';
        duplicateSearchInput.recordId = sourceRecord.Id;
        duplicateSearchInput.fieldNames = new List<String>{'Name','Phone'};
            
        Test.startTest();
        List<DF_SearchDuplicateRecords.DuplicateSearchOutput> duplicateSearchOutput = DF_SearchDuplicateRecords.findDuplicates(new List<DF_SearchDuplicateRecords.DuplicateSearchInput>{duplicateSearchInput});
        Test.stopTest();
        
        System.assertEquals(true, duplicateSearchOutput[0].success);
        System.assertEquals('No duplicate records found.', duplicateSearchOutput[0].message);
        System.assertEquals(null, duplicateSearchOutput[0].duplicateRecords);
        System.assertEquals(1, duplicateSearchOutput[0].duplicateCount);
    }
    
    @IsTest
    static void findDuplicates_ReturnsDuplicateRecords_WhenMatchingNullFieldValuesExist() {
        
        Account sourceRecord = [SELECT Id FROM Account WHERE Name = 'Null Active Account' LIMIT 1];
        
        DF_SearchDuplicateRecords.DuplicateSearchInput duplicateSearchInput = new DF_SearchDuplicateRecords.DuplicateSearchInput();
        duplicateSearchInput.objectName = 'Account';
        duplicateSearchInput.recordId = sourceRecord.Id;
        duplicateSearchInput.fieldNames = new List<String>{'Active__c'};
            
        Test.startTest();
        List<DF_SearchDuplicateRecords.DuplicateSearchOutput> duplicateSearchOutput = DF_SearchDuplicateRecords.findDuplicates(new List<DF_SearchDuplicateRecords.DuplicateSearchInput>{duplicateSearchInput});
        Test.stopTest();
        
        System.assertEquals(true, duplicateSearchOutput[0].success);
        System.assert(duplicateSearchOutput[0].duplicateCount > 1);
    }
    
    @IsTest
    static void findDuplicates_ReturnsFailure_WhenInvalidObjectProvided() {
        
        DF_SearchDuplicateRecords.DuplicateSearchInput duplicateSearchInput = new DF_SearchDuplicateRecords.DuplicateSearchInput();
        duplicateSearchInput.objectName = 'InvalidObject';
        duplicateSearchInput.recordId = '001000000000000AAA';
        duplicateSearchInput.fieldNames = new List<String>{'Name'};
            
        Test.startTest();
        List<DF_SearchDuplicateRecords.DuplicateSearchOutput> duplicateSearchOutput = DF_SearchDuplicateRecords.findDuplicates(new List<DF_SearchDuplicateRecords.DuplicateSearchInput>{duplicateSearchInput});
        Test.stopTest();
        
        System.assertEquals(false, duplicateSearchOutput[0].success);
        System.assertNotEquals(null, duplicateSearchOutput[0].message);
    }
    
    @IsTest
    static void findDuplicates_ReturnsResults_WhenMultipleInputsProvided() {
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'Duplicate Account' LIMIT 2];
        
        DF_SearchDuplicateRecords.DuplicateSearchInput duplicateSearchInput1 = new DF_SearchDuplicateRecords.DuplicateSearchInput();
        duplicateSearchInput1.objectName = 'Account';
        duplicateSearchInput1.recordId = accounts[0].Id;
        duplicateSearchInput1.fieldNames = new List<String>{'Name'};
            
        DF_SearchDuplicateRecords.DuplicateSearchInput duplicateSearchInput2 = new DF_SearchDuplicateRecords.DuplicateSearchInput();
        duplicateSearchInput2.objectName = 'Account';
        duplicateSearchInput2.recordId = accounts[1].Id;
        duplicateSearchInput2.fieldNames = new List<String>{'Name'};
            
        Test.startTest();
        List<DF_SearchDuplicateRecords.DuplicateSearchOutput> duplicateSearchOutput = DF_SearchDuplicateRecords.findDuplicates(new List<DF_SearchDuplicateRecords.DuplicateSearchInput>{duplicateSearchInput1,duplicateSearchInput2});
        Test.stopTest();
        
        System.assertEquals(2, duplicateSearchOutput.size());
        System.assertEquals(true, duplicateSearchOutput[0].success);
        System.assertEquals(true, duplicateSearchOutput[1].success);
    }
    
    @IsTest
    static void findDuplicates_RespectsRecordLimit_WhenMoreThanFiveRecordsExist() {
        
        List<Account> accountsToInsert = new List<Account>();
        
        for(Integer i = 0; i < 10; i++) {
            accountsToInsert.add(new Account(Name = 'Limit Test', Phone = '9999999999'));
        }
        
        insert accountsToInsert;
        
        Account sourceRecord = [SELECT Id FROM Account WHERE Name = 'Limit Test' LIMIT 1];
        
        DF_SearchDuplicateRecords.DuplicateSearchInput duplicateSearchInput = new DF_SearchDuplicateRecords.DuplicateSearchInput();
        duplicateSearchInput.objectName = 'Account';
        duplicateSearchInput.recordId = sourceRecord.Id;
        duplicateSearchInput.fieldNames = new List<String>{'Name'};
            
        Test.startTest();
        List<DF_SearchDuplicateRecords.DuplicateSearchOutput> duplicateSearchOutput = DF_SearchDuplicateRecords.findDuplicates(new List<DF_SearchDuplicateRecords.DuplicateSearchInput>{duplicateSearchInput});
        Test.stopTest();
        
        System.assert(duplicateSearchOutput[0].duplicateCount <= 5);
    }
}