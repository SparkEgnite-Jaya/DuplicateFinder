import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getScheduleStatus from '@salesforce/apex/DF_BatchConfigurationController.getScheduleStatus';
import scheduleWeeklyCleanup from '@salesforce/apex/DF_BatchConfigurationController.scheduleWeeklyCleanup';

export default class BatchConfigurationComponent extends LightningElement {
    scheduleStatus;
    isLoading = true;

    get isButtonDisabled() {
        return this.scheduleStatus?.isScheduled;
    }

    connectedCallback() {
        this.getBatchStatus();
    }
  
    handleSchedule() {
        this.isLoading = true;

        scheduleWeeklyCleanup()
            .then((result) => {
                this.scheduleStatus = result;

                if (result.isScheduled) {
                    this.showToast('Success', result.message, 'success');
                } else {
                    this.showToast('Error', result.message, 'error');
                }
            })
            .catch((error) => {
                this.showToast('Error', error.body?.message || 'An unexpected error occurred.', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleRefresh() {
        this.getBatchStatus();
    }

    getBatchStatus() {
        this.isLoading = true;

        getScheduleStatus()
            .then((result) => {
                this.scheduleStatus = result;
            })
            .catch((error) => {
                this.showToast('Error', error.body?.message || 'An unexpected error occurred.', 'error');
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

    get messageClass() {
        if (!this.scheduleStatus?.isScheduled) {
            return 'slds-notify slds-notify_alert slds-theme_warning slds-m-vertical_medium';
        }

        if (this.scheduleStatus.message?.includes('paused')) {
            return 'slds-notify slds-notify_alert slds-theme_warning slds-m-vertical_medium';
        }

        return 'slds-notify slds-notify_alert slds-theme_success slds-m-vertical_medium';
    }
}