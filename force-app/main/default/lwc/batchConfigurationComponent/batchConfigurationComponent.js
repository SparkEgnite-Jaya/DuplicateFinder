import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getScheduleStatus from '@salesforce/apex/DF_BatchConfigurationController.getScheduleStatus';
import scheduleWeeklyCleanup from '@salesforce/apex/DF_BatchConfigurationController.scheduleWeeklyCleanup';

export default class BatchConfigurationComponent extends LightningElement {
    isButtonDisabled = false;
    isLoading = true;

    connectedCallback() {
        this.getBatchStatus();
    }
  
    handleSchedule() {
        this.isLoading = true;
        scheduleWeeklyCleanup()
            .then((updatedStatus) => {
                this.scheduleStatus = updatedStatus;
                this.showToast('Success', 'Weekly cleanup job scheduled successfully.', 'success');
                this.isButtonDisabled = true;
            })
            .catch((error) => {
                this.showToast('Error', error.body?.message || 'An error occurred.', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    getBatchStatus() {
        this.isLoading = true;
        getScheduleStatus()
            .then(result => {
                this.isButtonDisabled = result.isScheduled;
            })
            .catch(error => {
                this.showToast('Error', error.body?.message || 'An error occurred.', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    handleFinish() {
        this.dispatchEvent(new CustomEvent('finish'));
    }
}