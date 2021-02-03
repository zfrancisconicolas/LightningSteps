public with sharing class LightningSteps_ProductListController {
    /*
     * getProductEntries
     * returns: List ProductEntry
     * apex code called from the lightning web component to retrieve product entries in stock
    */
    @AuraEnabled(cacheable=true)
    public static List<ProductEntry> getProductEntries() {
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
                return parseEntries(pbEntries);
            }
        }
        return null;
    }

    /*
     * parseEntries
     * params: List PricebookEntry pbEntries
     * returns: List ProductEntry
     * code to parse PricebookEntry into ProductEntry
    */
    @TestVisible
    private static List<ProductEntry> parseEntries(List<PriceBookEntry> pbEntries){
        List<ProductEntry> returnEntries = new List<ProductEntry>();
        ProductEntry prodEntry;
        for(PriceBookEntry pbEntry : pbEntries){
            prodEntry = new ProductEntry();
            prodEntry.priceBookId = pbEntry.Pricebook2Id;
            prodEntry.productId = pbEntry.Product2Id;
            prodEntry.unitPrice = pbEntry.UnitPrice;
            prodEntry.productName = pbEntry.Product2.Name;
            prodEntry.productDescription = pbEntry.Product2.Description;
            prodEntry.productCategory = pbEntry.Product2.Category__c;
            prodEntry.productStyle = pbEntry.Product2.Style__c;
            prodEntry.productColor = pbEntry.Product2.Color__c;
            prodEntry.productStock = pbEntry.Product2.Current_Stock__c;
            prodEntry.productInStock = pbEntry.Product2.In_Stock__c;
            prodEntry.productCode = pbEntry.Product2.ProductCode;
            prodEntry.pbEntryId = pbEntry.Id;
            if(pbEntry.Product2.Size__c > 0) {
                prodEntry.productSize = pbEntry.Product2.Size__c;
            }
            returnEntries.add(prodEntry);
        }
        return returnEntries;
    }
}