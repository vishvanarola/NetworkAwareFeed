//
//  CartManager.swift
//  NetworkAwareFeed
//
//  Created by apple on 29/05/25.
//

import Foundation

class CartManager {
    static let shared = CartManager()
    
    private let cartKey = "cart_items"
    private(set) var items: [CartItem] = []
    
    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var totalPrice: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    private init() {
        loadCart()
    }
    
    func addToCart(product: BeautyProducts, quantity: Int = 1) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(product: product, quantity: quantity))
        }
        saveCart()
    }
    
    func removeFromCart(productId: Int) {
        items.removeAll { $0.product.id == productId }
        saveCart()
    }
    
    func updateQuantity(productId: Int, quantity: Int) {
        if let index = items.firstIndex(where: { $0.product.id == productId }) {
            items[index].quantity = quantity
            saveCart()
        }
    }
    
    func clearCart() {
        items.removeAll()
        saveCart()
    }
    
    private func saveCart() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: cartKey)
        }
    }
    
    private func loadCart() {
        if let data = UserDefaults.standard.data(forKey: cartKey),
           let decoded = try? JSONDecoder().decode([CartItem].self, from: data) {
            items = decoded
        }
    }
} 
