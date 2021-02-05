public with sharing class LightningSteps_ProductListController {
    /*
     * getProductEntries
     * returns: List ProductEntry
     * apex code called from the lightning web component to retrieve product entries in stock
    */
    @AuraEnabled(cacheable=true)
    public static List<ProductEntry> getProductEntries() {
        List<ProductEntry> productEntries = new List<ProductEntry>();
        List<PriceBookEntry> pbEntries = new List<PriceBookEntry>();
        
        Pricebook2 pb2 = [
            SELECT Id
            FROM Pricebook2
            WHERE IsStandard = true
            LIMIT 1
        ];

        if(pb2 != null){
            pbEntries = [
                SELECT Id, Product2Id, UnitPrice, Product2.Name, Product2.Description, Product2.Category__c, 
                    Product2.Style__c, Product2.Color__c, Product2.Current_Stock__c, Product2.In_Stock__c, 
                    Product2.ProductCode, Pricebook2Id, Product2.Size__c
                FROM PriceBookEntry
                WHERE Pricebook2Id = :pb2.Id
                AND Product2.IsActive = true
                AND Product2.In_Stock__c = true
            ];

            if(!pbEntries.isEmpty()){
                productEntries = ProductEntry.parseEntries(pbEntries);
                return productEntries;
            }
        }
        return null;
    }
}
