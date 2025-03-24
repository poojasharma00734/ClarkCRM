public with sharing class ConfigController {
    
    /**
     * Retrieves all available Config__c records.
     * @return List of Config__c records with Id, Label, Type, and Amount fields.
     */
    @AuraEnabled(cacheable=true)
    public static List<Config__c> getAvailableConfigs() {
        return [SELECT Id, Label__c, Type__c, Amount__c FROM Config__c];
    }

     /**
     * Adds selected Config__c records to the Case_Config__c related list.
     * Prevents duplicate Configs from being added.
     * @param selectedConfig List of selected Config__c records.
     */

    @AuraEnabled
    public static void addConfigsToCase(List<Case_Config__c> selectedConfig) {
        system.System.debug('select'+ selectedConfig);
       
        if (selectedConfig.isEmpty()) {
            throw new IllegalArgumentException('Invalid inputs');
        }
        insert selectedConfig;
    }
}