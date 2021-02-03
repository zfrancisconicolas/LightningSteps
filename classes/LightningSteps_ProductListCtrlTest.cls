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
    }

    @isTest
    static void getProductEntriesTest(){
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        List<Product2> products = [
            SELECT Id
            FROM Product2
        ];

        List<PriceBookEntry> pbEntries = new List<PriceBookEntry>();
        if(!products.isEmpty()){
            for(Product2 prod : products){
                pbEntries.add(new PriceBookEntry(
                    Pricebook2Id = pricebookId,
                    Product2Id = prod.Id,
                    UnitPrice = 110, 
                    IsActive = true
                ));
            }
        }

        insert pbEntries;

        List<ProductEntry> productEntries = LightningSteps_ProductListController.getProductEntries();
        System.assertEquals(2, productEntries.size(), 'We should have two product entries.');
    }

    @isTest
    static void getProductEntries_withoutProductsTest(){
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        List<ProductEntry> productEntries = LightningSteps_ProductListController.getProductEntries();

        System.assertEquals(null, productEntries, 'The list should be null');
    }
}