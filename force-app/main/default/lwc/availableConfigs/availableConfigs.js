import { LightningElement, wire, track, api } from 'lwc';
import getAvailableConfigs from '@salesforce/apex/ConfigController.getAvailableConfigs';
import addConfigsToCase from '@salesforce/apex/ConfigController.addConfigsToCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from "lightning/refresh";

export default class AvailableConfigs extends LightningElement {
    @track configs = [];  // Stores available Config__c records
    wiredResult;
    @track selectedConfigs = [];  // Stores selected Config records
    @track selectedRows = [];  // Add this property to track selected row IDs
    @api recordId;


    // Define table columns for Config records
    columns = [
        { label: 'Label', fieldName: 'Label__c' },
        { label: 'Type', fieldName: 'Type__c' },
        { label: 'Amount', fieldName: 'Amount__c', type: 'currency' }
    ];

    // Fetch available Config records from Apex
    @wire(getAvailableConfigs)
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
                    this.selectedConfigs = [];
                    this.selectedRows = [];
                    // Dispatch the RefreshEvent to notify other components
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
}