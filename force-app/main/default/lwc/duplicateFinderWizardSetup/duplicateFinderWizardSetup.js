import { LightningElement, track , wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { NavigationMixin,CurrentPageReference  } from "lightning/navigation";

export default class DuplicateFinderWizardSetup extends NavigationMixin(LightningElement) {
    @track currentStep = '1';  // 1

    // Getter flags to dynamically show/hide content blocks smoothly
    get isStep1() { return this.currentStep === '1'; }
    get isStep2() { return this.currentStep === '2'; }
    get isStep3() { return this.currentStep === '3'; }
    get isStep4() { return this.currentStep === '4'; }

    handleNext() {
        let nextValue = parseInt(this.currentStep, 10) + 1;
        this.currentStep = nextValue.toString();
    }

    handleBack() {
        console.log('inside Back :: ');
        let prevValue = parseInt(this.currentStep, 10) - 1;
        console.log('prevValue :: ', prevValue);
        this.currentStep = prevValue.toString();
        console.log('currentStep :: ', this.currentStep);
    }

    handleSaveAndNext() {
        // Add your Apex call here to save your Custom Settings records!
        // Once successful promise returns, advance the view step:
        this.showToast('Success', 'Configurations saved successfully!', 'success');
        this.handleNext();
    }

    handleStartBatch() {
        // Add your Apex call here to run: Database.executeBatch(new DF_DeleteOldCustomFieldHistoryBatch());
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
        // Replace 'c__MyCustomApp' with your actual Custom App's Developer Name
        this[NavigationMixin.Navigate]({
            type: 'standard__app',
            attributes: {
                appTarget: 'c__DuplicateFinder'
            }
        });
    }

}