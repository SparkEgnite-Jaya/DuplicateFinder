import { LightningElement,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Showduplicateobjectrecords extends NavigationMixin(LightningElement) {

    duplicateRecords = [];
    
        @api
        get value() {
              console.log('Inside get value');
            return this._value;
        }
    
        set value(value) {
            console.log('Inside set value');
            this._value = value;
    
            console.log(
                'Agent Data:',
                JSON.stringify(value)
            );
    
            
        }
    
         connectedCallback() {
              console.log('Before this.value :: ' , JSON.stringify( this.value));
             console.log('Before lwc called :: ' , JSON.stringify( this.duplicateRecords));
            this.duplicateRecords = this.value.lstDuplicateRecordInfo;
               console.log('After lwc called :: ' , JSON.stringify( this.duplicateRecords));
         }

        /*handleViewRecord(event) {
            console.log('handleViewRecord:: ');
            const recordId = event.target.dataset.id;
               console.log('handleViewRecord:: ' + recordId);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    objectApiName: 'Account',
                    actionName: 'view'
                }
            });
        }*/

    handleViewRecord(event) {
         console.log('handleViewRecord:: ');
            const recordId = event.target.dataset.id;
               console.log('handleViewRecord:: ' + recordId);
        window.open('/' + recordId, '_blank');
    }

}