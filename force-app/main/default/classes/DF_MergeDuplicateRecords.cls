public class DF_MergeDuplicateRecords {
    
    public class MergeDuplicateInput {
        @InvocableVariable(required=true) public String objectName;
        @InvocableVariable(required=true) public Id masterId;
        @InvocableVariable(required=true) public List<Id> duplicateIds;
    }
    
    public class MergeDuplicateOutput {
        @InvocableVariable public String masterRecordId;
        @InvocableVariable public String message;
    }
    
    @InvocableMethod( label='Merge Duplicates Using Field Values.' 
                     description='Merge duplicate records' ) 
    public static List<MergeDuplicateOutput> mergeDuplicates(List<MergeDuplicateInput> lstMergeDuplicateInput) {
        MergeDuplicateInput mergeDuplicateInput = lstMergeDuplicateInput[0];
        Set<Id> duplicateRecordIds = getDuplicateIds(mergeDuplicateInput.masterId,mergeDuplicateInput.duplicateIds);
        
        Map<String, Schema.SObjectField> fieldMap = getFieldMap(mergeDuplicateInput.objectName);
        List<String> mergeableFields = getMergeableFields(fieldMap);
        
        SObject masterRecord = getMasterRecord(mergeDuplicateInput.objectName,mergeDuplicateInput.masterId,mergeableFields);
        List<String> emptyFieldsOfMasterRecord = getEmptyFields(masterRecord, mergeableFields);

        List<SObject> duplicateRecords = getDuplicateRecords(mergeDuplicateInput.objectName,duplicateRecordIds,emptyFieldsOfMasterRecord);

        List<Custom_Field_History_Tracking__c> historyRecords = populateMasterRecord(masterRecord,duplicateRecords,emptyFieldsOfMasterRecord,mergeDuplicateInput.objectName,mergeDuplicateInput.masterId);

        saveChanges(masterRecord,duplicateRecords,historyRecords);
        
        return buildResponse(masterRecord.Id);
       
    }
    
    private static Set<Id> getDuplicateIds( Id masterId, List<Id> duplicateRecordIds ) { 
        Set<Id> setDuplicateRecordIds = new Set<Id>(duplicateRecordIds); 
        setDuplicateRecordIds.remove(masterId); 
        return setDuplicateRecordIds; 
    } 
    
    private static Map<String, Schema.SObjectField> getFieldMap( String objectName ) { 
        return Schema.getGlobalDescribe() .get(objectName) .getDescribe() .fields .getMap(); 
    }
    
    private static SObject getMasterRecord( String objectName, Id masterId, List<String> fields ) { 
        fields.add('Id');
        String query = 'SELECT ' + String.join(fields, ',') + ' FROM ' + objectName + ' WHERE Id = :masterId'; 
        return Database.query(query); 
    }
    
    private static List<String> getEmptyFields( SObject master,List<String> mergeableFields ) { 
        List<String> emptyFields = new List<String>(); 
        
        for(String fieldName : mergeableFields){
            Object value = master.get(fieldName);
            
            if(value == null || (value instanceof String && String.isBlank((String)value))){
                emptyFields.add(fieldName);
            }
        }
        
        return emptyFields; 
    }
    
    private static List<SObject> getDuplicateRecords(String objectName,Set<Id> duplicateRecordIds,List<String> fields) {
        if(duplicateRecordIds.isEmpty()) {
            return new List<SObject>();
        }
        
        List<String> queryFields = new List<String>{'Id'};
        queryFields.addAll(fields);
        
        String query = 'SELECT ' +
                        String.join(queryFields, ',') +
                        ' FROM ' +
                        objectName +
                        ' WHERE Id IN :duplicateRecordIds';
        
        return Database.query(query);
    }
    
    private static List<String> getMergeableFields(Map<String, Schema.SObjectField> fieldMap){
        List<String> mergeableFields = new List<String>();
        
        for(String fieldName : fieldMap.keySet()){
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            if( fieldName == 'Id' || !fieldDescribe.isAccessible() || !fieldDescribe.isUpdateable() ||
                fieldDescribe.isCalculated() || fieldDescribe.isAutoNumber() || fieldDescribe.getType() == Schema.DisplayType.Address 
               || fieldDescribe.getType() == Schema.DisplayType.Location ){
                continue;
            }
            
            // Skip managed package fields
            if(fieldName.endsWith('__c') && fieldName.substringBefore('__c').contains('__')){
                continue;
            }
            
            mergeableFields.add(fieldName);
        }
        
        return mergeableFields;
    }
    
    private static List<Custom_Field_History_Tracking__c> populateMasterRecord(SObject master,List<SObject> duplicateRecords,List<String> emptyFields,String objectName,String recordId) {
        List<Custom_Field_History_Tracking__c> historyRecords = new List<Custom_Field_History_Tracking__c>();
        
        for (String fieldName : emptyFields) {
            for (SObject duplicateRecord : duplicateRecords) {
                Object fieldValue = duplicateRecord.get(fieldName);
                
                if (fieldValue == null) {
                    continue;
                }
                
                master.put(fieldName, fieldValue);
                historyRecords.add(createHistoryRecord(objectName, fieldName, null, fieldValue, recordId));
                break;
            }
        }
        
        return historyRecords;
    }
    
    private static Custom_Field_History_Tracking__c createHistoryRecord(String objectName,String fieldName,Object oldValue,Object newValue,String masterRecordId) {
        Custom_Field_History_Tracking__c customFieldHistoryRecord = new Custom_Field_History_Tracking__c();
        
        customFieldHistoryRecord.Name = objectName;
        customFieldHistoryRecord.Master_Record_Id__c = masterRecordId;
        customFieldHistoryRecord.Field_Name__c = fieldName;
        customFieldHistoryRecord.Old_Value__c = oldValue == null ? null : String.valueOf(oldValue);
        customFieldHistoryRecord.New_Value__c = newValue == null  ? null : String.valueOf(newValue);
        customFieldHistoryRecord.Modified_By__c = UserInfo.getUserId();

        return customFieldHistoryRecord;
    }
    
    private static void saveChanges(SObject masterRecord,List<SObject> duplicateRecords,List<Custom_Field_History_Tracking__c> lstCustomFieldHistoryRecords) {
        UPDATE masterRecord;
        
        if(!lstCustomFieldHistoryRecords.isEmpty()) {
            INSERT lstCustomFieldHistoryRecords;
        }
        
        if(!duplicateRecords.isEmpty()) {
            DELETE duplicateRecords;
        }
    }
    
    private static List<MergeDuplicateOutput> buildResponse(Id masterId) {
        MergeDuplicateOutput mergeDuplicateOutput = new MergeDuplicateOutput();
        mergeDuplicateOutput.masterRecordId = String.valueOf(masterId);
        mergeDuplicateOutput.message = 'Master Record Updated Successfully';
        
        return new List<MergeDuplicateOutput>{ mergeDuplicateOutput };
    }
}