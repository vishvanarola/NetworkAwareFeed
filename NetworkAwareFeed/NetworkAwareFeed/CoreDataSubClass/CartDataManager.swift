//
//  CartDataManager.swift
//  NetworkAwareFeed
//
//  Created by apple on 30/05/25.
//

import UIKit
import CoreData

final class CartDataManager {
    
    // MARK: - Singleton Instance
    static let shared = CartDataManager()
    private init() {}
    
    // MARK: - Add Product to Cart
    func addProductToCart(_ productData: ProductsData, quantity: Int = 1) {
        let context = CoreDataManager.shared.newBackgroundContext()
        
        context.perform {
            do {
                let productFetch: NSFetchRequest<QuantroProduct> = QuantroProduct.fetchRequest()
                productFetch.predicate = NSPredicate(format: "id == %d", productData.id ?? 0)
                
                let quantroProduct: QuantroProduct
                if let existingProduct = try context.fetch(productFetch).first {
                    quantroProduct = existingProduct
                } else {
                    quantroProduct = QuantroProduct(context: context)
                    quantroProduct.id = Int64(productData.id ?? 0)
                    quantroProduct.title = productData.title
                    quantroProduct.desc = productData.description
                    quantroProduct.category = productData.category
                    quantroProduct.price = productData.price ?? 0.0
                    quantroProduct.discountPercentage = productData.discountPercentage ?? 0.0
                    quantroProduct.rating = productData.rating ?? 0.0
                    quantroProduct.stock = Int64(productData.stock ?? 0)
                    quantroProduct.brand = productData.brand
                    quantroProduct.sku = productData.sku
                    quantroProduct.weight = Int64(productData.weight ?? 0)
                    quantroProduct.warrantyInformation = productData.warrantyInformation
                    quantroProduct.shippingInformation = productData.shippingInformation
                    quantroProduct.availabilityStatus = productData.availabilityStatus
                    quantroProduct.returnPolicy = productData.returnPolicy
                    quantroProduct.minimumOrderQuantity = Int64(productData.minimumOrderQuantity ?? 0)
                    quantroProduct.thumbnail = productData.thumbnail
                    quantroProduct.tags = productData.tags as NSObject?
                    quantroProduct.reviews = productData.reviews as NSObject?
                    quantroProduct.images = productData.images as NSObject?
                }
                
                let cartFetch: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
                cartFetch.predicate = NSPredicate(format: "product.id == %d", productData.id ?? 0)
                
                if let existingCartItem = try context.fetch(cartFetch).first {
                    existingCartItem.quantity += Int64(quantity)
                } else {
                    let cartItem = CartProduct(context: context)
                    cartItem.quantity = Int64(quantity)
                    cartItem.product = quantroProduct
                }
                
                CoreDataManager.shared.saveContext(context: context)
                print("✅ Successfully added product to cart")
            } catch {
                print("❌ Failed to add product to cart: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Retrieve Cart Items
    func getCartItems() -> [CartProduct] {
        let context = CoreDataManager.shared.mainContext
        var items: [CartProduct] = []
        
        context.performAndWait {
            let fetchRequest: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
            
            do {
                items = try context.fetch(fetchRequest)
                print("✅ Successfully retrieved \(items.count) cart items")
            } catch {
                print("❌ Failed to retrieve cart items: \(error.localizedDescription)")
            }
        }
        
        return items
    }
    
    // MARK: - Update Quantity for a Product in Cart
    func updateQuantity(productId: Int, quantity: Int, completion: @escaping () -> Void) {
        let context = CoreDataManager.shared.newBackgroundContext()
        
        context.perform {
            let fetchRequest: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "product.id == %d", productId)
            
            do {
                if let cartItem = try context.fetch(fetchRequest).first {
                    cartItem.quantity = Int64(quantity)
                    CoreDataManager.shared.saveContext(context: context)
                }
                completion()
            } catch {
                print("Failed to update quantity: \(error.localizedDescription)")
                completion()
            }
        }
    }
    
    // MARK: - Remove Product from Cart
    func removeProductFromCart(productId: Int) {
        let context = CoreDataManager.shared.newBackgroundContext()
        
        context.perform {
            let fetchRequest: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "product.id == %d", productId)
            
            do {
                let items = try context.fetch(fetchRequest)
                for item in items {
                    context.delete(item)
                }
                CoreDataManager.shared.saveContext(context: context)
                print("✅ Successfully removed product from cart")
            } catch {
                print("Failed to remove product from cart: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Clear Entire Cart
    func clearCart() {
        let context = CoreDataManager.shared.newBackgroundContext()
        
        context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CartProduct.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                CoreDataManager.shared.saveContext(context: context)
                print("✅ Successfully cleared entire cart")
            } catch {
                print("Failed to clear cart: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Get Quantity for a Product Already in Cart
    func getQuantityForProduct(_ productId: Int) -> Int {
        let context = CoreDataManager.shared.mainContext
        var result: Int = 0
        
        context.performAndWait {
            let fetchRequest: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "product.id == %d", productId)
            
            do {
                let items = try context.fetch(fetchRequest)
                if let item = items.first {
                    result = Int(item.quantity)
                }
            } catch {
                print("Failed to get quantity: \(error.localizedDescription)")
            }
        }
        return result
    }
}
