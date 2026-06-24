@IsTest
private class DF_FieldValidatorTest {
    
    @IsTest
    static void validateFields_itReturnsSuccess_whenAllConfiguredFieldsAreSupported() {
        DF_FieldValidator.testDataFields = new List<String>{'Name', 'Phone'};
            
        DF_FieldValidator.FieldValidatorInputWrapper fieldValidatorInputWrapper = new DF_FieldValidator.FieldValidatorInputWrapper();
        fieldValidatorInputWrapper.entityType = 'Account';
        
        Test.startTest();
        List<DF_FieldValidator.FieldValidatorOutputWrapper> fieldValidatorOutputWrapper = DF_FieldValidator.validateFields(new List<DF_FieldValidator.FieldValidatorInputWrapper>{fieldValidatorInputWrapper});
        Test.stopTest();
        
        Assert.isFalse(fieldValidatorOutputWrapper.isEmpty());
        Assert.areEqual(1, fieldValidatorOutputWrapper.size());
        Assert.isTrue(fieldValidatorOutputWrapper[0].success);
        Assert.areEqual(2, fieldValidatorOutputWrapper[0].supportedFields.size());
        Assert.areEqual(0, fieldValidatorOutputWrapper[0].unsupportedFields.size());
    }

    @IsTest
    static void validateFields_itReturnsSupportedAndUnsupportedFields_whenInvalidFieldExists() {
        DF_FieldValidator.testDataFields = new List<String>{'Name', 'Invalid_Field__c'};

        DF_FieldValidator.FieldValidatorInputWrapper fieldValidatorInputWrapper = new DF_FieldValidator.FieldValidatorInputWrapper();
        fieldValidatorInputWrapper.entityType = 'Account';

        Test.startTest();
        List<DF_FieldValidator.FieldValidatorOutputWrapper> fieldValidatorOutputWrapper = DF_FieldValidator.validateFields(new List<DF_FieldValidator.FieldValidatorInputWrapper>{fieldValidatorInputWrapper});
		Test.stopTest();
        
        Assert.isFalse(fieldValidatorOutputWrapper.isEmpty());
        Assert.isFalse(fieldValidatorOutputWrapper[0].success);
        Assert.areEqual(1, fieldValidatorOutputWrapper[0].supportedFields.size());
        Assert.areEqual(1, fieldValidatorOutputWrapper[0].unsupportedFields.size());
        Assert.isTrue(fieldValidatorOutputWrapper[0].unsupportedFields.contains('Invalid_Field__c'));
    }

    @IsTest
    static void validateFields_itReturnsFailure_whenNoConfiguredFieldsExist() {
        DF_FieldValidator.testDataFields = new List<String>();

        DF_FieldValidator.FieldValidatorInputWrapper fieldValidatorInputWrapper = new DF_FieldValidator.FieldValidatorInputWrapper();
        fieldValidatorInputWrapper.entityType = 'Account';

        Test.startTest();
        List<DF_FieldValidator.FieldValidatorOutputWrapper> fieldValidatorOutputWrapper = DF_FieldValidator.validateFields(new List<DF_FieldValidator.FieldValidatorInputWrapper>{fieldValidatorInputWrapper});
        Test.stopTest();
        
        Assert.isFalse(fieldValidatorOutputWrapper.isEmpty());
        Assert.isFalse(fieldValidatorOutputWrapper[0].success);
        Assert.isTrue(fieldValidatorOutputWrapper[0].message.contains('No duplicate field configuration found'));
    }

    @IsTest
    static void validateFields_itReturnsFailure_whenInvalidObjectProvided() {
        DF_FieldValidator.testDataFields = new List<String>{'Name'};

        DF_FieldValidator.fieldValidatorInputWrapper fieldValidatorInputWrapper = new DF_FieldValidator.fieldValidatorInputWrapper();
        fieldValidatorInputWrapper.entityType = 'InvalidObject';

        Test.startTest();
        List<DF_FieldValidator.FieldValidatorOutputWrapper> fieldValidatorOutputWrapper = DF_FieldValidator.validateFields(new List<DF_FieldValidator.fieldValidatorInputWrapper>{fieldValidatorInputWrapper});
        Test.stopTest();
		
        Assert.isFalse(fieldValidatorOutputWrapper.isEmpty());
        Assert.isFalse(fieldValidatorOutputWrapper[0].success);
    }
}