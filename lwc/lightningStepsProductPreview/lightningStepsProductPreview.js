import { LightningElement, api, track } from "lwc";
import PRODUCT_IMAGES from "@salesforce/resourceUrl/lightningSteps_products";

export default class LightningStepsProductPreview extends LightningElement {
    @track productName;
    @track productDescription;
    @track productImage;

    //Changes showed information to the product selected by the user
    @api
    showProduct(selectedProduct){
        let selectedProductRaw = JSON.parse(JSON.stringify(selectedProduct));
        let product = selectedProductRaw.detail.selectedProduct;
        this.productName = product["productName"];
        this.productDescription = product["productDescription"];
        this.productImage = PRODUCT_IMAGES + "/lightningsteps/" + product["productCode"] + ".jpg";
    }
}