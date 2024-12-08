public with sharing class OverdueReminderService {

    @AuraEnabled
    public static void sendOverdueReminders() {
        // Debug log at the start of the method
        System.debug('DEBUG: Entering sendOverdueReminders method');
        
        try {
            // Query overdue borrowing records
            List<Borrowing_Record__c> overdueRecords = [
                SELECT Id, Borrower__r.Name, Borrower__r.Borrower_Email__c, 
                       Library_Item__r.Name, Borrow_Date__c, Due_Date__c 
                FROM Borrowing_Record__c
                WHERE Status__c = 'Overdue' 
                AND Borrower__r.Borrower_Email__c != null
            ];

            // Debug log number of overdue records
            System.debug('DEBUG: Found ' + overdueRecords.size() + ' overdue records');

            // If there are overdue records, process them
            if (!overdueRecords.isEmpty()) {
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                
                for (Borrowing_Record__c record : overdueRecords) {
                    // Debug log for each overdue record
                    System.debug('DEBUG: Processing overdue record for ' + record.Borrower__r.Name);
                    
                    // Create an email message
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] { record.Borrower__r.Borrower_Email__c });
                    email.setSubject('Reminder: Overdue Library Item');
                    email.setPlainTextBody('Hello ' + record.Borrower__r.Name + ',\n\n' +
                                           'This is a reminder that the following library item is overdue:\n\n' +
                                           'Item: ' + record.Library_Item__r.Name + '\n' +
                                           'Borrow Date: ' + record.Borrow_Date__c + '\n' +
                                           'Due Date: ' + record.Due_Date__c + '\n\n' +
                                           'Please return the item at your earliest convenience.\n\n' +
                                           'Thank you,\nLibrary Management System');
                    emails.add(email);
                    
                    // Debug log email creation
                    System.debug('DEBUG: Email created for ' + record.Borrower__r.Name);
                }

                // Send all emails in bulk
                if (!emails.isEmpty()) {
                    Messaging.sendEmail(emails);
                    
                    // Debug log email sending
                    System.debug('DEBUG: Emails sent successfully');
                }
            } else {
                System.debug('DEBUG: No overdue records found to process');
            }
        } catch (Exception e) {
            // Comprehensive error logging
            System.debug('ERROR: Exception in sendOverdueReminders');
            System.debug('ERROR Message: ' + e.getMessage());
            System.debug('ERROR Stack Trace: ' + e.getStackTraceString());
            
            // Optionally rethrow or handle the exception
            throw new AuraHandledException('Error sending overdue reminders: ' + e.getMessage());
        }
        
        // Final debug log
        System.debug('DEBUG: Exiting sendOverdueReminders method');
    }
}