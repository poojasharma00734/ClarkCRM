import { LightningElement, wire, track, api } from 'lwc';
import getConfigs from '@salesforce/apex/ConfigController.getAvailableConfigs';
import addConfigsToCase from '@salesforce/apex/ConfigController.addConfigsToCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from "lightning/refresh";
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Case.Status';

export default class AvailableConfigs extends LightningElement {
    @track configs = [];  // Stores available Config__c records
    wiredResult;
    @track selectedConfigs = [];  // Stores selected Config records
    @track selectedRowsID = [];  // Add this property to track selected row IDs
    @api recordId;
    @track isCaseClosed = false;

    // Define table columns for Config records
    columns = [
        { label: 'Label', fieldName: 'Label__c' },
        { label: 'Type', fieldName: 'Type__c' },
        { label: 'Amount', fieldName: 'Amount__c', type: 'currency' }
    ];

     // Use getRecord to get the Case Status
     @wire(getRecord, { 
        recordId: '$recordId', 
        fields: [STATUS_FIELD] 
    })
    wiredCase({ error, data }) {
        if (data) {
            // Get the status value
            const status = data.fields.Status.value;
            
            // Check if case is closed - adjust based on your Status picklist values
            this.isCaseClosed = status === 'Closed';
            console.log('Case Status:', status, 'Is Closed:', this.isCaseClosed);
        } else if (error) {
            console.error('Error loading case:', error);
        }
    }

    // Fetch available Config records from Apex
    @wire(getConfigs, { caseId: '$recordId' })
    wiredConfigs(result) {
        this.wiredResult = result;
        if (result.data) {
            this.configs = result.data;
            
        } else if (result.error) {
            console.error('Error fetching configs:', result.error);
        }
    }

    // Capture selected rows in the table
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRowsID = selectedRows.map(row => row.Id);
        const caseIdValue = this.recordId;
        const formattedRows = selectedRows.map(row => {
            // Only include fields that exist on Case_Config__c
            return {
                Case__c: caseIdValue, // add the case ID
                Name : row.Label__c,
                Label__c : row.Label__c, // Add label field for case config
                Type__c: row.Type__c, // Add type field for case config
                Amount__c: row.Amount__c // Add amount field for case config
            };
        });
        this.selectedConfigs = formattedRows;
    }

    // Add selected Configs to Case
    handleAdd() {
        if (this.selectedConfigs.length > 0) {
            addConfigsToCase({selectedConfig: this.selectedConfigs })
                .then(() => {
                    this.showToast('Success', 'Configs added to Case successfully!', 'success');
                    this.configs = this.configs.filter(row => !this.selectedRowsID.includes(row.Id));
                    console.log(this.configs.length);
                    if(this.configs.length === 0){
                        this.isCaseClosed=true;
                    }
                    // Clear selection
                    this.selectedRowIds = [];
                    this.template.querySelector('lightning-datatable').selectedRows = [];
                // Dispatch RefreshEvent to notify Case Config Component to refresh
                this.dispatchEvent(new RefreshEvent());
                })
                .catch(error => {
                    console.error('Error adding Configs to Case: ', error);
                    this.showToast('Error', 'Failed to add Configs to Case.', 'error');
                });
        } else {
            this.showToast('Warning', 'Please select at least one Config.', 'warning');
        }
    }

    // Helper function to show toast messages
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(evt);
    }
        // Method to refresh data
        refreshData() {
            refreshApex(this.configs);
        }
}