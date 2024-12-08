public with sharing class BorrowingRecordController {

    /**
     * Fetches borrowing history for a specific library item.
     *
     * @param libraryItemId ID of the Library Item.
     * @return List<Borrowing_Record__c> Borrowing history records.
     */
    @AuraEnabled(cacheable=true)
    public static List<Borrowing_Record__c> getBorrowingHistory(Id libraryItemId) {
        return [
            SELECT Id, Name, Borrower__r.Name, Borrower__r.Borrower_Email__c,
                   Borrow_Date__c, Due_Date__c, Return_Date__c, Status__c
            FROM Borrowing_Record__c
            WHERE Library_Item__c = :libraryItemId
            ORDER BY Borrow_Date__c DESC
        ];
    }

    /**
     * Fetches currently borrowed items.
     *
     * @return List<Borrowing_Record__c> Currently borrowed items.
     */
    @AuraEnabled(cacheable=true)
    public static List<Borrowing_Record__c> getCurrentlyBorrowedItems() {
        return [
            SELECT Id, Name, Library_Item__r.Name, Borrower__r.Name,
                   Borrow_Date__c, Due_Date__c, Status__c
            FROM Borrowing_Record__c
            WHERE Status__c = 'Borrowed'
        ];
    }
}
