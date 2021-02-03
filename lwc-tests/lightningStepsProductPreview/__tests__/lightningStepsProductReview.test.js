import { createElement } from 'lwc';
import LightningStepsProductPreview from 'c/lightningStepsProductPreview';

describe('product preview component test', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }   
    });

    /*
     * displays product
     * Simple test to verify product preview and description
    */
    it('display accounts', () => {
        var blals = {"detail":{"selectedProduct":{"pbEntryId":"01u4x000003FQwfAAG","priceBookId":"01s4x000006yJlhAAE","productCategory":"Men Shoes","productCode":"BLALS-001","productColor":"Black","productDescription":"Black leather shoes great for the office","productId":"01t4x000000C84kAAC","productInStock":true,"productName":"Black Leather Shoe","productSize":40,"productStock":37,"productStyle":"Business","unitPrice":120,"productUrl":"/lightning/r/01t4x000000C84kAAC/view"}}};

        const element = createElement('c-lightning-steps-product-review', { is: LightningStepsProductPreview });
        document.body.appendChild(element);
        element.showProduct(blals);

        return Promise.resolve().then(() => {
            expect(element.shadowRoot.querySelectorAll("h1")[0].innerHTML).toBe(blals.detail.selectedProduct.productDescription);
        });
    });
});