public with sharing class BorrowingHistoryController {
    @AuraEnabled(cacheable=true)
    public static List<Borrowing_Record__c> getBorrowingRecords(String searchKey) {
        if (String.isNotBlank(searchKey)) {
            String searchPattern = '%' + String.escapeSingleQuotes(searchKey) + '%';
            return [
                SELECT Id, 
                       Library_Item__r.Name, 
                       Borrower__r.Name, 
                       Borrower__r.Borrower_Email__c, 
                       Borrow_Date__c, 
                       Return_Date__c, 
                       Status__c
                FROM Borrowing_Record__c
                WHERE Borrower__r.Name LIKE :searchPattern
                ORDER BY Borrow_Date__c DESC
            ];
        } else {
            return [
                SELECT Id, 
                       Library_Item__r.Name, 
                       Borrower__r.Name, 
                       Borrower__r.Borrower_Email__c, 
                       Borrow_Date__c, 
                       Return_Date__c, 
                       Status__c
                FROM Borrowing_Record__c
                WHERE Status__c IN ('Borrowed', 'Overdue')
                ORDER BY Borrow_Date__c DESC
            ];
        }
    }
}