import { LightningElement, api, track, wire } from "lwc";
import getProductEntries from "@salesforce/apex/LightningSteps_ProductListController.getProductEntries";

export default class lightningStepsProductList extends LightningElement {
    @track defaultSortDirection = "asc";
    @track sortDirection = "asc";
    @track products = [];
    @track originalProducts = [];
    @track filter = "";
    @track sortedBy;
    @track error;
    
    //Retrieves product entries from apex code
    @wire (getProductEntries)
    wiredProducts({error, data}) {
        if(data && Array.isArray(data)) {
            this.products = data.map(entry => {
                return {
                    ...entry,
                    productUrl: `/lightning/r/${entry.productId}/view`,
                }
            });            
            this.originalProducts = this.products;
            this.error = undefined;
        } 
        else if (error || data == null) {
            this.error = 'There are no products or pricebook.';
        }
    }

    //Refresh products list
    @api
    reloadProducts() {
        this.products = [...this.products];
    }

    //Removes stock from the products
    @api
    discountStock(product, neededQuantity) {
        for (var i in this.products) {
            if (this.products[i].productId == product["productId"]) {
                let total = (parseInt(this.products[i].productStock, 10) - parseInt(neededQuantity, 10));
                this.products[i].productStock = total;
                break; 
            }
        }
        this.reloadProducts();
    }

    //Adds stock to the products. Supports multiple products at once    
    @api
    addStock(removedProducts){
        for (var i in this.products) {
            for (var removedProduct of removedProducts) {
                if (this.products[i].productId == removedProduct["productId"]) {
                    let productTotal = (parseInt(removedProduct["quantityNeeded"], 10) + this.products[i].productStock);
                    this.products[i].productStock = productTotal;
                    break; 
                }
            }   
        }   
        this.reloadProducts();
    }

    //Handles the filter for the products
    handleFilter(event){
        let filterString;
        if(this.filter != ""){
            let filterField = this.filter;
            if(filterField == "productSize"){
                filterString = parseInt(event.detail.value, 10); 
                var filteredProducts = this.originalProducts.filter(function (elem) { 
                        let objectValue = parseInt(elem[filterField], 10);
                        return objectValue == filterString;;
                    } 
                ); 
                if(Number.isNaN(filterString)){
                    this.products = this.originalProducts;
                }
                else{
                    this.products = filteredProducts;
                }
            }
            else{
                filterString = event.detail.value.toLowerCase();  
                var filteredProducts = this.originalProducts.filter(function (elem) { 
                        let objectValue = (elem[filterField.toString()]).toLowerCase();
                        return objectValue.startsWith(filterString);
                    } 
                ); 
                this.products = filteredProducts;
            }
        }
    }

    //Handles the filter change
    changeFilter(event){
        var selectedFilter = event.detail.value;
        this.filter = selectedFilter;
    }
    
    //Handles datatable sorting
    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.products];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
        this.products = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    //Handles datatable sort by
    sortBy(field, reverse) {
        field == "productUrl" ? field = "productName" : field = field;
        return function (obj1, obj2) {
            obj1 = obj1[field];
            obj2 = obj2[field];
            return reverse * ((obj1 > obj2) - (obj2 > obj1));
        };
    }

    //Handles product selection. Sends information to the parent component
    handleSelection(){
        const row = this.template.querySelector("lightning-datatable").getSelectedRows(); 
        let currentProduct = this.products.find((elem) => elem.productId === row[0].productId);
        var selectProduct = JSON.parse(JSON.stringify(currentProduct));

        this.dispatchEvent(new CustomEvent("prodselect", {
            detail: {  selectedProduct: selectProduct } 
        }));
    }

    //Handles product addition to the cart
    handleRowAction(event) {
        let currentProduct;
        const action = event.detail.action;
        const row = event.detail.row;
        if (action.name === "Add") {
            currentProduct = this.products.find((elem) => elem.productId === row.productId);
            var addedProduct = JSON.parse(JSON.stringify(currentProduct));
            this.dispatchEvent(new CustomEvent("openadd", {
                detail: {  product: addedProduct } 
            }));
        }
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

    //Filter options
    get filterOptions() {
        return [
            { label: "Category", value: "productCategory" },
            { label: "Style", value:  "productStyle" },
            { label: "Color", value: "productColor" },
            { label: "Size", value: "productSize" }
        ];
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
                label: "Category",
                fixedWidth: 130,
                fieldName: "productCategory",
                sortable: true
            },
            {
                label: "Style",
                fixedWidth: 120,
                fieldName: "productStyle",
                sortable: true
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
                label: "Quantity in Stock",
                fixedWidth: 170,
                fieldName: "productStock",
                sortable: true,
                cellAttributes: { alignment: "center" }
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
                type: "button", 
                fixedHeight: 20,
                typeAttributes: {
                    label: "Add To Cart",
                    name: "Add",
                    title: "Add To Cart",
                    disabled: false,
                    value: "addToCart",
                    iconPosition: "center"
                }
            }
        ];
    }
}