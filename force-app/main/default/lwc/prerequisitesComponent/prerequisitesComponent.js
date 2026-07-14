import { LightningElement } from 'lwc';
import getPrerequisitesStepStatus from '@salesforce/apex/PrerequisitesComponentController.getPrerequisitesStepStatus';

export default class PrerequisitesComponent extends LightningElement {

    permissionDone = false;
    agentDone = false;
    isLoading = true;

    get disableNext() {
        return this.isLoading || !(this.permissionDone && this.agentDone);
    }

    connectedCallback() {
        this.loadPrerequisiteStatus();
    }

    loadPrerequisiteStatus() {
        this.isLoading = true;

        getPrerequisitesStepStatus()
            .then(result => {
                console.log('result', result);
                this.permissionDone = result.isPermissionSetAssigned;
                this.agentDone = result.isAgentActive;
            })
            .catch(error => {
                this.showToast('Error', error.body?.message || 'An error occurred.', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
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