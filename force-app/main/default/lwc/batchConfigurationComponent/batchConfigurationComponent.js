import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getScheduleStatus from '@salesforce/apex/DF_BatchConfigurationController.getScheduleStatus';
import scheduleWeeklyCleanup from '@salesforce/apex/DF_BatchConfigurationController.scheduleWeeklyCleanup';
//c/duplicateFinderWizardSetupimport removeWeeklyCleanupSchedule from '@salesforce/apex/DF_BatchConfigurationController.removeWeeklyCleanupSchedule';

export default class BatchConfigurationComponent extends LightningElement {
    @track isButtonDisabled = false;
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
                //return refreshApex(this.wiredStatusResult); // clear cache
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
                console.error(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // Call apex to abort/remove the job
  /*  handleRemoveSchedule() {
        this.isLoading = true;
        removeWeeklyCleanupSchedule()
            .then(() => {
                this.showToast('Removed', 'Weekly cleanup job schedule has been removed.', 'info');
                // Manually reset state since removeWeeklyCleanupSchedule returns void
                this.scheduleStatus = { isScheduled: false, status: 'Not Scheduled', nextFireTime: null };
                return refreshApex(this.wiredStatusResult); // clear cache
            })
            .catch((error) => {
                this.showToast('Error', error.body?.message || 'An error occurred.', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    } */

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