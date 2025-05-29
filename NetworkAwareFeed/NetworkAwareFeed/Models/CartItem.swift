//
//  CartItem.swift
//  NetworkAwareFeed
//
//  Created by apple on 29/05/25.
//

import Foundation

struct CartItem: Codable {
    let product: BeautyProducts
    var quantity: Int
    
    var totalPrice: Double {
        let price = product.price ?? 0
        let discount = product.discountPercentage ?? 0
        let discountedPrice = price * (1 - discount/100)
        return discountedPrice * Double(quantity)
    }
} 
