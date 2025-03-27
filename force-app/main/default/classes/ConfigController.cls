public with sharing class ConfigController {
    @AuraEnabled(cacheable=true)
    public static List<Config__c> getAvailableConfigs(Id caseId) {
        Set<String> existingConfigLabels = new Set<String>();
        // Get labels of configs already added to this case
        for(Case_Config__c cc : [SELECT Label__c FROM Case_Config__c WHERE Case__c = :caseId WITH SECURITY_ENFORCED]) {
            existingConfigLabels.add(cc.Label__c);
        }
        // Return only configs that haven't been added yet
        return [SELECT Id, Label__c, Type__c, Amount__c 
                FROM Config__c 
                WHERE Label__c NOT IN :existingConfigLabels WITH SECURITY_ENFORCED];
    }

     /**
     * Adds selected Config__c records to the Case_Config__c related list.
     * Prevents duplicate Configs from being added.
     * @param selectedConfig List of selected Config__c records.
     */
    @AuraEnabled
    public static void addConfigsToCase(List<Case_Config__c> selectedConfig) {       
        if (selectedConfig.isEmpty()) {
            throw new IllegalArgumentException('Invalid inputs');
        }
        try {
        insert selectedConfig;
        } catch (Exception e) {
        // Roll back on any exception
        throw new AuraHandledException('Error: ' + e.getMessage());
        }
    } 
}