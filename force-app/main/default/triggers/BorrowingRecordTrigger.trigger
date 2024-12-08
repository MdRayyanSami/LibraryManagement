trigger BorrowingRecordTrigger on Borrowing_Record__c (before insert, before update) {
    // Collect library item IDs from borrowing records being processed
    Set<Id> libraryItemIds = new Set<Id>();
    for (Borrowing_Record__c record : Trigger.new) {
        if (record.Library_Item__c != null) {
            libraryItemIds.add(record.Library_Item__c);
        }
    }

    // Query for current statuses of the library items
    Map<Id, Library_Item__c> libraryItemMap = new Map<Id, Library_Item__c>(
        [SELECT Id, Status__c FROM Library_Item__c WHERE Id IN :libraryItemIds]
    );

    // Validate borrowing conditions
    for (Borrowing_Record__c record : Trigger.new) {
        if (record.Status__c == 'Borrowed') {
            Library_Item__c libraryItem = libraryItemMap.get(record.Library_Item__c);
            if (libraryItem != null && libraryItem.Status__c == 'Checked Out') {
                record.addError('This item is already checked out and cannot be borrowed again.');
            }
        }
    }
}
