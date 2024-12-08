import { LightningElement, track } from 'lwc';
import getChatbotResponse from '@salesforce/apex/OpenAIIntegration.getChatbotResponse';

export default class LibraryAssistant extends LightningElement {
    @track messages = [];
    userInput = '';
    messageCounter = 0;

    handleInputChange(event) {
        this.userInput = event.target.value;
    }

    // New method to handle Enter key press
    handleKeyPress(event) {
        // Check if the pressed key is Enter (key code 13)
        if (event.keyCode === 13) {
            this.handleSendMessage();
        }
    }

    handleSendMessage() {
        if (this.userInput.trim() === '') {
            return;
        }

        // Add user's message to the chat
        this.addMessage('user', this.userInput);

        // Process bot response
        this.processBotResponse(this.userInput);

        // Clear the input field
        this.userInput = '';
        
        // Scroll to bottom after new message
        this.scrollToBottom();
    }

    processBotResponse(userInput) {
        // Call Apex method to get OpenAI response
        getChatbotResponse({
            prompt: userInput
        })
        .then(response => {
            // Add bot's response with styling
            const botStyle = 'background-color: #e8f5e9; margin-right: auto; max-width: 70%;';
            this.addMessage('bot', response, botStyle);
        })
        .catch(error => {
            console.error('Error getting bot response:', error);
            this.addMessage('bot', 'Sorry, there was an error processing your request.', 
                'background-color: #e8f5e9; margin-right: auto; max-width: 70%;');
        });
    }

    addMessage(type, text, style) {
        const messageStyle = type === 'user' 
            ? 'background-color: #e3f2fd; margin-left: auto; max-width: 70%;'
            : style || 'background-color: #e8f5e9; margin-right: auto; max-width: 70%;';

        this.messages = [
            ...this.messages,
            {
                id: ++this.messageCounter,
                type,
                text,
                style: messageStyle
            }
        ];
    }

    scrollToBottom() {
        const chatContainer = this.template.querySelector('.chat-container');
        if (chatContainer) {
            setTimeout(() => {
                chatContainer.scrollTop = chatContainer.scrollHeight;
            }, 100);
        }
    }
}