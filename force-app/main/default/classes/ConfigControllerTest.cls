/**
 * Test class for ConfigController
 * @author Pooja Sharma
 */
@isTest
public with sharing class ConfigControllerTest {
     // Test data setup
     @TestSetup
     static void setupTestData() {
         // Create test case
         Case testCase = new Case(
             Subject = 'Test Case',
             Status = 'New',
             Origin = 'Web'
         );
         insert testCase;
         
         // Create test configs
         List<Config__c> configs = new List<Config__c>();
         for (Integer i = 1; i <= 5; i++) {
             configs.add(new Config__c(
                 Name = 'Config ' + i,
                 Label__c = 'Config ' + i,
                 Type__c = 'Type ' + Math.mod(i, 3),
                 Amount__c = i * 100
             ));
         }
         insert configs;
         
         // Add some configs to the case already
         List<Case_Config__c> caseConfigs = new List<Case_Config__c>();
         caseConfigs.add(new Case_Config__c(
             Case__c = testCase.Id,
             Label__c = 'Config 1',
             Type__c = 'Type 1',
             Amount__c = 100
         ));
         caseConfigs.add(new Case_Config__c(
             Case__c = testCase.Id,
             Label__c = 'Config 2',
             Type__c = 'Type 2',
             Amount__c = 200
         ));
         insert caseConfigs;
     }
        /**
     * Test getAvailableConfigs method
     * Verifies that only configs not already added to the case are returned
     */
    @isTest
    static void testGetAvailableConfigs() {
        // Get the test case
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        
        // Start the test
        Test.startTest();
        
        // Call the method
        List<Config__c> availableConfigs = ConfigController.getAvailableConfigs(testCase.Id);
        
        // End the test
        Test.stopTest();
        
        // Verify results
        System.assertEquals(3, availableConfigs.size(), 'Should return 3 available configs');
        
        // Verify that Config 1 and Config 2 are not in the results
        for (Config__c config : availableConfigs) {
            System.assertNotEquals('Config 1', config.Label__c, 'Config 1 should not be in available configs');
            System.assertNotEquals('Config 2', config.Label__c, 'Config 2 should not be in available configs');
        }
    }
     /**
     * Test getAvailableConfigs with no existing case configs
     */
    @isTest
    static void testGetAvailableConfigsNoExisting() {
        // Create a new case with no configs
        Case newCase = new Case(
            Subject = 'New Case',
            Status = 'New',
            Origin = 'Web'
        );
        insert newCase;
        
        // Start the test
        Test.startTest();
        
        // Call the method
        List<Config__c> availableConfigs = ConfigController.getAvailableConfigs(newCase.Id);
        
        // End the test
        Test.stopTest();
        
        // Verify results
        System.assertEquals(5, availableConfigs.size(), 'Should return all 5 configs');
    }
    /**
 * Test addConfigsToCase method - successful scenario
 */
    @isTest
    static void testAddConfigsToCase() {
    // Get the test case
    Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
    // Get available configs (those not already added to the case)
    List<Config__c> availableConfigs = [
        SELECT Id, Label__c, Type__c, Amount__c 
        FROM Config__c 
        WHERE Label__c NOT IN ('Config 1', 'Config 2')
        LIMIT 2
    ];
    // Create Case_Config__c records to add
    List<Case_Config__c> configsToAdd = new List<Case_Config__c>();
    for (Config__c config : availableConfigs) {
        configsToAdd.add(new Case_Config__c(
            Case__c = testCase.Id,
            Label__c = config.Label__c,
            Type__c = config.Type__c,
            Amount__c = config.Amount__c
        ));
    }
    // Count existing case configs before adding
    Integer existingCount = [SELECT COUNT() FROM Case_Config__c WHERE Case__c = :testCase.Id];
    
    // Start the test
    Test.startTest();
    
    // Call the method to add configs
    ConfigController.addConfigsToCase(configsToAdd);
    
    // End the test
    Test.stopTest();
     // Verify results
     Integer newCount = [SELECT COUNT() FROM Case_Config__c WHERE Case__c = :testCase.Id];
     System.assertEquals(existingCount + configsToAdd.size(), newCount, 'Should have added ' + configsToAdd.size() + ' new case configs');
     
     // Verify the specific configs were added
     List<Case_Config__c> addedConfigs = [
         SELECT Label__c, Type__c, Amount__c 
         FROM Case_Config__c 
         WHERE Case__c = :testCase.Id AND Label__c IN :new List<String>{availableConfigs[0].Label__c, availableConfigs[1].Label__c}
     ];
     
     System.assertEquals(configsToAdd.size(), addedConfigs.size(), 'All configs should have been added');
     
     // Verify the details of the added configs
     for (Case_Config__c addedConfig : addedConfigs) {
         Boolean matchFound = false;
         for (Config__c originalConfig : availableConfigs) {
             if (addedConfig.Label__c == originalConfig.Label__c) {
                 System.assertEquals(originalConfig.Type__c, addedConfig.Type__c, 'Type should match');
                 System.assertEquals(originalConfig.Amount__c, addedConfig.Amount__c, 'Amount should match');
                 matchFound = true;
                 break;
             }
         }
         System.assert(matchFound, 'Should find a matching original config for ' + addedConfig.Label__c);
     }
    }
    /**
 * Test addConfigsToCase method - empty list scenario
 */
@isTest
static void testAddConfigsToCaseEmptyList() {
    // Start the test
    Test.startTest();
    
    // Call the method with empty list
    try {
        ConfigController.addConfigsToCase(new List<Case_Config__c>());
        System.assert(false, 'Should have thrown an exception for empty list');
    } catch (IllegalArgumentException e) {
        System.assertEquals('Invalid inputs', e.getMessage(), 'Exception message should match');
    }
    
    // End the test
    Test.stopTest();
}

/**
 * Test addConfigsToCase method - exception handling
 */
@isTest
static void testAddConfigsToCaseException() {
    // Create a test case
    Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
    
    // Create a Case_Config__c with invalid data that will cause a DML exception
    // For example, exceeding field length limits
    String tooLongString = 'A';
    for(Integer i = 0; i < 300; i++) {
        tooLongString += 'A'; // Create a string that exceeds field length limits
    }
    
    List<Case_Config__c> invalidConfigs = new List<Case_Config__c>{
        new Case_Config__c(
            Case__c = testCase.Id,
            Label__c = tooLongString, // This should exceed the field length limit
            Type__c = 'Test Type',
            Amount__c = 100
        )
    };
    
    // Start the test
    Test.startTest();
    
    // Variable to track if exception was thrown
    Boolean exceptionThrown = false;
    
    // Call the method with invalid data
    try {
        ConfigController.addConfigsToCase(invalidConfigs);
    } catch (Exception e) {
        exceptionThrown = true;
        System.debug('Exception type: ' + e.getTypeName());
        System.debug('Exception message: ' + e.getMessage());
    }
    
    // End the test
    Test.stopTest();
    
    // Verify an exception was thrown
    System.assert(exceptionThrown, 'An exception should have been thrown');
}
}