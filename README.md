
# Clark Technical Assignment:

# User Story
As a Consultant,
I have a related list with available Configs from which I can select Configs and add them to the Case.
So that, I can add new records and activate them without leaving the Case page.
Users would like to be able to add Config records to Case without leaving the Case detail page. Users
should see two custom related lists on the detail page Case:
1. “Available Configs” - displays all available Config records.
2. “Case Configs” – displays Configs added to the current Case

# Requiremente can be divided into tasks

1. Setup object struture to store Config and Case config with reuqired fields and FLS.
2. A lwc component which shows the Available configs on the case Page 
    - Showing 3 columns and a Add button with the available config records
    - Once a config records is added to Case config the Available config disappears , we can make it ready only as well but for better solution suggestion would be hide it from available configs.
    - Once "Add" button is clicked the case configs will be displayed on Case config component without refreshing the page as per the requirements.
3. A lwc component which displays the case configs on the case Page 
    - Showing 3 columns and a "Send Case" with the case configs records related to case
    - As requirement says , Sets the status of the Case to “Closed” then request is sent to the external service but the best solution would be when the request is sent successfully then case should be closed not vice versa else case would be closed even if the request is failed.
    - Another problem would be Mixed DML exception , as DML before callout is not permitted additionally if we use asynchronous methods then case would be updated to closed and we would not be able to control the Request outcome and DML dependency.
4. Endpoint URL at "https://clarkcrm.requestcatcher.com/test"
5. Best Practices to followed
    - Good test class coveragee
    - No Hard coding and End point to custom setting
    - Coding standrd to follow for error and exceptions handling
    - Use of standard methods and SLDS classes example "lightning/uiRelatedListApi" to avoid SOQL query or 'lightning/refresh' for refresh communication to other component.
    - Avoid unnessary code logics or debugs
    - Errors of the external system handled


## Security Consderations/Assumptions

- Currenlty both the object have Sharing as Public Read/Write but it can be manage
- All the fields are read/edit 
- Object level permission are Read/Create/Edit/Delete
- All the permission are given to system admin
- There is a permission set named "CaseConfigPermission" also created if someone needs access to configurations this permission can be assigned.
- Test Classes Coverage are CaseConfigController 92% and ConfigController 100% and it covered all the negative and positive scenarios
- Not much effort on Page layouts but based on the need Config fields are required on the page layout.
- Once the case is closed both "Add" and "Send" button are disabled for any action.
- Case config list is always read only as it will only used for sending the data to external service.
- The Objects have Name standard fields which i left as text but it cna be also used as Auto Number as Lable is a uniqeue field.
- Type could be better used as picklist as it could lead as a mistake , i have made this as Text field but better suggestion to be used as Picklist.
- No need to make Case Config Object field as Unique field from the field definition as if the field is Unique it will not allow other records to be inserted on the same object which will block the purpose , ideally Case Config should be read only object only inserted by the automations.


## Optional Requirements:
1. Sort records by any column in Available Configs and Case Configs components.
2. Add pagination in the Available Configs component (there can be more than 200 records).

 First 2 we can discuss during further discussion as there are number of ways we can achieve these 2 with soring and infinite scrolling or GrapghQL

3. How would you split the above user story into tasks? Please include it in the Readme.
 - Added in the readme

| Test Class  | Coverage |
| ------------- | ------------- |
| CaseConfigControllerTest  | 92%  |
| ConfigControllerTest  | 100%  |


## - Github repository containing all the developed components

Repository link - https://github.com/poojasharma00734/ClarkCRM

## Component List

| Component Name  | Type |
| ------------- | ------------- |
| CaseConfigController  | Apex Class  |
| ConfigController  | Apex Class  |
| ConfigControllerTest  | Apex Class  |
| CaseConfigControllerTest.cls  | Apex Test Class  |
| availableConfigs  | LWC  |
| caseConfigs  | LWC  |
| Case_Record_Page1  | FlexiPage  |
| Clark_Case_Configs  | Lightning App  |
| CaseConfigPermission |  PermissionSet  |
| ConfigEndpoint | RemoteSiteSetting  |
| Case_Config__c | Custom Tab  |
| Config__c | Custom Tab  |
| Case_Config__c | CustomObject |
| Config__c | CustomObject  |
| API_Endpoint__c | Custom Setting  |
| Config__c-Config Layout | Page Layout  |
| Case_Config__c-Case Config Layout | Page Layout  |


## Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)



## Setup and Project initialization

For this I have Created a new SFDX Project and Initialize d a private GitHub repository and push the SFDX project. Committed initial project setup.

## Create Objects and Fields

For this I have created two objects with some fields, the list is given below:

Object	        Fields
Config__c		Lable, Type, Amount
Case_Config__c	Lable, Type, Amount, Case__c (Lookup)

## 