import { LightningElement,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ShowDuplicateRecords extends NavigationMixin(LightningElement) {

    duplicateRecords = [];

    @api
    get value() {
        return this._value;
    }

    set value(value) {
        this._value = value;
    }

    connectedCallback() {
        this.duplicateRecords = this.value.lstDuplicateRecordInfo;
    }

    handleViewRecord(event) {
        const recordId = event.target.dataset.id;
        window.open('/' + recordId, '_blank');
    }

}