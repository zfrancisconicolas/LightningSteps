# LightningSteps
Lightning Steps App

# Notes:
Project to deploy to the org with ANT.

Couldn't use the sfdx source data model because of the error "Error parsing file: Element {http://soap.sforce.com/2006/04/metadata}types invalid at this location in type EmailServicesFunction". Can't find a solution to it.

LWC tests inside each component __tests__ folder. In order to test, paste the lwc-tests content inside the lwc folder and run them with JEST.

CSV file for data loading in root folder. 
For each product, there should be a related Pricebook Entry. There is a script named PricebookEntry script that creates them through the anonymous console.