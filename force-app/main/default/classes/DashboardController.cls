// DashboardController.apex
public with sharing class DashboardController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDashboardData() {
        Map<String, Object> dashboardData = new Map<String, Object>();

        // Total Borrowed Items
        Integer totalBorrowed = [SELECT COUNT() FROM Borrowing_Record__c WHERE Status__c = 'Borrowed'];

        // Overdue Items
        Integer overdueItems = [SELECT COUNT() FROM Borrowing_Record__c WHERE Status__c = 'Overdue'];

        // Items Available for Borrowing
        Integer availableItems = [SELECT COUNT() FROM Library_Item__c WHERE Status__c = 'Available'];

        // Most Borrowed Items
        List<Map<String, Object>> mostBorrowedList = new List<Map<String, Object>>();
        for (AggregateResult result : [
            SELECT Library_Item__r.Name name, COUNT(Id) totalBorrowedCount
            FROM Borrowing_Record__c
            GROUP BY Library_Item__r.Name
            ORDER BY COUNT(Id) DESC
            LIMIT 3
        ]) {
            mostBorrowedList.add(new Map<String, Object>{
                'name' => (String)result.get('name'),
                'count' => ((Long)result.get('totalBorrowedCount')).intValue()
            });
        }

        // Top Borrowers
        List<Map<String, Object>> topBorrowersList = new List<Map<String, Object>>();
        for (AggregateResult result : [
            SELECT Borrower__r.Name name, COUNT(Id) totalBorrowerCount
            FROM Borrowing_Record__c
            GROUP BY Borrower__r.Name
            ORDER BY COUNT(Id) DESC
            LIMIT 3
        ]) {
            topBorrowersList.add(new Map<String, Object>{
                'name' => (String)result.get('name'),
                'count' => ((Long)result.get('totalBorrowerCount')).intValue()
            });
        }

        dashboardData.put('totalBorrowed', totalBorrowed);
        dashboardData.put('overdueItems', overdueItems);
        dashboardData.put('availableItems', availableItems);
        dashboardData.put('mostBorrowed', mostBorrowedList);
        dashboardData.put('topBorrowers', topBorrowersList);

        return dashboardData;
    }
}