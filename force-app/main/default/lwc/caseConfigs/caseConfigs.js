import { LightningElement, wire, track,api } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import { registerRefreshHandler, unregisterRefreshHandler} from 'lightning/refresh';
import sendCaseData from '@salesforce/apex/CaseConfigController.sendCaseData';


export default class CaseConfigs extends LightningElement {
    @api recordId;
    @track configs = [];  // Stores Case_Config__c records related to the case
    error;
    wiredResult;
    refreshHandlerId;
    isLoading = true;
    @track isCaseClosed = false;
    @track isProcessing = false;
    @track resultMessage = '';

    // Define table columns for Case Config records
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
        // Set processing state
        this.isProcessing = true;
        this.resultMessage = '';
        sendCaseData({ 
            caseId: this.recordId,
            caseConfigs: this.configs
        })
        .then(result => {
            this.isProcessing = false;
            this.resultMessage = result;
            console.log('result'+result)
            // Refresh the record page to show updated status
            if (result.startsWith('Success')) {
                // Show success message
                this.resultMessage = result;                
                // Show toast notification
                getRecordNotifyChange([{recordId: this.recordId}]);
                // 4. Dispatch the RefreshEvent for other components to refresh
                this.showToast('Success', 'Case data sent and case closed successfully', 'success');
                
            } else {
                // Show error message
                this.resultMessage = result;
                this.showToast('Error', 'Failed to process case data', 'error');
            }
        })
        .catch(error => {
            this.isProcessing = false;
            this.resultMessage = 'Error: ' + (error.body ? error.body.message : error.message);
            this.showToast('Error', this.resultMessage, 'error');
        });

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