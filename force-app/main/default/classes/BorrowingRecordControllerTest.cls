@isTest
public class BorrowingRecordControllerTest {

    @isTest
    static void testGetBorrowingHistory() {
        // Create sample Library Item
        Library_Item__c libraryItem = new Library_Item__c(
            Name = 'The Great Gatsby',
            Item_Type__c = 'Book',
            Barcode__c = '12345',
            Status__c = 'Available'
        );
        insert libraryItem;

        // Create sample Borrower
        Borrower__c borrower = new Borrower__c(
            Name = 'John Doe',
            Borrower_Email__c = 'john.doe@example.com',
            Phone_Number__c = '1234567890',
            Borrowing_Limit__c = 5
        );
        insert borrower;

        // Create sample Borrowing Records
        Borrowing_Record__c record1 = new Borrowing_Record__c(
            Name = 'Record 1',
            Library_Item__c = libraryItem.Id,
            Borrower__c = borrower.Id,
            Borrow_Date__c = Date.today().addDays(-10),
            Due_Date__c = Date.today().addDays(-3),
            Return_Date__c = Date.today(),
            Status__c = 'Returned'
        );

        Borrowing_Record__c record2 = new Borrowing_Record__c(
            Name = 'Record 2',
            Library_Item__c = libraryItem.Id,
            Borrower__c = borrower.Id,
            Borrow_Date__c = Date.today().addDays(-5),
            Due_Date__c = Date.today().addDays(5),
            Status__c = 'Borrowed'
        );

        insert new List<Borrowing_Record__c>{ record1, record2 };

        // Add Checkpoint for Verification
        System.debug(LoggingLevel.INFO, 'Checkpoint: Borrowing Records Inserted');

        // Test Borrowing History
        Test.startTest();
        List<Borrowing_Record__c> borrowingHistory = BorrowingRecordController.getBorrowingHistory(libraryItem.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(2, borrowingHistory.size(), 'History should return 2 records');
        System.assertEquals('Record 2', borrowingHistory[0].Name, 'Latest record should be first');

        // Success Message
        System.debug(LoggingLevel.INFO, 'Success: testGetBorrowingHistory passed.');
    }

    @isTest
    static void testGetCurrentlyBorrowedItems() {
        // Create sample Library Item
        Library_Item__c libraryItem = new Library_Item__c(
            Name = 'The Catcher in the Rye',
            Item_Type__c = 'Book',
            Barcode__c = '67890',
            Status__c = 'Available'
        );
        insert libraryItem;

        // Create sample Borrower
        Borrower__c borrower = new Borrower__c(
            Name = 'Jane Smith',
            Borrower_Email__c = 'jane.smith@example.com',
            Phone_Number__c = '9876543210',
            Borrowing_Limit__c = 3
        );
        insert borrower;

        // Create a Borrowing Record
        Borrowing_Record__c borrowedRecord = new Borrowing_Record__c(
            Name = 'Borrowed Record',
            Library_Item__c = libraryItem.Id,
            Borrower__c = borrower.Id,
            Borrow_Date__c = Date.today(),
            Due_Date__c = Date.today().addDays(10),
            Status__c = 'Borrowed'
        );

        insert borrowedRecord;

        // Add Checkpoint for Verification
        System.debug(LoggingLevel.INFO, 'Checkpoint: Borrowed Record Inserted');

        // Test Currently Borrowed Items
        Test.startTest();
        List<Borrowing_Record__c> currentlyBorrowed = BorrowingRecordController.getCurrentlyBorrowedItems();
        Test.stopTest();

        // Assertions
        System.assertEquals(1, currentlyBorrowed.size(), 'Should return 1 borrowed item');
        System.assertEquals('Borrowed Record', currentlyBorrowed[0].Name, 'Record name should match');

        // Success Message
        System.debug(LoggingLevel.INFO, 'Success: testGetCurrentlyBorrowedItems passed.');
    }
}
