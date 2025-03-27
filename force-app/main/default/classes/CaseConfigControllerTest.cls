/**
 * Test class for CaseConfigController
 * @author Pooja Sharma
 */
@isTest
public with sharing class CaseConfigControllerTest {
    // Test data setup
    @TestSetup
    static void setupTestData() {
        // Create custom setting for API endpoint
        API_Endpoint__c endpoint = new API_Endpoint__c(
            Name = 'Config EndPoint',
            EndPointURL__c = 'https://example.com/api/config'
        );
        insert endpoint;
        
        // Create test case
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Web'
        );
        insert testCase;
        
        // Create test case configs
        List<Case_Config__c> caseConfigs = new List<Case_Config__c>();
        for (Integer i = 1; i <= 3; i++) {
            caseConfigs.add(new Case_Config__c(
                Case__c = testCase.Id,
                Label__c = 'Config ' + i,
                Type__c = 'Type ' + i,
                Amount__c = i * 100
            ));
        }
        insert caseConfigs;
    }
       /**
     * Test successful case data sending
     */
    @isTest
    static void testSendCaseDataSuccess() {
        // Get the test case
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        
        // Get case configs
        List<Case_Config__c> caseConfigs = [
            SELECT Id, Label__c, Type__c, Amount__c 
            FROM Case_Config__c 
            WHERE Case__c = :testCase.Id
        ];
        
        // Set up the mock callout response
        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());
        
        // Start the test
        Test.startTest();
        
        // Call the method
        String result = CaseConfigController.sendCaseData(testCase.Id, caseConfigs);
        
        // End the test
        Test.stopTest();
        
        // Verify the result
        System.assertEquals('Success: Case closed successfully', result, 'Should return success message');
        
        // Verify the case was updated
        Case updatedCase = [SELECT Status FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Closed', updatedCase.Status, 'Case status should be Closed');
    }
    /**
     * Test case data sending with error response
     */
    @isTest
    static void testSendCaseDataError() {
        // Get the test case
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        
        // Get case configs
        List<Case_Config__c> caseConfigs = [
            SELECT Id, Label__c, Type__c, Amount__c 
            FROM Case_Config__c 
            WHERE Case__c = :testCase.Id
        ];
        
        // Set up the mock callout response
        Test.setMock(HttpCalloutMock.class, new ErrorCalloutMock());
        
        // Start the test
        Test.startTest();
        
        // Call the method
        String result = CaseConfigController.sendCaseData(testCase.Id, caseConfigs);
        
        // End the test
        Test.stopTest();
        
        // Verify the result contains error message
        System.assert(result.startsWith('Error:'), 'Should return error message');
        
        // Verify the case was not updated
        Case updatedCase = [SELECT Status FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('New', updatedCase.Status, 'Case status should still be New');
    }
      /**
     * Mock class for successful HTTP callout
     */
    private class SuccessCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":"success","message":"Data received"}');
            response.setStatusCode(200);
            return response;
        }
    }
     /**
     * Mock class for error HTTP callout
     */
    private class ErrorCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Create a fake error response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":"error","message":"Invalid data"}');
            response.setStatusCode(400);
            return response;
        }
    }
}