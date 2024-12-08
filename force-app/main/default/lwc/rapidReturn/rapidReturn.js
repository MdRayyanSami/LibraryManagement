import { LightningElement, track } from 'lwc';
import validateAndReturn from '@salesforce/apex/RapidReturnController.validateAndReturn';
import fetchBorrowers from '@salesforce/apex/RapidReturnController.fetchBorrowers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RapidReturn extends LightningElement {
    @track borrowerEmail = '';
    @track barcode = '';
    @track returnMessage = '';
    @track borrowerSuggestions = [];
    @track emailError = false;
    @track returnInfo = '';

    // Getter for computing email input class
    get computeEmailClass() {
        return this.emailError ? 'slds-has-error' : '';
    }

    handleEmailChange(event) {
        this.borrowerEmail = event.target.value;
        this.emailError = false;
        this.validateInputs();
        this.fetchBorrowerSuggestions(); // Fetch suggestions as email changes
    }

    async fetchBorrowerSuggestions() {
        if (this.borrowerEmail.length < 3) {
            this.borrowerSuggestions = [];
            return;
        }
        try {
            const results = await fetchBorrowers({ searchKey: this.borrowerEmail });
            this.borrowerSuggestions = results;
        } catch (error) {
            console.error('Error fetching borrower suggestions:', error);
        }
    }

    handleBorrowerSelect(event) {
        const selectedBorrower = event.currentTarget.dataset.value;
        this.borrowerEmail = selectedBorrower;
        this.borrowerSuggestions = [];
        this.validateInputs();
    }

    handleBarcodeChange(event) {
        this.barcode = event.target.value;
        this.validateInputs();
    }

    validateInputs() {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        this.emailError = this.borrowerEmail && !emailRegex.test(this.borrowerEmail);
    }

    // Handle Enter key press for Return action
    handleKeyPress(event) {
        if (event.key === 'Enter' && !this.isButtonDisabled) {
            this.handleReturn();
        }
    }

    async handleReturn() {
        try {
            const result = await validateAndReturn({
                borrowerEmail: this.borrowerEmail,
                barcode: this.barcode
            });

            this.returnInfo = `The book was returned ${
                result.daysEarlyOrLate > 0 ? `${result.daysEarlyOrLate} days late` : `${Math.abs(result.daysEarlyOrLate)} days early`
            }.`;
            this.returnMessage = 'Item successfully returned.';
            this.showToast('Success', this.returnMessage, 'success');
            this.clearForm();
        } catch (error) {
            this.returnMessage = error.body ? error.body.message : 'An error occurred.';
            this.showToast('Error', this.returnMessage, 'error');
        }
    }

    // Computed property for button disabled state
    get isButtonDisabled() {
        return this.emailError || !this.borrowerEmail || !this.barcode;
    }

    clearForm() {
        this.borrowerEmail = '';
        this.barcode = '';
        this.returnMessage = '';
        this.returnInfo = '';
        this.borrowerSuggestions = [];
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}
