public with sharing class ConfigController {
    
    /**
     * Retrieves all available Config__c records.
     * @return List of Config__c records with Id, Label, Type, and Amount fields.
     */
    @AuraEnabled(cacheable=true)
    public static List<Config__c> getAvailableConfigs() {
        return [SELECT Id, Label__c, Type__c, Amount__c FROM Config__c];
    }
}