/*
 * WRAPPER CLASS FOR THE LIGHTNING STEPS APP
*/

public class ProductEntry {
    @AuraEnabled
    public Id productId;
    @AuraEnabled
    public Decimal unitPrice;
    @AuraEnabled
    public String productName;
    @AuraEnabled
    public String productCode;
    @AuraEnabled
    public String pbEntryId;
    @AuraEnabled
    public String priceBookId;
    @AuraEnabled
    public String productDescription;
    @AuraEnabled
    public String productCategory;
    @AuraEnabled
    public String productStyle;
    @AuraEnabled
    public String productColor;
    @AuraEnabled
    public Decimal productStock;
    @AuraEnabled
    public Boolean productInStock;
    @AuraEnabled
    public Decimal productSize = 0;
    @AuraEnabled
    public Decimal quantityNeeded;
    
    
    /*
     * parseEntries
     * params: List PricebookEntry pbEntries
     * returns: List ProductEntry
     * code to parse PricebookEntry into ProductEntry
    */
    public static List<ProductEntry> parseEntries(List<PriceBookEntry> pbEntries){
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