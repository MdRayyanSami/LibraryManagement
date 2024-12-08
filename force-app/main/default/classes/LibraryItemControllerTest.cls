@isTest
public class LibraryItemControllerTest {
    @isTest
    static void SearchLibraryItems() {
        // Create sample data
        Library_Item__c item1 = new Library_Item__c(
            Name = 'Test Book 1', 
            Barcode__c = '12345', 
            Item_Type__c = 'Book', 
            Status__c = 'Available'
        );
        Library_Item__c item2 = new Library_Item__c(
            Name = 'Test Equipment 1', 
            Barcode__c = '67890', 
            Item_Type__c = 'AV Equipment', 
            Status__c = 'Checked Out'
        );
        insert new List<Library_Item__c>{ item1, item2 };

        // Test the method
        Test.startTest();
        List<Library_Item__c> results = LibraryItemController.searchLibraryItems('Test', 'Book', 'Available');
        Test.stopTest();

        // Assertions
        System.assertEquals(1, results.size(), 'Should return one matching library item.');
        System.assertEquals('Test Book 1', results[0].Name, 'Returned item name should match expected.');
    }
}
