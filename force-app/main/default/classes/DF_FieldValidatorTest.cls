@IsTest
private class DF_FieldValidatorTest {

    @IsTest
    static void validateFields_ReturnsSuccess_WhenAllConfiguredFieldsAreSupported() {

        DF_FieldValidator.testDataFields = new List<String>{'Name','Phone'};

        DF_FieldValidator.FieldValidatorInputWrapper fieldValidatorInputWrapper = new DF_FieldValidator.FieldValidatorInputWrapper();
        fieldValidatorInputWrapper.entityType = 'Account';

        Test.startTest();
        List<DF_FieldValidator.FieldValidatorOutputWrapper> fieldValidatorOutputWrapper = DF_FieldValidator.validateFields(new List<DF_FieldValidator.FieldValidatorInputWrapper>{ fieldValidatorInputWrapper});
        Test.stopTest();

        System.assertEquals(1, fieldValidatorOutputWrapper.size());
        System.assertEquals(true, fieldValidatorOutputWrapper[0].success);
        System.assertEquals(2, fieldValidatorOutputWrapper[0].supportedFields.size());
        System.assertEquals(0, fieldValidatorOutputWrapper[0].unsupportedFields.size());
    }

    @IsTest
    static void validateFields_ReturnsSupportedAndUnsupportedFields_WhenInvalidFieldExists() {

        DF_FieldValidator.testDataFields = new List<String>{'Name','Invalid_Field__c'};

        DF_FieldValidator.FieldValidatorInputWrapper fieldValidatorInputWrapper = new DF_FieldValidator.FieldValidatorInputWrapper();
        fieldValidatorInputWrapper.entityType = 'Account';

        Test.startTest();
        List<DF_FieldValidator.FieldValidatorOutputWrapper> fieldValidatorOutputWrapper = DF_FieldValidator.validateFields(new List<DF_FieldValidator.FieldValidatorInputWrapper>{fieldValidatorInputWrapper});
		Test.stopTest();

        System.assertEquals(false, fieldValidatorOutputWrapper[0].success);
        System.assertEquals(1, fieldValidatorOutputWrapper[0].supportedFields.size());
        System.assertEquals(1, fieldValidatorOutputWrapper[0].unsupportedFields.size());
        System.assert(fieldValidatorOutputWrapper[0].unsupportedFields.contains('Invalid_Field__c'));
    }

    @IsTest
    static void validateFields_ReturnsFailure_WhenNoConfiguredFieldsExist() {

        DF_FieldValidator.testDataFields = new List<String>();

        DF_FieldValidator.FieldValidatorInputWrapper fieldValidatorInputWrapper = new DF_FieldValidator.FieldValidatorInputWrapper();
        fieldValidatorInputWrapper.entityType = 'Account';

        Test.startTest();
        List<DF_FieldValidator.FieldValidatorOutputWrapper> fieldValidatorOutputWrapper = DF_FieldValidator.validateFields(new List<DF_FieldValidator.FieldValidatorInputWrapper>{fieldValidatorInputWrapper});
        Test.stopTest();

        System.assertEquals(false, fieldValidatorOutputWrapper[0].success);
        System.assert(fieldValidatorOutputWrapper[0].message.contains('No duplicate field configuration found'));
    }

    @IsTest
    static void validateFields_ReturnsFailure_WhenInvalidObjectProvided() {

        DF_FieldValidator.testDataFields = new List<String>{'Name'};

        DF_FieldValidator.fieldValidatorInputWrapper fieldValidatorInputWrapper = new DF_FieldValidator.fieldValidatorInputWrapper();
        fieldValidatorInputWrapper.entityType = 'InvalidObject';

        Test.startTest();
        List<DF_FieldValidator.FieldValidatorOutputWrapper> fieldValidatorOutputWrapper = DF_FieldValidator.validateFields(new List<DF_FieldValidator.fieldValidatorInputWrapper>{fieldValidatorInputWrapper});
        Test.stopTest();

        System.assertEquals(false, fieldValidatorOutputWrapper[0].success);
    }
}