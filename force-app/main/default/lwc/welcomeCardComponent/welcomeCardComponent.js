import { LightningElement } from 'lwc';

export default class WelcomeCardComponent extends LightningElement {

    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

}