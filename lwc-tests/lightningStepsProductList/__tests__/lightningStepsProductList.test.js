import { createElement } from "lwc";
import { registerLdsTestWireAdapter } from "@salesforce/sfdx-lwc-jest";
import LightningStepsProductList from "c/lightningStepsProductList";
import { getProductEntries } from "@salesforce/apex/LightningSteps_ProductListController.getProductEntries";

// Register a test wire adapter.
const getRecordWireAdapter = registerLdsTestWireAdapter(getProductEntries);

describe("product list component test", () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }   
    });

    /*
     * displays products
     * Simple test to verify datatable population
    */
    it("display products", () => {
        //Couldn't solve an issue with a JSON mock so we are creating an array
        let blals = {"pbEntryId":"01u4x000003FQwfAAG","priceBookId":"01s4x000006yJlhAAE","productCategory":"Men Shoes","productCode":"BLALS-001","productColor":"Black","productDescription":"Black leather shoes great for the office","productId":"01t4x000000C84kAAC","productInStock":true,"productName":"Black Leather Shoe","productSize":40,"productStock":37,"productStyle":"Business","unitPrice":120,"productUrl":"/lightning/r/01t4x000000C84kAAC/view"};
        let brols = {"pbEntryId":"01u4x000003FQwgAAG","priceBookId":"01s4x000006yJlhAAE","productCategory":"Men Shoes","productCode":"BROLS-001","productColor":"Brown","productDescription":"Brown leather shoes great for the office","productId":"01t4x000000C84lAAC","productInStock":true,"productName":"Brown Leather Shoe","productSize":42,"productStock":20,"productStyle":"Business","unitPrice":120,"productUrl":"/lightning/r/01t4x000000C84lAAC/view"};
        let grels = {"pbEntryId":"01u4x000003FQwhAAG","priceBookId":"01s4x000006yJlhAAE","productCategory":"Men Shoes","productCode":"GRELS-001","productColor":"Grey","productDescription":"Greyleathershoesgreatfortheoffice","productId":"01t4x000000C84mAAC","productInStock":true,"productName":"GreyLeatherShoe","productSize":48,"productStock":11,"productStyle":"Business","unitPrice":120,"productUrl":"/lightning/r/01t4x000000C84mAAC/view"};
        let bross = {"pbEntryId":"01u4x000003FQwiAAG","priceBookId":"01s4x000006yJlhAAE","productCategory":"Men Shoes","productCode":"BROSS-001","productColor":"Brown","productDescription":"Brownsuedeshoesgreatfortheoffice","productId":"01t4x000000C84nAAC","productInStock":true,"productName":"BrownSuedeShoe","productSize":41,"productStock":2,"productStyle":"Business","unitPrice":190,"productUrl":"/lightning/r/01t4x000000C84nAAC/view"};

        var mockProducts = [blals, brols, grels, bross];
        const element = createElement("c-lightning-steps-product-list", { is: LightningStepsProductList });
        document.body.appendChild(element);
        getRecordWireAdapter.emit(mockProducts);

        return Promise.resolve().then(() => {
           const table = element.shadowRoot.querySelector("lightning-datatable");
           expect(table.data.length).toBe(mockProducts.length);
           expect(table.data[0].productCode).toBe(mockProducts[0].productCode);
        });
    });

    /*
     * no products
     * Simple test to verify the error message
    */
    it("no products", () => {
        const element = createElement("c-lightning-steps-product-list", { is: LightningStepsProductList });
        document.body.appendChild(element);
        getRecordWireAdapter.emit(null);

        return Promise.resolve().then(() => {
           const h1 = element.shadowRoot.querySelectorAll("h1");
           expect(h1[0].textContent).toBe("There are no products to display.");
        });
    });
});