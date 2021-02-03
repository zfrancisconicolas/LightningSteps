Pricebook2 pb = [
    SELECT Id
    FROM PriceBook2
    WHERE IsStandard = true
];

List<Product2> products = [
    SELECT Id, Name, ProductCode 
    FROM Product2
    WHERE In_Stock__c = true
];

List<PricebookEntry> pbEntries = new List<PricebookEntry>();
if(!products.isEmpty()){
    for(Product2 prod : products){
    	pbEntries.add(new PricebookEntry(
        	UnitPrice = Integer.valueof((math.random() * 100)),
            Pricebook2Id = pb.Id,
            Product2Id = prod.Id
        ));
	}
}

if(!pbEntries.isEmpty()){
    insert pbEntries;
}