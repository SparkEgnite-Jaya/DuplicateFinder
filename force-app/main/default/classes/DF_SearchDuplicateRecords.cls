public class DF_SearchDuplicateRecords {
    
    public class DuplicateSearchInput { 
        @InvocableVariable(required=true) public String objectName; 
        @InvocableVariable(required=true) public String recordId; 
        @InvocableVariable(required=true) public List<String> fieldNames; 
    }
    
    public class DuplicateSearchOutput {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
        @InvocableVariable public Integer duplicateCount;
        @InvocableVariable public DuplicateRecordsInfo duplicateRecords;
    }
    
    public class DuplicateRecordsInfo{
        @InvocableVariable public List<DuplicateRecordInfo> lstDuplicateRecordInfo;
    }
    
    public class DuplicateRecordInfo {
        @InvocableVariable public Id recordId;
        @InvocableVariable public List<MatchedField> matchedFields;
    }
    
    public class MatchedField {
        @InvocableVariable public String fieldName;
        @InvocableVariable public String fieldValue;
    }
    
    @InvocableMethod(label='Find Duplicate Records'
                     description='Find duplicate records using configured fields')
    public static List<DuplicateSearchOutput> findDuplicates(List<DuplicateSearchInput> duplicateSearchInputs) {
        List<DuplicateSearchOutput> duplicateSearchOutputs = new List<DuplicateSearchOutput>();
        
        for (DuplicateSearchInput duplicateSearchInput : duplicateSearchInputs) {
            duplicateSearchOutputs.add(processRequest(duplicateSearchInput));
        }
        
        return duplicateSearchOutputs;
    }
    
    private static DuplicateSearchOutput processRequest(DuplicateSearchInput duplicateSearchInput) {
        try {
            SObject sourceRecord = getSourceRecord(duplicateSearchInput);
            String whereClause = buildDuplicateCriteria(sourceRecord,duplicateSearchInput.fieldNames);
            
            if (String.isBlank(whereClause)) {
                return buildErrorOutput('No field values available for duplicate search.');
            }
            
            List<SObject> duplicateRecords = findMatchingRecords(duplicateSearchInput.objectName,duplicateSearchInput.recordId,duplicateSearchInput.fieldNames,whereClause);
            
            return buildSuccessOutput(duplicateRecords,duplicateSearchInput.fieldNames);
        } catch (Exception e) {
            return buildErrorOutput(e.getMessage());
        }
    }    
    
    private static SObject getSourceRecord(DuplicateSearchInput input) {
        Set<String> fields = new Set<String>(input.fieldNames);
        fields.add('Id');
        
        String query = 'SELECT ' +
                        String.join(new List<String>(fields), ',') +
                        ' FROM ' +
                        input.objectName +
                        ' WHERE Id = ' + '\'' +input.recordId + '\'';
        
        return Database.query(query);
    }
    
    private static String buildDuplicateCriteria(SObject sourceRecord,List<String> fieldNames) {
        List<String> conditions = new List<String>();
        
        for (String fieldName : fieldNames) {
            String condition = buildFieldCondition(sourceRecord, fieldName);
            if (condition != null) {
                conditions.add(condition);
            }
        }
        
        return String.join(conditions, ' AND ');
    }
    
    private static String buildFieldCondition(SObject sourceRecord,String fieldName) {
        Object sourceFieldvalue = sourceRecord.get(fieldName);
        
        if (sourceFieldvalue == null) {
            return fieldName + ' = null';
        }
        
        if (sourceFieldvalue instanceof String) {
            return fieldName + ' = \'' + String.escapeSingleQuotes( String.valueOf(sourceFieldvalue) ) + '\'';
        }
        
        return fieldName + ' = ' + String.valueOf(sourceFieldvalue);
    }
 
    private static List<SObject> findMatchingRecords(String objectName,Id recordId,List<String> fieldNames,String whereClause) {
        List<String> queryFields = new List<String>{'Id'};
        queryFields.addAll(fieldNames);
        
        Integer recordLimit = getRecordLimit();
        
        String query = 'SELECT ' +  String.join(queryFields, ',') +
                        ' FROM ' + objectName +
                        ' WHERE ' + whereClause + 
            			' ORDER BY CreatedDate DESC' +
            			' LIMIT ' + recordLimit;
        
        return Database.query(query);
    }
 
    private static DuplicateSearchOutput buildSuccessOutput(List<SObject> duplicateRecords,List<String> fieldNames){
        DuplicateSearchOutput duplicateSearchOutput = new DuplicateSearchOutput();
        duplicateSearchOutput.success = true;
        duplicateSearchOutput.duplicateCount = duplicateRecords.size();
        
        if(duplicateRecords.size() > 1){
            duplicateSearchOutput.duplicateRecords = convertToWrapper(duplicateRecords,fieldNames);
            duplicateSearchOutput.message = duplicateRecords.size() +' duplicate record(s) found.';
        }
        else{
            duplicateSearchOutput.duplicateRecords = null;
            duplicateSearchOutput.message = 'No duplicate records found.';
        }
        
        return duplicateSearchOutput;
    }
    
    private static DuplicateSearchOutput buildErrorOutput(String message) {
        DuplicateSearchOutput duplicateSearchOutput = new DuplicateSearchOutput();
        
        duplicateSearchOutput.success = false;
        duplicateSearchOutput.message = message;
        
        return duplicateSearchOutput;
    }

    private static DuplicateRecordsInfo convertToWrapper(List<SObject> records,List<String> fieldNames){
        DuplicateRecordsInfo duplicateRecordsInfo = new DuplicateRecordsInfo();
        duplicateRecordsInfo.lstDuplicateRecordInfo = new List<DuplicateRecordInfo>();
        
        for(SObject record : records){
            
            DuplicateRecordInfo recordInfo = new DuplicateRecordInfo();
            recordInfo.recordId = (Id)record.get('Id');
            recordInfo.matchedFields =  new List<MatchedField>();
            
            for(String fieldName : fieldNames){
                
                MatchedField matchedField = new MatchedField();
                matchedField.fieldName = fieldName;
                Object value = record.get(fieldName);
                matchedField.fieldValue = value != null ? String.valueOf(value) : null;
                
                recordInfo.matchedFields.add(matchedField);
            }
            duplicateRecordsInfo.lstDuplicateRecordInfo.add(recordInfo);
        }
        
        return duplicateRecordsInfo;
    }
    
    private static Integer getRecordLimit(){
        Integer limitValue = 5;

        Duplicate_Finder_Setting__c duplicateFinderCustomSettingRecord = Duplicate_Finder_Setting__c.getOrgDefaults();

        if(duplicateFinderCustomSettingRecord != null && duplicateFinderCustomSettingRecord.Record_Limit__c != null){
            limitValue = Integer.valueOf(duplicateFinderCustomSettingRecord.Record_Limit__c);
        }

        if(limitValue < 1){
            limitValue = 5;
        }

        if(limitValue > 5){
            limitValue = 5;
        }

        return limitValue;
    }
}