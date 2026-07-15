import { LightningElement, track } from 'lwc';
import getConfigurationStatus from '@salesforce/apex/DF_ConfigurationController.getConfigurationStatus';

export default class ConfigurationComponent extends LightningElement {

    status;
    isLoading = true;

    connectedCallback() {
        this.loadStatus();
    }

    loadStatus() {
        this.isLoading = true;
        getConfigurationStatus()
            .then(result => {
                this.status = result;
            })
            .catch(error => {
                this.showToast('Error', error.body?.message || 'An error occurred.', 'error');
            }).finally(() => {
                this.isLoading = false;
            });
    }

    handleRefresh() {
        this.loadStatus();
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
        return this.getStatusIcon(this.status?.isCustomMetadataConfigured);
    }

    get recordLimitIcon() {
        return this.getStatusIcon(this.status?.isRecordLimitConfigured);
    }

    getStatusIcon(isConfigured) {
        return isConfigured ? 'utility:success' : 'utility:error';
    }

    get metadataIconClass() {
        return this.getIconClass(this.status?.isCustomMetadataConfigured);
    }

    get recordLimitIconClass() {
        return this.getIconClass(this.status?.isRecordLimitConfigured);
    }

    getIconClass(isConfigured) {
        return isConfigured ? 'status-button-blue' : 'status-button-red';
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

    showToast(title, message, variant) {
            this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

}