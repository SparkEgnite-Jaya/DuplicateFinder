public class DF_ConfigurationController {
    
    public class ConfigurationStatus {
        @AuraEnabled public Boolean isCustomMetadataConfigured;
        @AuraEnabled public Boolean isRecordLimitConfigured;
        @AuraEnabled public Integer recordLimit;
        @AuraEnabled public Boolean isReady;
    }

    @AuraEnabled(cacheable=true)
    public static ConfigurationStatus getConfigurationStatus() {
        ConfigurationStatus status = new ConfigurationStatus();

        status.isCustomMetadataConfigured = [SELECT Count() FROM DF_Duplicate_Field_Config__mdt] > 0;
        Duplicate_Finder_Setting__c setting = Duplicate_Finder_Setting__c.getOrgDefaults();

        if(setting != null && setting.Record_Limit__c != null){
            status.isRecordLimitConfigured = true;
            status.recordLimit = Integer.valueOf(setting.Record_Limit__c);
        }else {
            status.isRecordLimitConfigured = false;
        }

        status.isReady = status.isCustomMetadataConfigured && status.isRecordLimitConfigured;
        return status;
    }
    
}