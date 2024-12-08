trigger BorrowingRecordHelperTrigger on Borrowing_Record__c (before insert, before update) {
    // Map to store borrower and their active borrowing count
    Map<Id, Borrower__c> borrowerMap = new Map<Id, Borrower__c>(
        [SELECT Id, Borrowing_Limit__c, 
                (SELECT Id FROM Borrowing_Records__r WHERE Status__c = 'Borrowed') 
         FROM Borrower__c]
    );

    for (Borrowing_Record__c record : Trigger.new) {
        // Skip limit check for records being returned
        if (record.Status__c == 'Returned') {
            continue;
        }

        if (record.Borrower__c != null) {
            Borrower__c borrower = borrowerMap.get(record.Borrower__c);

            if (borrower != null) {
                Integer activeBorrowings = borrower.Borrowing_Records__r.size();

                // Validate the borrowing limit
                if (activeBorrowings >= borrower.Borrowing_Limit__c) {
                    record.addError('This borrower has reached their borrowing limit.');
                }
            }
        }
    }
}
