import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createOrders from "@salesforce/apex/LightningSteps_ShoppingCartController.createOrders";
import retrieveAccounts from "@salesforce/apex/LightningSteps_ShoppingCartController.retrieveAccounts";

export default class LightningStepsShoppingCart extends LightningElement {
    @track showAccountSelection = false;
    @track defaultSortDirection = "asc";
    @track accountItemsOriginal = [];
    @track sortDirection = "asc";
    @track chosenAccount = "";
    @api accountItems = [];
    @track totalPrice = 0;
    @track cart = [];
    @track sortedBy;
    @track error;   

    //Retrieves accounts from apex code
    @wire(retrieveAccounts)
    wiredAccounts({error, data}) {
        if (data) {
            for(var i=0; i<data.length; i++)  {
                this.accountItems = [...this.accountItems, {
                    value: data[i].Id,
                    label: data[i].Name
                }];       
            }          
            this.accountItemsOriginal = this.accountItems;
            this.error = undefined;
        } 
        else if (error) {
            this.error = error;
        }
    }

    //Shows account selection modal
    @api
    showAccountSelectionPage() {
        if(this.cart.length > 0 ){
            this.showAccountSelection = true;
        }
        else{
            this.showToast("Warning", "You should at least have an item in the cart.", "warning"); 
        }
    }

    //Sums up the total price
    @api
    addTotalPrice(price) {
        this.totalPrice += price;
    }

    //Adds products to the shopping cart
    @api
    addToCart(addedProduct) {
        var productExists = false;
        let cartSize = this.cart.length;
        if(cartSize > 0){
            for (let i = 0 ; i < cartSize ; i++) {
                if (this.cart[i].productId == addedProduct["productId"]) {
                    var total = (parseInt(this.cart[i].quantityNeeded, 10) + parseInt(addedProduct["quantityNeeded"], 10));
                    this.cart[i].quantityNeeded = total;
                    productExists = true;
                    break; 
                }
            }
            if (!productExists)
                this.cart = [...this.cart, addedProduct];
        }
        else {
            this.cart = [...this.cart, addedProduct];
        }
    }

    //Changes the selected account to the one entered by the user
    handleAccountChange(event) {
        const selectedOption = event.detail.value;
        this.chosenAccount = selectedOption;
    }

    //Closes the account selection modal
    closeAccountSelection() {
        this.showAccountSelection = false;
    }

    //Empties the cart after placing an order
    resetCart() {
        this.cart = [];
        this.totalPrice = 0;
    }
    
    //Empties when the user needs to
    emptyCart() {
        var productIds = [];
        for (var i = 0; i < this.cart.length; i++) {            
            productIds = [...productIds, this.cart[i].productId];
        }
        this.removeProduct(productIds);
        this.resetCart();
    }

    //Calls apex code to create orders, order items and update products
    callCreateOrders() {
        if(this.chosenAccount != ""){
            var entries = JSON.stringify(this.cart);
            var result = createOrders({entryList: entries, accountId: this.chosenAccount});
            if(result){
                this.showToast("Success", "Order placed correctly!", "success"); 
                this.closeAccountSelection();
                this.resetCart()
                this.callReloadProducts()
                this.chosenAccount = "";
            }
            else {
                this.showToast("Error", "There was an error processing the order. Contact your administrator to review the logs.", "error"); 
                this.closeAccountSelection();
            }
        }
        else{
            this.showToast("Error", "You need to select an account.", "error"); 
        }
    }

    //Refreshes the products list
    callReloadProducts() {
        this.dispatchEvent(new CustomEvent("prodreload"));
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

    //Removes products from the cart
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        let productToRemove = [];
        productToRemove.push(row.productId);
        if (action.name === "Remove") {
            this.removeProduct(productToRemove)
        }
    }

    //Removes the products from the cart and adds the stock back to the product list
    removeProduct(removedProductIds) {
        var productsToRemove = [];
        for (let i = 0; i < removedProductIds.length; i++) {       
            let prod = this.cart.find((elem) => elem.productId === removedProductIds[i]);
            productsToRemove = [...productsToRemove, prod];
        }

        var removedProducts = JSON.parse(JSON.stringify(productsToRemove));

        if(removedProductIds.length == 1){
            this.totalPrice -= (removedProducts[0].unitPrice * removedProducts[0].quantityNeeded);
            this.cart = this.cart.filter(item => item["productId"] != removedProducts[0].productId);
        }

        this.dispatchEvent(new CustomEvent(
            "cartremov", { 
                detail: { products: removedProducts } 
            }
        ));
    }

    //Handle account search for selection
    handleAccountSearch(event){
        const pressedEnter = event.keyCode === 13;
        let accountFilterString = event.target.value.toLowerCase(); 
        if (pressedEnter) {
            var filteredAccounts = this.accountItemsOriginal.filter(function (elem) { 
                    let accountName = elem.label.toLowerCase().toString();
                    return accountName.includes(accountFilterString);
                } 
            ); 
            this.accountItems = filteredAccounts;        
        }
    }

    //Handle datatable sorting
    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.cart];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
        this.cart = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    //Handle datatable sort by
    sortBy(field, reverse) {
        field == "productUrl" ? field = "productName" : field = field;
        return function (obj1, obj2) {
            obj1 = obj1[field];
            obj2 = obj2[field];
            return reverse * ((obj1 > obj2) - (obj2 > obj1));
        };
    }

    //Table columns
    get columns() {
        return [
            {
                label: "Product Name",
                fixedWidth: 190,
                fieldName: "productUrl",
                sortable: true,
                type: "url",
                typeAttributes: { label: { fieldName: "productName" } }
            },
            {
                label: "Color",
                fixedWidth: 120,
                fieldName: "productColor",
                sortable: true
            },
            {
                label: "Size",
                fixedWidth: 120,
                fieldName: "productSize",
                sortable: true
            },
            {
                label: "Price",
                fixedWidth: 120,
                fieldName: "unitPrice",
                sortable: true,
                type: "currency",
                cellAttributes: { alignment: "center" }
            },
            {
                label: "Quantity",
                fixedWidth: 120,
                fieldName: "quantityNeeded",
                type: "number",
                sortable: true,
                cellAttributes: { alignment: "center" }
            },
            {
                type: "button", 
                fixedHeight: 20,
                typeAttributes: {
                    label: "Remove",
                    name: "Remove",
                    title: "Remove",
                    disabled: false,
                    value: "removeFromCart",
                    iconPosition: "center"
                }
            }   
        ];
    }
    
    get selectedAccount() {
        return this.chosenAccount;
    }

}