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
}