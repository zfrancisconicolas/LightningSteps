@IsTest
public class LightningSteps_ShoppingCartCtrlTest {   
    private static Id pricebookId = Test.getStandardPricebookId();
    @TestSetup
    static void testData(){
        List<Product2> products = new List<Product2>();
        List<PricebookEntry> pbEntries = new List<PricebookEntry>();

        insert new Account(
            Name = 'Francisco Zanotti',
            BillingCity = 'Buenos Aires', 
            BillingCountry = 'Argentina', 
            BillingPostalCode = '1870', 
            BillingState = 'Buenos Aires', 
            BillingStreet = 'Fake Street 102', 
            ShippingCity = 'Buenos Aires', 
            ShippingCountry = 'Argentina', 
            ShippingPostalCode = '1870', 
            ShippingState = 'Buenos Aires', 
            ShippingStreet = 'Fake Street 102'
        );

        Product2 whivs002 = new Product2(
            Name = 'White Vinyl Sneaker',
            ProductCode = 'WHIVS-002',
            Description = 'White sneakers for kids',
            isActive = true,
            Category__c = 'Kid Shoes',
            Style__c = 'Sneakers',
            Color__c = 'White',
            Size__c = 20,
            Current_Stock__c = 21 
        );

        Product2 blals001 = new Product2(
            Name = 'Black Leather Shoe',
            ProductCode = 'BLALS-001',
            Description = 'Black leather shoes great for the office',
            isActive = true,
            Category__c = 'Men Shoes',
            Style__c = 'Business',
            Color__c = 'Black',
            Size__c = 40,
            Current_Stock__c = 25 
        );

        products.add(whivs002);
        products.add(blals001);

        insert products;

        PricebookEntry blals001Entry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = blals001.Id,
            UnitPrice = 110, 
            IsActive = true
        );

