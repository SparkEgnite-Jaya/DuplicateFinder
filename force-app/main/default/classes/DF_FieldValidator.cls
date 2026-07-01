public class DF_FieldValidator {
    
    @TestVisible
    private static List<String> testDataFields;

    public class FieldValidatorInputWrapper {
        @InvocableVariable(required=true) public String entityType;
    }
    
    public class FieldValidatorOutputWrapper {
        @InvocableVariable public Boolean success;
        @InvocableVariable public List<String> supportedFields;
        @InvocableVariable public List<String> unsupportedFields;
        @InvocableVariable public String message;
    }
    
    @InvocableMethod(label='Validate Duplicate Fields'
                     description='Validates duplicate matching fields configured in metadata')
    public static List<FieldValidatorOutputWrapper> validateFields(List<FieldValidatorInputWrapper> fieldValidatorInputWrappers) {
        List<FieldValidatorOutputWrapper> fieldValidatorOutputWrappers = new List<FieldValidatorOutputWrapper>();
        
        for(FieldValidatorInputWrapper fieldValidatorInputWrapper : fieldValidatorInputWrappers) {
            fieldValidatorOutputWrappers.add(processRequest(fieldValidatorInputWrapper));
        }
        
        return fieldValidatorOutputWrappers;
    }
    
    private static FieldValidatorOutputWrapper processRequest(FieldValidatorInputWrapper fieldValidatorInputWrapper) {
        FieldValidatorOutputWrapper fieldValidatorOutputWrapper = initializeOutput();
        
        try {
            List<String> configuredFields = getConfiguredFields(fieldValidatorInputWrapper.entityType);
            
            if(configuredFields.isEmpty()) {
                fieldValidatorOutputWrapper.success = false;
                fieldValidatorOutputWrapper.message = 'No duplicate field configuration found for object '+ fieldValidatorInputWrapper.entityType;
                return fieldValidatorOutputWrapper;
            }
            
            validateConfiguredFields(fieldValidatorInputWrapper.entityType, configuredFields, fieldValidatorOutputWrapper);
            setResultStatus(fieldValidatorOutputWrapper);
        } catch(Exception ex) {
            fieldValidatorOutputWrapper.success = false;
            fieldValidatorOutputWrapper.message = ex.getMessage();
        }
        
        return fieldValidatorOutputWrapper;
    }
    
    private static List<String> getConfiguredFields(String objectName) {
        if(Test.isRunningTest() && testDataFields != null) {
            return testDataFields;
        }

        List<String> metadataConfiguredFields = new List<String>();

        for(DF_Duplicate_Field_Config__mdt duplicateFieldMetadataConfig : getConfiguredObjectFields(objectName)) {
            metadataConfiguredFields.add(duplicateFieldMetadataConfig.Field_API_Name__c);
        }

        return metadataConfiguredFields;
    }
    
    private static FieldValidatorOutputWrapper initializeOutput() {
        FieldValidatorOutputWrapper fieldValidatorOutputWrapper = new FieldValidatorOutputWrapper();
        fieldValidatorOutputWrapper.supportedFields = new List<String>();
        fieldValidatorOutputWrapper.unsupportedFields = new List<String>();
        
        return fieldValidatorOutputWrapper;
    }
    
    private static Map<String, Schema.SObjectField> getFieldMap(String objectName) {
        return Schema.getGlobalDescribe()
                     .get(objectName)
                     .getDescribe()
                     .fields
                     .getMap();
    }
    
    private static void validateConfiguredFields(String objectName,List<String> configuredFields,FieldValidatorOutputWrapper result) {
        Map<String, Schema.SObjectField> objectFieldsMap = getFieldMap(objectName);
        
        for(String fieldName : configuredFields) {
            if(isSupportedField(fieldName, objectFieldsMap)) {
                result.supportedFields.add(fieldName);
            }
            else {
                result.unsupportedFields.add(fieldName);
            }
        }
    }
    
    private static Boolean isSupportedField(String fieldName,Map<String, Schema.SObjectField> objectFieldsMap) {
        if(!objectFieldsMap.containsKey(fieldName)) {
            return false;
        }
        
        Schema.DescribeFieldResult fieldDescribeResult = objectFieldsMap.get(fieldName).getDescribe();
        
        return fieldDescribeResult .isAccessible()
            && fieldDescribeResult .isFilterable()
            && isSupportedType(fieldDescribeResult.getType());
    }
    
    private static Boolean isSupportedType(Schema.DisplayType fieldType) {
        return fieldType == Schema.DisplayType.String
            || fieldType == Schema.DisplayType.Email
            || fieldType == Schema.DisplayType.Phone
            || fieldType == Schema.DisplayType.Picklist
            || fieldType == Schema.DisplayType.Integer
            || fieldType == Schema.DisplayType.Double
            || fieldType == Schema.DisplayType.Currency
            || fieldType == Schema.DisplayType.Date
            || fieldType == Schema.DisplayType.DateTime
            || fieldType == Schema.DisplayType.Url
        	|| fieldType == Schema.DisplayType.Boolean;
    }
    
    private static void setResultStatus(FieldValidatorOutputWrapper fieldValidatorOutputWrapper) {
        fieldValidatorOutputWrapper.success = fieldValidatorOutputWrapper.unsupportedFields.isEmpty();
        fieldValidatorOutputWrapper.message = fieldValidatorOutputWrapper.success ? 'All configured fields are supported.'
            																	  : 'Some configured fields are unsupported.';
    } 
    
    private static List<DF_Duplicate_Field_Config__mdt> getConfiguredObjectFields(String objectName){
        return [SELECT Field_API_Name__c,Object_Name__c
                FROM DF_Duplicate_Field_Config__mdt
                WHERE Object_Name__c = :objectName];
    }
}