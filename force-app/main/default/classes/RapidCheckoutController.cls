public with sharing class RapidCheckoutController {
    @AuraEnabled
    public static Borrower__c getBorrowerInfo(String email) {
        return [SELECT Id, Name, Borrowing_Limit__c, Phone_Number__c,
                (SELECT Id FROM Borrowing_Records__r WHERE Status__c IN ('Borrowed', 'Overdue'))
                FROM Borrower__c 
                WHERE Borrower_Email__c = :email 
                LIMIT 1];
    }

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
    public static String validateAndCheckout(String borrowerEmail, String barcode) {
        Savepoint sp = Database.setSavepoint();
        try {
            Borrower__c borrower = [SELECT Id, Borrowing_Limit__c, 
                                    (SELECT Id FROM Borrowing_Records__r WHERE Status__c IN ('Borrowed', 'Overdue'))
                                    FROM Borrower__c 
                                    WHERE Borrower_Email__c = :borrowerEmail 
                                    LIMIT 1];
            if (borrower == null) {
                throw new AuraHandledException('No borrower found with the provided email.');
            }

            Library_Item__c item = [SELECT Id, Status__c, Name 
                                    FROM Library_Item__c 
                                    WHERE Barcode__c = :barcode 
                                    LIMIT 1];
            if (item == null) {
                throw new AuraHandledException('No library item found with the provided barcode.');
            }

            if (item.Status__c == 'Checked Out' || item.Status__c == 'Borrowed') {
                throw new AuraHandledException('The item "' + item.Name + '" is currently checked out and unavailable.');
            } else if (item.Status__c == 'Maintenance') {
                throw new AuraHandledException('This item is currently under maintenance.');
            } else if (item.Status__c == 'Lost') {
                throw new AuraHandledException('This item is marked as lost and cannot be checked out.');
            } else if (item.Status__c != 'Available') {
                throw new AuraHandledException('This item is not available for checkout.');
            }

            if (borrower.Borrowing_Records__r.size() >= borrower.Borrowing_Limit__c) {
                throw new AuraHandledException('Borrower has reached the maximum limit of ' + borrower.Borrowing_Limit__c + ' items.');
            }

            Borrowing_Record__c newRecord = new Borrowing_Record__c(
                Name = 'Checkout ' + item.Name + ' - ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss'),
                Borrower__c = borrower.Id,
                Library_Item__c = item.Id,
                Borrow_Date__c = Date.today(),
                Due_Date__c = Date.today().addDays(7),
                Status__c = 'Borrowed'
            );
            insert newRecord;

            item.Status__c = 'Borrowed';
            update item;

            return 'Success';
        } catch (QueryException e) {
            Database.rollback(sp);
            throw new AuraHandledException('Invalid borrower email or barcode.');
        } catch (DmlException e) {
            Database.rollback(sp);
            throw new AuraHandledException('Database error occurred: ' + e.getMessage());
        } catch (AuraHandledException e) {
            Database.rollback(sp);
            throw e;
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
    }
}