        PricebookEntry whivs002Entry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = whivs002.Id,
            UnitPrice = 200, 
            IsActive = true
        );

        pbEntries.add(whivs002Entry);
        pbEntries.add(blals001Entry);

        insert pbEntries;
    }


    /*
     *  createOrdersTest
     *  Tests a successful order and order item creation and product update
    */
    @isTest
    static void createOrdersTest(){
        Account selectedAccount = [SELECT Id FROM Account LIMIT 1];

        List<PriceBookEntry> pbEntries = [
            SELECT Id, Product2Id, UnitPrice, Product2.Name, Product2.Description, Product2.Category__c, Pricebook2Id,
                Product2.Style__c, Product2.Color__c, Product2.Current_Stock__c, Product2.In_Stock__c, Product2.Size__c, Product2.ProductCode
            FROM PriceBookEntry
            WHERE Pricebook2Id = :pricebookId
            AND Product2.IsActive = true
            AND Product2.In_Stock__c = true
        ];

        List<ProductEntry> productEntries = LightningSteps_ProductListController.parseEntries(pbEntries);

        //SETTING THE QUANTITY SOLD
        for(ProductEntry prodEntry : productEntries){
            prodEntry.quantityNeeded = 5;
        }

        Test.startTest();
            LightningSteps_ShoppingCartController.createOrders(JSON.serialize(productEntries), selectedAccount.Id);
        Test.stopTest();

        List<Order> createdOrders = [
            SELECT Id 
            FROM Order
        ];

        List<OrderItem> createdOrderItems = [
            SELECT Id
            FROM OrderItem
        ];
        
        List<LightningSteps_Log__c> errorLogs = [
            SELECT Id
            FROM LightningSteps_Log__c
        ];

        System.assertEquals(1, createdOrders.size(), 'We should have an order.');
        System.assertEquals(2, createdOrderItems.size(), 'We should have two order items.');
        System.assertEquals(0, errorLogs.size(), 'We should have no errors.');
    }

    /*
     *  createOrders_withErrorsTest
     *  Tests an unsuccessful transaction, savepoint rollback and error log creation
    */
    @isTest
    static void createOrders_withErrorsTest(){
        Account selectedAccount = [SELECT Id FROM Account LIMIT 1];

        List<PriceBookEntry> pbEntries = [
            SELECT Id, Product2Id, UnitPrice, Product2.Name, Product2.Description, Product2.Category__c, Pricebook2Id,
                Product2.Style__c, Product2.Color__c, Product2.Current_Stock__c, Product2.In_Stock__c, Product2.Size__c, Product2.ProductCode
            FROM PriceBookEntry
            WHERE Pricebook2Id = :pricebookId
            AND Product2.IsActive = true
            AND Product2.In_Stock__c = true
        ];

        List<ProductEntry> productEntries = LightningSteps_ProductListController.parseEntries(pbEntries);

        //SETTING THE QUANTITY SOLD
        for(ProductEntry prodEntry : productEntries){
            prodEntry.quantityNeeded = 5;
            prodEntry.priceBookId = '01s4x000006yJlhAAB'; //NOT EXISTING ID
        }

        Test.startTest();
            LightningSteps_ShoppingCartController.createOrders(JSON.serialize(productEntries), selectedAccount.Id);
        Test.stopTest();

        List<Order> createdOrders = [
            SELECT Id 
            FROM Order
        ];

        List<OrderItem> createdOrderItems = [
            SELECT Id
            FROM OrderItem
        ];
        
        List<LightningSteps_Log__c> errorLogs = [
            SELECT Id, Error_Message__c
            FROM LightningSteps_Log__c
        ];

        System.assertEquals(0, createdOrders.size(), 'We should have no orders.');
        System.assertEquals(0, createdOrderItems.size(), 'We should have no order items.');
        System.assertEquals(1, errorLogs.size(), 'We should have an error.');
        System.assertEquals(true, errorLogs[0].Error_Message__c.contains('Pricebook'), 'The error should be related to the missing pricebook id.');
    }

    
    /*
     *  createOrderItems_withErrorsTest
     *  Tests an unsuccessful transaction, savepoint rollback and error log creation
    */
    @isTest
    static void createOrderItems_withErrorsTest(){
        Account selectedAccount = [SELECT Id FROM Account LIMIT 1];

        List<PriceBookEntry> pbEntries = [
            SELECT Id, Product2Id, UnitPrice, Product2.Name, Product2.Description, Product2.Category__c, Pricebook2Id,
                Product2.Style__c, Product2.Color__c, Product2.Current_Stock__c, Product2.In_Stock__c, Product2.Size__c, Product2.ProductCode
            FROM PriceBookEntry
            WHERE Pricebook2Id = :pricebookId
            AND Product2.IsActive = true
            AND Product2.In_Stock__c = true
        ];

        List<ProductEntry> productEntries = LightningSteps_ProductListController.parseEntries(pbEntries);

        //SETTING THE QUANTITY SOLD
        for(ProductEntry prodEntry : productEntries){
            prodEntry.quantityNeeded = 5;
            prodEntry.pbEntryId = '01u4x000003FQviAkk'; //NOT EXISTING ID
        }

        Test.startTest();
            LightningSteps_ShoppingCartController.createOrders(JSON.serialize(productEntries), selectedAccount.Id);
        Test.stopTest();

        List<Order> createdOrders = [
            SELECT Id 
            FROM Order
        ];

        List<OrderItem> createdOrderItems = [
            SELECT Id
            FROM OrderItem
        ];
        
        List<LightningSteps_Log__c> errorLogs = [
            SELECT Id, Error_Message__c
            FROM LightningSteps_Log__c
        ];

        System.assertEquals(0, createdOrders.size(), 'We should have no orders.');
        System.assertEquals(0, createdOrderItems.size(), 'We should have no order items.');
        System.assertEquals(2, errorLogs.size(), 'We should have an error.');
        System.assertEquals(true, errorLogs[0].Error_Message__c.contains('PricebookEntry'), 'The error should be related to the missing pricebook entry.');
    }
    
    /*
     *  retrieveAccountsTest
     *  Tests account retrieval
    */
    @isTest
    static void retrieveAccountsTest(){
        List<Account> allAccounts = LightningSteps_ShoppingCartController.retrieveAccounts();
        System.assertEquals(1, allAccounts.size(), 'We should have only one account.');
    }
}