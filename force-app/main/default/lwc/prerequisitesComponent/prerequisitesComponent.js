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
        this.loadStatus();
    }

    loadStatus() {
        this.isLoading = true;

        getPrerequisitesStepStatus()
            .then(result => {
                this.permissionDone = result.isPermissionSetAssigned;
                this.agentDone = result.isAgentActive;
            })
            .catch(error => {
                console.error(error);
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

   /* get hidePermissionCheckbox(){
        return this.permissionDone ? true : false;
    }

    get hideAgentCheckbox(){
        return this.agentDone ? 'hide-checkbox' : '';
    }

    get permissionClass(){
        return this.permissionDone ? 'status-blue' : '';
    }

    get agentClass(){
        return this.agentDone ? 'status-blue' : '';
    }*/

}