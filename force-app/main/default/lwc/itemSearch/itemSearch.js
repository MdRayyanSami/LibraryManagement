import { LightningElement, track } from 'lwc';
import searchLibraryItems from '@salesforce/apex/LibraryItemController.searchLibraryItems';

export default class ItemSearch extends LightningElement {
    @track searchKey = ''; // Item Name filter
    @track selectedItemType = ''; // Item Type filter
    @track selectedStatus = ''; // Status filter
    @track libraryItems = []; // Results from search
    @track error; // Error handling

    // Combobox options
    itemTypeOptions = [
        { label: 'All', value: '' },
        { label: 'Book', value: 'Book' },
        { label: 'AV Equipment', value: 'AV Equipment' }
    ];

    statusOptions = [
        { label: 'All', value: '' },
        { label: 'Available', value: 'Available' },
        { label: 'Checked Out', value: 'Checked Out' },
        { label: 'Maintenance', value: 'Maintenance' },
        { label: 'Borrowed', value: 'Borrowed' },
        { label: 'Lost', value: 'Lost' }
    ];

    // Datatable columns
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Barcode', fieldName: 'Barcode__c' },
        { label: 'Item Type', fieldName: 'Item_Type__c' },
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'Description', fieldName: 'Description__c' }
    ];

    // Input change handlers
    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
    }

    handleItemTypeChange(event) {
        this.selectedItemType = event.target.value;
    }

    handleStatusChange(event) {
        this.selectedStatus = event.target.value;
    }

    // Handle the Search button click
    handleSearch() {
        searchLibraryItems({ 
            searchKey: this.searchKey, 
            itemType: this.selectedItemType, 
            status: this.selectedStatus 
        })
            .then((result) => {
                this.libraryItems = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.libraryItems = undefined;
            });
    }
}
