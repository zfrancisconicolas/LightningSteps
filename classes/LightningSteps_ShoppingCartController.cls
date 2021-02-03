public with sharing class LightningSteps_ShoppingCartController {
    /*
     * retrieveAccounts
     * returns: List Account
     * apex code called from the lightning web component to retrieve all available accounts
    */
    @AuraEnabled(cacheable=true)
    public static List<Account> retrieveAccounts(){
        return [SELECT Id, Name FROM Account];
    }

    /*
     * createOrders
     * params: String entryList, String accountId
     * returns: true if successfull
     * apex code called from the lightning web component to insert orders, order items and modify product stock
    */
    @AuraEnabled
    public static Boolean createOrders(String entryList, String accountId) {
        Boolean success = true;
        List<LightningSteps_Log__c> errorLogs = new List<LightningSteps_Log__c>();
        String currentPricebook;
        if(entryList != null && accountId != null){
            List<ProductEntry> entries = (List<ProductEntry>) JSON.deserialize(entryList,  List<ProductEntry>.class);
            Set<Id> productIds = new Set<Id>();
            Map<Id, Decimal> productsSold = new Map<Id, Decimal>();
            List<Product2> productsToUpdate = new List<Product2>();
            List<OrderItem> orderItems = new List<OrderItem>();

            Account selectedAccount = [
                SELECT Id, Name, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,
                    ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet
                FROM Account
                WHERE Id = :accountId
            ];

            for(ProductEntry entry : entries){
                currentPricebook = entry.priceBookId;
                productIds.add(entry.productId);
                productsSold.put(entry.productId, entry.quantityNeeded);
            }

            List<Product2> products = [
                SELECT Id, Current_Stock__c 
                FROM Product2
                WHERE Id IN :productIds
            ];

            Savepoint sp = Database.setSavepoint();

            Order finalOrder = newOrder(currentPricebook, selectedAccount);

            Database.SaveResult[] saveResultList = Database.insert(new List<Order> { finalOrder }, false);
            for (Database.SaveResult sr : saveResultList) {
                if (!sr.isSuccess()) {
                    errorLogs.addAll(createErrorLog(sr, 'Order'));
                    success = false;
                }
            }

            orderItems = newOrderItems(entries, finalOrder.Id);

            if(success){
                if(!orderItems.isEmpty()){
                    Database.SaveResult[] orderItemResult = Database.insert(orderItems, false);
                    for (Database.SaveResult sr : orderItemResult) {
                        if (!sr.isSuccess()) {
                            errorLogs.addAll(createErrorLog(sr, 'Order Item'));
                            success = false;
                        }
                    }
    
                    productsToUpdate = updateProducts(products, productsSold);
    
                    Database.SaveResult[] productResult = Database.update(productsToUpdate, false);
                    for (Database.SaveResult sr : productResult) {
                        if (!sr.isSuccess()) {
                            errorLogs.addAll(createErrorLog(sr, 'Product'));
                            success = false;
                        }
                    }
                    if(!success){
                        Database.rollback(sp);
                    }
                }
            }
            
            if(!errorLogs.isEmpty()){
                insert errorLogs;
            }
        }
        return success;
    }

    /*
     * createErrorLog
     * params: SaveResult sr, String objectName
     * returns: List LightningSteps_Log__c
     * creates error logs when DML transactions fail
    */
    private static List<LightningSteps_Log__c> createErrorLog(Database.SaveResult sr, String objectName){
        List<LightningSteps_Log__c> errorLogs = new List<LightningSteps_Log__c>();
        for(Database.Error err : sr.getErrors()) {
            errorLogs.add(new LightningSteps_Log__c(
                Error_Message__c = 'The following error has occurred. \n' + err.getMessage() + '\n' + objectName + ' fields that affected this error: ' + err.getFields()
            ));
        }
        return errorLogs;
    }

    /*
     * newOrderItems
     * params: List ProductEntry, Id orderId
     * returns: List OrderItem
     * creates order item records from product entries
    */
    private static List<OrderItem> newOrderItems(List<ProductEntry> entries, Id orderId){
        List<OrderItem> orderItems = new List<OrderItem>();
        for(ProductEntry entry : entries){
            orderItems.add(
                new OrderItem(
                    UnitPrice = entry.unitPrice,
                    Quantity = entry.quantityNeeded,
                    Product2Id = entry.productId,
                    OrderId = orderId,
                    Description = entry.productDescription,
                    PricebookEntryId = entry.pbEntryId
                )
            );
        }
        return orderItems;
    }

    /*
     * newOrder
     * params: Id currentPricebook, Account selectedAccount
     * returns: Order
     * creates order records
    */
    private static Order newOrder(Id currentPricebook, Account selectedAccount){
        return new Order(
            Description = 'Order placed on ' + Date.today(),
            Name = 'LS-' + selectedAccount.Name + '-' + Date.today(),
            AccountId = selectedAccount.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = currentPricebook,
            BillingCity = selectedAccount.BillingCity, 
            BillingCountry = selectedAccount.BillingCountry, 
            BillingPostalCode =selectedAccount.BillingPostalCode, 
            BillingState = selectedAccount.BillingState, 
            BillingStreet = selectedAccount.BillingStreet,
            ShippingCity = selectedAccount.ShippingCity, 
            ShippingCountry = selectedAccount.ShippingCountry, 
            ShippingPostalCode = selectedAccount.ShippingPostalCode, 
            ShippingState = selectedAccount.ShippingState, 
            ShippingStreet = selectedAccount.ShippingStreet
        );
    }

    /*
     * updateProducts
     * params: List Product2, Map (Id, Decimal) productsSold
     * returns: List Product2
     * updates products to remove available stock upon a sale
    */
    private static List<Product2> updateProducts(List<Product2> products, Map<Id, Decimal> productsSold){
        List<Product2> productsToUpdate = new List<Product2>();
        for(Product2 prod : products){
            if(productsSold.containsKey(prod.Id)){
                prod.Current_Stock__c -= productsSold.get(prod.Id);
                productsToUpdate.add(prod);
            }
        }
        return productsToUpdate;
    }
}