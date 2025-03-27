public with sharing class CaseConfigController {
    /**
     * Sends the Case Config data to an external service and closes the Case.
     * @param caseId The Id of the Case to be sent.
     * @return A success or error message.
     */
    @AuraEnabled
    public static String sendCaseData(Id caseId,List<Case_Config__c> caseConfigs) {
        try {
            // 1. Prepare the request payload
            Map<String, Object> payload = new Map<String, Object>();
            payload.put('caseId', caseId);
            payload.put('status', 'Closed');
            payload.put('caseConfigs', caseConfigs);
            // 2. Make the callout
            HttpResponse response = makeCallout(JSON.serialize(payload));
            // 3. Process response
            if (response.getStatusCode() == 200) {
                // Update the case if callout was successful
                Case caseToUpdate = new Case(
                    Id = caseId,
                    Status = 'Closed'
                );
                update caseToUpdate;
                return 'Success: Case closed successfully';
            } else {
                return 'Error: ' + response.getStatus() + ' - ' + response.getBody();
            }
        }catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }

    private static HttpResponse makeCallout(String jsonPayload) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        API_Endpoint__c endpoint = API_Endpoint__c.getInstance('Config EndPoint');
        // Configure your endpoint
        request.setEndpoint(endpoint.EndPointURL__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonPayload);
        // Set timeout (in milliseconds)
        request.setTimeout(120000);
        return http.send(request);
    }
}