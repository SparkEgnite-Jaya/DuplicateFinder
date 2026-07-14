import { LightningElement, track , wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin,CurrentPageReference  } from "lightning/navigation";

export default class DuplicateFinderWizardSetup extends NavigationMixin(LightningElement) {
    @track currentStep = '1'; 

    get isStep1() { return this.currentStep === '1'; }
    get isStep2() { return this.currentStep === '2'; }
    get isStep3() { return this.currentStep === '3'; }
    get isStep4() { return this.currentStep === '4'; }

    handleNext() {
        let nextValue = parseInt(this.currentStep, 10) + 1;
        this.currentStep = nextValue.toString();
    }

    handleBack() {
        let prevValue = parseInt(this.currentStep, 10) - 1;
        this.currentStep = prevValue.toString();
    }

    handleSaveAndNext() {
        this.showToast('Success', 'Configurations saved successfully!', 'success');
        this.handleNext();
    }

    handleStartBatch() {
        this.showToast('Batch Started', 'The maintenance engine processing thread has begun execution.', 'info');
    }

    handleFinish() {
        this.showToast('Setup Complete', 'You have completed the setup wizard.', 'success');
        this.navigateToMainApp();
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    navigateToMainApp() {
        this[NavigationMixin.Navigate]({
            type: 'standard__app',
            attributes: {
                appTarget: 'c__DuplicateFinder'
            }
        });
    }

}