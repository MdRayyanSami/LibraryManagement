import { LightningElement, wire, track } from 'lwc';
import getBorrowingRecords from '@salesforce/apex/BorrowingHistoryController.getBorrowingRecords';

export default class BorrowingHistory extends LightningElement {
    @track borrowingRecords;
    @track searchKey = '';
    
    columns = [
        { label: 'Library Item', fieldName: 'itemName', type: 'text' },
        { label: 'Borrower', fieldName: 'borrowerName', type: 'text' },
        { label: 'Email', fieldName: 'borrowerEmail', type: 'email' },
        { label: 'Borrow Date', fieldName: 'borrowDate', type: 'date' },
        { label: 'Return Date', fieldName: 'returnDate', type: 'date' },
        { label: 'Status', fieldName: 'status', type: 'text' }
    ];

    @wire(getBorrowingRecords, { searchKey: '$searchKey' })
    wiredRecords({ error, data }) {
        if (data) {
            this.borrowingRecords = data.map(record => ({
                id: record.Id,
                itemName: record.Library_Item__r.Name,
                borrowerName: record.Borrower__r.Name,
                borrowerEmail: record.Borrower__r.Borrower_Email__c,
                borrowDate: record.Borrow_Date__c,
                returnDate: record.Return_Date__c,
                status: record.Status__c
            }));
        } else if (error) {
            console.error('Error:', error);
        }
    }

    handleSearch(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
        }, 300);
    }
}