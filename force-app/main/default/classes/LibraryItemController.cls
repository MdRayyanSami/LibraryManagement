public with sharing class LibraryItemController {

    /**
     * Fetches library items based on search criteria.
     *
     * @param searchKey Partial name of the library item to search for.
     * @param itemType Type of item (e.g., Book, AV Equipment).
     * @param status Status of the item (e.g., Available, Checked Out).
     * @return List<Library_Item__c> List of library items matching the search criteria.
     */
    @AuraEnabled(cacheable=true)
    public static List<Library_Item__c> searchLibraryItems(String searchKey, String itemType, String status) {
        // Prepare the search key with wildcards
        String searchKeyParam = String.isBlank(searchKey) ? '%%' : '%' + searchKey + '%';
        
        // Build the query with dynamic SOQL
        List<String> whereConditions = new List<String>();
        whereConditions.add('Name LIKE :searchKeyParam');
        
        // Dynamically add optional filters
        if (String.isNotBlank(itemType)) {
            whereConditions.add('Item_Type__c = :itemType');
        }
        if (String.isNotBlank(status)) {
            whereConditions.add('Status__c = :status');
        }
        
        // Construct the full query
        String query = 'SELECT Id, Name, Barcode__c, Item_Type__c, Status__c, Description__c ' +
                       'FROM Library_Item__c ' +
                       'WHERE ' + String.join(whereConditions, ' AND ') + 
                       ' ORDER BY Name ASC';
        
        // Execute the query with improved error handling
        try {
            return Database.query(query);
        } catch (QueryException e) {
            // Log the error or handle it appropriately
            System.debug('Error in searchLibraryItems: ' + e.getMessage());
            return new List<Library_Item__c>();
        }
    }
}
