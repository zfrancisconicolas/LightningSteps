import { LightningElement, track } from "lwc"
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class LightningStepsMainComponent extends LightningElement {
    @track showAdditionToCart = false;
    neededQuantity = 0;
    currentProduct;

    //Calls the child and show the selected product
    productSelection(selectedProduct) {
        this.template.querySelector("c-lightning-steps-product-preview").showProduct(selectedProduct);
    }

    //Get the product needed quantity
    handleQuantityChange(event) {
        this.neededQuantity = event.detail.value;
    }

    //Changes the current product to the one the user is adding to the cart
    openAdditionToCart(product) {
        var addedProduct = JSON.parse(JSON.stringify(product)).detail.product;
        this.currentProduct = addedProduct;
        this.showAdditionToCart = true;
    }

    //Close addition to cart modal
    closeAdditionToCart() {
        this.showAdditionToCart = false;
        this.neededQuantity = 0;
    } 

    //Reloads product array to show changes
    onProductReload() {
        this.template.querySelector("c-lightning-steps-product-list").reloadProducts();
    }

    //Removes products from the cart and returns the stock back to the products list
    onCartRemoval(products) {
        var removedProductsRaw = JSON.parse(JSON.stringify(products));
        var removedProducts = [];
        for(let i = 0 ; i < removedProductsRaw.detail.products.length ; i++){
            removedProducts = [...removedProducts, removedProductsRaw.detail.products[i]];
        }
        this.template.querySelector("c-lightning-steps-product-list").addStock(removedProducts);
    }

    //Adds product to cart, total price and discounts stock
    addProductToCart() {
        let product = this.currentProduct;
        if(this.neededQuantity > 0) {
            if(this.neededQuantity <= product["productStock"]) {
                product["quantityNeeded"] = this.neededQuantity;
                this.template.querySelector("c-lightning-steps-shopping-cart").addToCart(product);
                this.template.querySelector("c-lightning-steps-shopping-cart").addTotalPrice(product["unitPrice"] * this.neededQuantity);
                this.template.querySelector("c-lightning-steps-product-list").discountStock(product, this.neededQuantity);
                this.neededQuantity = 0;
            }
            else {
                this.showToast("Error", "There isn't enough stock of " + product["productName"], "error"); 
                this.neededQuantity = 0;
            }
        }
        else if (this.neededQuantity < 0) {
            this.showToast("Error", "Please enter a valid number.", "error"); 
            this.neededQuantity = 0;
        }
        else {
            this.showToast("Error", "Please enter quantity for " + product["productName"], "error"); 
        }
        this.closeAdditionToCart();
    }

    //Show Toast event for messages
    showToast(_title, _message, _variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
            mode: "dismissable"
        }));
    }
}