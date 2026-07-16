import { LightningElement } from 'lwc';
import getPrerequisitesStepStatus from '@salesforce/apex/PrerequisitesComponentController.getPrerequisitesStepStatus';

export default class PrerequisitesComponent extends LightningElement {

    status;
    isLoading = true;

    get disableNext() {
        return this.isLoading || !(
                this.status?.isPermissionSetAssigned &&
                this.status?.isAgentActive);
    }

    connectedCallback() {
        this.loadPrerequisiteStatus();
    }

    loadPrerequisiteStatus() {
        this.isLoading = true;

        getPrerequisitesStepStatus()
            .then(result => {
               this.status = result;
            })
            .catch(error => {
                this.showToast('Error', error.body?.message || 'An error occurred.', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleRefresh() {
       this.loadPrerequisiteStatus();
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

    get metadataStatus() {
        console.log('metadataStatus', this.status.isPermissionSetAssigned);
        return this.status?.isPermissionSetAssigned
            ? 'Configured'
            : 'Not Configured';
    }

    get recordLimitStatus() {

        if(!this.status?.isAgentActive){
            return 'Not Configured';
        }

        return 'Configured';
    }

    get metadataIcon() {
        return this.getStatusIcon(this.status?.isPermissionSetAssigned);
    }

    get recordLimitIcon() {
        return this.getStatusIcon(this.status?.isAgentActive);
    }

    getStatusIcon(isConfigured) {
        return isConfigured ? 'utility:success' : 'utility:error';
    }

    get metadataIconClass() {
        return this.getIconClass(this.status?.isPermissionSetAssigned);
    }

    get recordLimitIconClass() {
        return this.getIconClass(this.status?.isAgentActive);
    }

    getIconClass(isConfigured) {
        return isConfigured ? 'status-button-blue' : 'status-button-red';
    }
}