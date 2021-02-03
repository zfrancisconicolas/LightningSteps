@IsTest
public class LightningSteps_ProductListCtrlTest {   
    @TestSetup
    static void testData(){
        List<Product2> products = new List<Product2>();
        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        Id pricebookId = Test.getStandardPricebookId();

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

    @isTest
    static void getProductEntriesTest(){
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        List<ProductEntry> productEntries = LightningSteps_ProductListController.getProductEntries();

        System.assertEquals(2, productEntries.size(), 'We should have two product entries.');
    }

}