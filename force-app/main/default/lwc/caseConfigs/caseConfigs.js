import { LightningElement, wire, track,api } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import sendCaseData from '@salesforce/apex/CaseConfigController.sendCaseData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { registerRefreshHandler, unregisterRefreshHandler,REFRESH_ERROR,REFRESH_COMPLETE,REFRESH_COMPLETE_WITH_ERRORS } from 'lightning/refresh';

export default class CaseConfigs extends LightningElement {
    @api recordId;
    @track configs = [];  // Stores Case_Config__c records related to the case
    error;
    wiredResult;
    refreshHandlerId;
    isLoading = true;

    // Define table columns for Case Config records
    columns = [
        { label: 'Label', fieldName: 'Label__c' },
        { label: 'Type', fieldName: 'Type__c' },
        { label: 'Amount', fieldName: 'Amount__c', type: 'currency' }
    ];
    
    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Case_Configs__r',
        fields: ['Case_Config__c.Id', 'Case_Config__c.Label__c', 'Case_Config__c.Amount__c', 'Case_Config__c.Type__c'],
        sortBy: ['Case_Config__c.Label__c']
    })
    wiredCaseConfigs(result) {
        this.wiredResult = result;
        this.isLoading = true;
        if (result.data) {
          this.configs = this.transformData(result.data); 
          this.error = undefined;
        } else if (result.error) {
        console.error('Error fetching case configs:', result.error);
          this.error = result.error;
          this.configs = [];

        }
        this.isLoading = false;
      }
      transformData(data) {
        // Map the API response to match your column structure
            if (!data || !data.records) return [];
            
            return data.records.map(record => {
                // Create a new object with the fields we need
                const flattenedRecord = {
                    id: record.id,
                    // Map the fields from the response to match our column structure
                    Label__c: record.fields.Label__c?.value || '',
                    Type__c: record.fields.Type__c?.value || '',
                    Amount__c: record.fields.Amount__c?.value || 0
                };
                
                return flattenedRecord;
            });
    }

    // Register for refresh events when component is connected
    connectedCallback() {
        this.refreshHandlerId = registerRefreshHandler(this, this.handleRefresh.bind(this));
    }
     // Unregister when component is disconnected
     disconnectedCallback() {
        unregisterRefreshHandler(this.refreshHandlerId);
    }

    // Send Case Config data to an external system
    handleSend() {
        console.log('record', this.recordId);
    }

    // Helper function to show toast messages
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(evt);
    }
    // Handle the refresh event
    handleRefresh() {
        return refreshApex(this.wiredResult);
    }

    
}