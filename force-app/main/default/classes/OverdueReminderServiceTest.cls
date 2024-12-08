@isTest
public class OverdueReminderServiceTest {

    @isTest
    static void testSendOverdueReminders() {
        // Create a sample borrower
        Borrower__c borrower = new Borrower__c(
            Name = 'Harry Jain',
            Borrower_Email__c = 'jain.harry@example.com',
            Phone_Number__c = '9871234560',
            Borrowing_Limit__c = 5
        );
        insert borrower;

        // Create a sample library item
        Library_Item__c libraryItem = new Library_Item__c(
            Name = 'The Great Harry', 
            Barcode__c = '67892', 
            Item_Type__c = 'Book', 
            Status__c = 'Borrowed',
            Description__c = 'Test Description'
        );
        insert libraryItem;

        // Create an overdue borrowing record
        Borrowing_Record__c overdueRecord = new Borrowing_Record__c(
            Borrower__c = borrower.Id,
            Library_Item__c = libraryItem.Id,
            Borrow_Date__c = Date.today().addDays(-15),
            Due_Date__c = Date.today().addDays(-7),
            Status__c = 'Overdue'
        );
        insert overdueRecord;

        // Start test context
        Test.startTest();
        
        // Debug log before method call
        System.debug('DEBUG: Attempting to send overdue reminders');
        
        // Simulate email sending
        OverdueReminderService.sendOverdueReminders();
        
        // Debug log after method call
        System.debug('DEBUG: Overdue reminders method completed');
        
        Test.stopTest();
    }
}