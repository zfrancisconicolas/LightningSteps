import { createElement } from 'lwc';
import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import LightningStepsShoppingCart from 'c/lightningStepsShoppingCart';
import { retrieveAccounts } from "@salesforce/apex/LightningSteps_ShoppingCartController.retrieveAccounts";

// Register a test wire adapter.
const getRecordWireAdapter = registerLdsTestWireAdapter(retrieveAccounts);

describe('shopping cart component test', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }   
    });

    /*
     * displays account
     * Simple test to verify account population
    */
    it('display accounts', () => {
        //Couldn't solve an issue with a JSON mock so we are creating an array
        let edge = {"Id":"01u4x000003FQwfAAG","Name":"Edge Communications"};
        let pyramid = {"Id":"01u4x000003FQwgAAG","Name":"Pyramid Construction Inc."};
        let genepoint = {"Id":"01u4x000003FQwhAAG","Name":"GenePoint"};
        let sforce = {"Id":"01u4x000003FQwiAAG","Name":"sForce"};

        var mockAccounts = [edge, pyramid, genepoint, sforce];
        const element = createElement('c-lightning-steps-shopping-cart', { is: LightningStepsShoppingCart });
        document.body.appendChild(element);
        getRecordWireAdapter.emit(mockAccounts);

        return Promise.resolve().then(() => {
            expect(element.accountItems.length).toBe(mockAccounts.length);
        });
    });
});