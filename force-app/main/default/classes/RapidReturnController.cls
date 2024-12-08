public with sharing class RapidReturnController {

    @AuraEnabled(cacheable=true)
    public static List<Borrower__c> fetchBorrowers(String searchKey) {
        return [
            SELECT Id, Name, Borrower_Email__c 
            FROM Borrower__c 
            WHERE Borrower_Email__c LIKE :('%' + searchKey + '%') 
            LIMIT 5
        ];
    }

    @AuraEnabled
    public static Map<String, Object> validateAndReturn(String borrowerEmail, String barcode) {
        Savepoint sp = Database.setSavepoint();
        try {
            // Get the borrower
            Borrower__c borrower = [
                SELECT Id, Name, 
                    (SELECT Id, Library_Item__c, Due_Date__c, Status__c FROM Borrowing_Records__r WHERE Status__c = 'Borrowed')
                FROM Borrower__c 
                WHERE Borrower_Email__c = :borrowerEmail 
                LIMIT 1
            ];

            // Get the library item
            Library_Item__c item = [
                SELECT Id, Name, Status__c 
                FROM Library_Item__c 
                WHERE Barcode__c = :barcode 
                LIMIT 1
            ];

            // Validate if the item is currently borrowed
            Borrowing_Record__c recordToUpdate = null;
            for (Borrowing_Record__c record : borrower.Borrowing_Records__r) {
                if (record.Library_Item__c == item.Id) {
                    recordToUpdate = record;
                    break;
                }
            }

            if (recordToUpdate == null) {
                throw new AuraHandledException('No matching borrowed record found for the given item and borrower.');
            }

            // Calculate days early/late
            Integer daysEarlyOrLate = Date.today().daysBetween(recordToUpdate.Due_Date__c);

            // Update the borrowing record
            recordToUpdate.Status__c = 'Returned';
            recordToUpdate.Return_Date__c = Date.today();
            update recordToUpdate;

            // Update the library item status
            item.Status__c = 'Available';
            update item;

            return new Map<String, Object>{
                'status' => 'Success',
                'daysEarlyOrLate' => daysEarlyOrLate
            };

        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
}
