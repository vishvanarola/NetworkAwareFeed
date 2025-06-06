//
//  Texts.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

//MARK: - Text Messages Enum
enum TextMessage {
    static let alert = "Alert"
    static let pleaseCheckInternet = "Please check your internet connection"
    static let somethingIsWrong = "Something is wrong"
    static let onlineMode = "Online Mode"
    static let offlineMode = "Offline Mode - Viewing Cached Data"
    static let pullToRefresh = "Pull to refresh"
    static let errorLoadingData = "Error Loading Data"
    static let noProductsPullDown = "No products available.\nPull down to refresh when online."
    static let proceedToCheckout = "Proceed to Checkout"
    static let checkout = "Checkout"
    static let totalAmount = "Total amount"
    static let proceedWithPayment = "Proceed with payment"
    static let orderConfirmed = "Order Confirmed!"
    static let thankYouForYourPurchase = "Thank you for your purchase."
    static let stockLimitReached = "Stock Limit Reached"
    static let outOfStock = "Out of Stock"
    static let brand = "Brand"
    static let category = "Category"
    static let status = "Status"
    static let minOrder = "Min Order"
    static let weight = "Weight"
    static let rating = "Rating"
    static let warranty = "Warranty"
    static let shipping = "Shipping"
    static let returns = "Returns"
    static let tags = "Tags"
    static let units = "units"
    static let selectQuantity = "Select Quantity"
    static let howManyItemsAddToCart = "How many items would you like to add to cart?"
    static let cancel = "Cancel"
    static let addToCart = "Add to Cart"
    static let invalidQuantity = "Invalid Quantity"
    static let enterValidNumber = "Please enter a valid number."
    static let stockUnavailable = "Stock Unavailable"
    static let allAvailableStockInYourCart = "All available stock is already in your cart."
    static let stockLimitExceeded = "Stock Limit Exceeded"
    static let continueShopping = "Continue Shopping"
    static let viewCart = "View Cart"
}

//MARK: - Entity Name Enum
enum EntityName {
    static let quantro = "QuantroProduct"
    static let cart = "CartProduct"
}
