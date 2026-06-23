@IsTest
public class DF_SearchDuplicateRecordsTest {
    
    @TestSetup
    static void createTestData() {        
        INSERT new List<Account>{
            TestDataFactoryAccount.buildAccount('Duplicate Account','1111111111','true'),
            TestDataFactoryAccount.buildAccount('Duplicate Account','1111111111','true'),
            TestDataFactoryAccount.buildAccount('Unique Account','2222222222','false'),
            TestDataFactoryAccount.buildAccount('Null Active Account','3333333333',null),
            TestDataFactoryAccount.buildAccount('Null Active Account','3333333333',null)   
        };
   }
    
    @IsTest
    static void findDuplicates_itReturnsDuplicateRecords_whenMatchingRecordsExist() {
        List<Account> sourceRecords = TestDataFactoryAccount.getAccountByName('Duplicate Account');
        
        DF_SearchDuplicateRecords.DuplicateSearchInput duplicateSearchInput = new DF_SearchDuplicateRecords.DuplicateSearchInput();
        duplicateSearchInput.objectName = 'Account';
        duplicateSearchInput.recordId = sourceRecords[0].Id;
        duplicateSearchInput.fieldNames = new List<String>{'Name','Phone'};
            
        Test.startTest();
        List<DF_SearchDuplicateRecords.DuplicateSearchOutput> duplicateSearchOutput = DF_SearchDuplicateRecords.findDuplicates(new List<DF_SearchDuplicateRecords.DuplicateSearchInput>{duplicateSearchInput});
        Test.stopTest();
        
        Assert.isTrue(duplicateSearchOutput[0].success);
        Assert.isTrue(duplicateSearchOutput[0].duplicateCount > 1);
        Assert.isNotNull(duplicateSearchOutput[0].duplicateRecords);
        Assert.areEqual(duplicateSearchOutput[0].duplicateCount, duplicateSearchOutput[0].duplicateRecords.lstDuplicateRecordInfo.size());
    }
    
    @IsTest
    static void findDuplicates_itReturnsNoDuplicateMessage_whenOnlyOneRecordMatches() {
        List<Account> sourceRecords = TestDataFactoryAccount.getAccountByName('Unique Account');
        
        DF_SearchDuplicateRecords.DuplicateSearchInput duplicateSearchInput = new DF_SearchDuplicateRecords.DuplicateSearchInput();
        duplicateSearchInput.objectName = 'Account';
        duplicateSearchInput.recordId = sourceRecords[0].Id;
        duplicateSearchInput.fieldNames = new List<String>{'Name','Phone'};
            
        Test.startTest();
        List<DF_SearchDuplicateRecords.DuplicateSearchOutput> duplicateSearchOutput = DF_SearchDuplicateRecords.findDuplicates(new List<DF_SearchDuplicateRecords.DuplicateSearchInput>{duplicateSearchInput});
        Test.stopTest();
        
        Assert.isTrue(duplicateSearchOutput[0].success);
        Assert.areEqual('No duplicate records found.', duplicateSearchOutput[0].message);
        Assert.isNull(duplicateSearchOutput[0].duplicateRecords);
        Assert.areEqual(1, duplicateSearchOutput[0].duplicateCount);
    }
    
    @IsTest
    static void findDuplicates_itReturnsDuplicateRecords_whenMatchingNullFieldValuesExist() {
        List<Account> sourceRecords = TestDataFactoryAccount.getAccountByName('Null Active Account');

        DF_SearchDuplicateRecords.DuplicateSearchInput duplicateSearchInput = new DF_SearchDuplicateRecords.DuplicateSearchInput();
        duplicateSearchInput.objectName = 'Account';
        duplicateSearchInput.recordId = sourceRecords[0].Id;
        duplicateSearchInput.fieldNames = new List<String>{'Active__c'};
            
        Test.startTest();
        List<DF_SearchDuplicateRecords.DuplicateSearchOutput> duplicateSearchOutput = DF_SearchDuplicateRecords.findDuplicates(new List<DF_SearchDuplicateRecords.DuplicateSearchInput>{duplicateSearchInput});
        Test.stopTest();
        
        Assert.isTrue(duplicateSearchOutput[0].success);
        Assert.isTrue(duplicateSearchOutput[0].duplicateCount > 1);
    }
    
    @IsTest
    static void findDuplicates_itReturnsFailure_whenInvalidObjectProvided() {
        DF_SearchDuplicateRecords.DuplicateSearchInput duplicateSearchInput = new DF_SearchDuplicateRecords.DuplicateSearchInput();
        duplicateSearchInput.objectName = 'InvalidObject';
        duplicateSearchInput.recordId = '001000000000000AAA';
        duplicateSearchInput.fieldNames = new List<String>{'Name'};
            
        Test.startTest();
        List<DF_SearchDuplicateRecords.DuplicateSearchOutput> duplicateSearchOutput = DF_SearchDuplicateRecords.findDuplicates(new List<DF_SearchDuplicateRecords.DuplicateSearchInput>{duplicateSearchInput});
        Test.stopTest();
        
        Assert.isFalse(duplicateSearchOutput[0].success);
        Assert.isNotNull(duplicateSearchOutput[0].message);
    }
    
    @IsTest
    static void findDuplicates_itReturnsResults_whenMultipleInputsProvided() {
        List<Account> sourceRecords = TestDataFactoryAccount.getAccountByName('Duplicate Account');
        
        DF_SearchDuplicateRecords.DuplicateSearchInput firstDuplicateSearchInput  = new DF_SearchDuplicateRecords.DuplicateSearchInput();
        firstDuplicateSearchInput.objectName = 'Account';
        firstDuplicateSearchInput.recordId = sourceRecords[0].Id;
        firstDuplicateSearchInput.fieldNames = new List<String>{'Name'};
            
        DF_SearchDuplicateRecords.DuplicateSearchInput secondDuplicateSearchInput = new DF_SearchDuplicateRecords.DuplicateSearchInput();
        secondDuplicateSearchInput.objectName = 'Account';
        secondDuplicateSearchInput.recordId = sourceRecords[1].Id;
        secondDuplicateSearchInput.fieldNames = new List<String>{'Name'};
            
        Test.startTest();
        List<DF_SearchDuplicateRecords.DuplicateSearchOutput> duplicateSearchOutput = DF_SearchDuplicateRecords.findDuplicates(new List<DF_SearchDuplicateRecords.DuplicateSearchInput>{firstDuplicateSearchInput,secondDuplicateSearchInput});
        Test.stopTest();
        
        Assert.areEqual(2, duplicateSearchOutput.size());
        Assert.isTrue(duplicateSearchOutput[0].success);
        Assert.isTrue(duplicateSearchOutput[1].success);
    }
    
    @IsTest
    static void findDuplicates_itRespectsRecordLimit_whenMoreThanFiveRecordsExist() {
        List<Account> accountsToInsert = new List<Account>();
        for(Integer i = 0; i < 10; i++) {
           accountsToInsert.add(TestDataFactoryAccount.buildAccount('Limit Test','9999999999',null));
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
        
        Assert.isTrue(duplicateSearchOutput[0].duplicateCount <= 5);
    }
}