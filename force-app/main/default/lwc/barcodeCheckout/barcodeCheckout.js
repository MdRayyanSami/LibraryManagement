import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validateAndCheckout from '@salesforce/apex/RapidCheckoutController.validateAndCheckout';
import getBorrowerInfo from '@salesforce/apex/RapidCheckoutController.getBorrowerInfo';
import fetchBorrowers from '@salesforce/apex/RapidCheckoutController.fetchBorrowers';

export default class RapidCheckout extends LightningElement {
    @track borrowerEmail = '';
    @track barcode = '';
    @track borrowerInfo = null;
    @track isButtonDisabled = true;
    @track borrowerSuggestions = [];
    @track emailError = false;

    handleEmailChange(event) {
        this.borrowerEmail = event.target.value;
        this.emailError = false;
        this.validateInputs();
        this.fetchBorrowerSuggestions(); // Fetch borrower suggestions
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
        this.fetchBorrowerInfo(); // Fetch borrower info after selection
        this.validateInputs();
    }

    handleBarcodeChange(event) {
        this.barcode = event.target.value;
        this.validateInputs();
    }

    validateInputs() {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        this.emailError = this.borrowerEmail && !emailRegex.test(this.borrowerEmail);
        this.isButtonDisabled = this.emailError || !this.borrowerEmail || !this.barcode;
    }

    handleKeyPress(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            if (!this.isButtonDisabled) {
                this.handleCheckout();
            }
        }
    }

    handleSubmit(event) {
        event.preventDefault();
        if (!this.isButtonDisabled) {
            this.handleCheckout();
        }
    }

    async fetchBorrowerInfo() {
        try {
            this.borrowerInfo = await getBorrowerInfo({ email: this.borrowerEmail });
        } catch (error) {
            this.showToast('Error', 'Invalid borrower email', 'error');
            this.borrowerInfo = null;
        }
    }

    async handleCheckout() {
        try {
            const result = await validateAndCheckout({
                borrowerEmail: this.borrowerEmail,
                barcode: this.barcode
            });
            
            this.showToast('Success', 'Item checked out successfully', 'success');
            this.clearForm();
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    clearForm() {
        this.borrowerEmail = '';
        this.barcode = '';
        this.borrowerInfo = null;
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
