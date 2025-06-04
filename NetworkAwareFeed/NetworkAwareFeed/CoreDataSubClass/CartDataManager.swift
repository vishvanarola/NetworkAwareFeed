//
//  CartDataManager.swift
//  NetworkAwareFeed
//
//  Created by apple on 30/05/25.
//

import UIKit
import CoreData

final class CartDataManager {
    
    // MARK: - Shared Context
    private var context: NSManagedObjectContext? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    // Convert arrays to NSArray for Core Data storage
    private func convertArrayToNSObject(_ array: [Any]?) -> NSObject? {
        return array as NSObject?
    }
    
    // MARK: - Add Product to Cart
    func addProductToCart(_ productData: ProductsData, quantity: Int = 1) {
        guard let context = context else { return }
        
        context.perform {
            // First check if the product exists in Core Data
            let productFetch: NSFetchRequest<QuantroProduct> = QuantroProduct.fetchRequest()
            productFetch.predicate = NSPredicate(format: "id == %d", productData.id ?? 0)
            
            do {
                let existingProducts = try context.fetch(productFetch)
                let quantroProduct: QuantroProduct
                
                if let existingProduct = existingProducts.first {
                    quantroProduct = existingProduct
                } else {
                    // Create new product if it doesn't exist
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
                    
                    // Convert arrays to NSObject
                    quantroProduct.tags = self.convertArrayToNSObject(productData.tags)
                    quantroProduct.reviews = self.convertArrayToNSObject(productData.reviews)
                    quantroProduct.images = self.convertArrayToNSObject(productData.images)
                    
                    try context.save()
                }
                
                // Now check if the product is already in cart
                let cartFetch: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
                cartFetch.predicate = NSPredicate(format: "product.id == %d", productData.id ?? 0)
                
                if let existingCartItem = try context.fetch(cartFetch).first {
                    existingCartItem.quantity += Int64(quantity)
                } else {
                    let cartItem = CartProduct(context: context)
                    cartItem.quantity = Int64(quantity)
                    cartItem.product = quantroProduct
                }
                
                try context.save()
                print("✅ Successfully added product to cart")
            } catch {
                print("❌ Failed to add product to cart: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Retrieve Cart Items
    func getCartItems() -> [(product: ProductsData, quantity: Int)] {
        guard let context = context else { return [] }
        
        var items: [(ProductsData, Int)] = []
        
        context.performAndWait {
            let fetchRequest: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
            
            do {
                let cartItems = try context.fetch(fetchRequest)
                
                for item in cartItems {
                    if let p = item.product {
                        let product = ProductsData(
                            id: Int(p.id),
                            title: p.title,
                            description: p.desc,
                            category: p.category,
                            price: p.price,
                            discountPercentage: p.discountPercentage,
                            rating: p.rating,
                            stock: Int(p.stock),
                            tags: p.tags as? [String],
                            brand: p.brand,
                            sku: p.sku,
                            weight: Int(p.weight),
                            warrantyInformation: p.warrantyInformation,
                            shippingInformation: p.shippingInformation,
                            availabilityStatus: p.availabilityStatus,
                            reviews: p.reviews as? [ReviewsData],
                            returnPolicy: p.returnPolicy,
                            minimumOrderQuantity: Int(p.minimumOrderQuantity),
                            images: p.images as? [String],
                            thumbnail: p.thumbnail
                        )
                        items.append((product, Int(item.quantity)))
                    }
                }
                print("✅ Successfully retrieved \(items.count) cart items")
            } catch {
                print("❌ Failed to retrieve cart items: \(error.localizedDescription)")
            }
        }
        
        return items
    }
    
    // MARK: - Update Quantity for a Product in Cart
    func updateQuantity(productId: Int, quantity: Int, completion: @escaping () -> Void) {
        guard let context = context else { return completion() }
        
        context.perform {
            let fetchRequest: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "product.id == %d", productId)
            
            do {
                if let cartItem = try context.fetch(fetchRequest).first {
                    cartItem.quantity = Int64(quantity)
                    try context.save()
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
        guard let context = context else { return }
        
        context.perform {
            let fetchRequest: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "product.id == %d", productId)
            
            do {
                let items = try context.fetch(fetchRequest)
                for item in items {
                    context.delete(item)
                }
                try context.save()
            } catch {
                print("Failed to remove product from cart: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Clear Entire Cart
    func clearCart() {
        guard let context = context else { return }
        
        context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CartProduct.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                print("Failed to clear cart: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Get Quantity for a Product Already in Cart
    func getQuantityForProduct(_ productId: Int) -> Int {
        guard let context = context else { return 0 }
        
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
