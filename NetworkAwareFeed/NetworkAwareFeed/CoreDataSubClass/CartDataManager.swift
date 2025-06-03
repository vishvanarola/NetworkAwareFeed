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
    
    // MARK: - Add Product to Cart
    func addProductToCart(_ productData: ProductsData, quantity: Int = 1) {
        guard let context = context else { return }
        
        context.perform {
            let fetchRequest: NSFetchRequest<CartProduct> = CartProduct.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "product.id == %d", productData.id ?? 0)
            
            do {
                if let existingCartItem = try context.fetch(fetchRequest).first {
                    existingCartItem.quantity += Int64(quantity)
                } else {
                    let productFetch: NSFetchRequest<QuantroProduct> = QuantroProduct.fetchRequest()
                    productFetch.predicate = NSPredicate(format: "id == %d", productData.id ?? 0)
                    
                    guard let existingProduct = try context.fetch(productFetch).first else {
                        print("Product not found in Core Data. Ensure it's saved before adding to cart.")
                        return
                    }
                    
                    let cartItem = CartProduct(context: context)
                    cartItem.quantity = Int64(quantity)
                    cartItem.product = existingProduct
                }
                
                try context.save()
            } catch {
                print("Failed to add product to cart: \(error.localizedDescription)")
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
                            returnPolicy: p.returnPolicy,
                            minimumOrderQuantity: Int(p.minimumOrderQuantity),
                            images: p.images as? [String],
                            thumbnail: p.thumbnail
                        )
                        items.append((product, Int(item.quantity)))
                    }
                }
            } catch {
                print("Failed to retrieve cart items: \(error.localizedDescription)")
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
