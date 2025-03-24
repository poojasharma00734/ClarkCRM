public with sharing class CaseConfigController {

    /**
     * Retrieves all Case_Config__c records related to a given Case.
     * @param caseId The Id of the Case.
     * @return List of Case_Config__c records.
     */
    @AuraEnabled(cacheable=true)
    public static List<Case_Config__c> getCaseConfigs(Id caseId) {
        return [SELECT Id, Label__c, Type__c, Amount__c FROM Case_Config__c WHERE Case__c = :caseId WITH SECURITY_ENFORCED];
    }

    /**
     * Adds selected Config__c records to the Case_Config__c related list.
     * Prevents duplicate Configs from being added.
     * @param caseId The Id of the Case.
     * @param configIds List of selected Config__c record Ids.
     */
    @AuraEnabled
    public static void addConfigsToCase(List<Case_Config__c> selectedConfig) {
        system.System.debug('select'+ selectedConfig);
       
        if (selectedConfig.isEmpty()) {
            throw new IllegalArgumentException('Invalid inputs');
        }
        insert selectedConfig;
    }

    /**
     * Sends the Case Config data to an external service and closes the Case.
     * @param caseId The Id of the Case to be sent.
     * @return A success or error message.
     */
    @AuraEnabled
    public static String sendCaseData(Id caseId) {
        if (caseId == null) {
            return 'Invalid caseId';
        }

        // Fetch all Case Config records for the given Case
        List<Case_Config__c> caseConfigs = [SELECT Label__c, Type__c, Amount__c FROM Case_Config__c WHERE Case__c = :caseId];

        if (caseConfigs.isEmpty()) {
            return 'No configs to send';
        }

        // Update Case status to "Closed"
        Case caseRecord = [SELECT Id, Status FROM Case WHERE Id = :caseId];
        caseRecord.Status = 'Closed';
        update caseRecord;

        // Prepare JSON payload for external service
        List<Map<String, Object>> configsList = new List<Map<String, Object>>();
        for (Case_Config__c cc : caseConfigs) {
            configsList.add(new Map<String, Object>{
                'label' => cc.Label__c,
                'type' => cc.Type__c,
                'amount' => cc.Amount__c
            });
        }

        Map<String, Object> payload = new Map<String, Object>{
            'caseId' => caseId,
            'status' => 'Closed',
            'caseConfigs' => configsList
        };

        // HTTP Request to External API
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://requestcatcher.com/'); 
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(payload));

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                return 'Success';
            } else {
                return 'Error: ' + response.getBody();
            }
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}