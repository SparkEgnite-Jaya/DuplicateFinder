import { LightningElement, track } from 'lwc';
import getConfigurationStatus from '@salesforce/apex/DF_ConfigurationController.getConfigurationStatus';

export default class ConfigurationComponent extends LightningElement {

    @track status;
    isLoading = true;

    connectedCallback() {
        this.loadStatus();
    }

    loadStatus() {
         this.isLoading = true;
        getConfigurationStatus()
            .then(result => {
                this.status = result;
                console.log('Configuration Status: ', this.status);
            })
            .catch(error => {
                console.error(error);
            }).finally(() => {
                this.isLoading = false;
            });
    }

    get metadataStatus() {
        return this.status?.isCustomMetadataConfigured
            ? 'Configured'
            : 'Not Configured';
    }

    get recordLimitStatus() {

        if(!this.status?.isRecordLimitConfigured){
            return 'Not Configured';
        }

        return `Configured (${this.status.recordLimit})`;
    }


    get metadataIcon() {
        return this.status?.isCustomMetadataConfigured
            ? 'utility:success'
            : 'utility:error';
    }

    get recordLimitIcon() {
        return this.status?.isRecordLimitConfigured
            ? 'utility:success'
            : 'utility:error';
    }

    get recordLimitIconClass() {
        return this.status?.isRecordLimitConfigured 
            ? 'status-blue' // Applies blue to both icon and text
            : 'status-red';
    }

    get metadataIconClass() {
        return this.status?.isCustomMetadataConfigured 
            ? 'status-blue' // Applies blue to both icon and text
            : 'status-red';
    }

    get disableNext() {
        return !this.status?.isReady;
    }

    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

}