//
//  ProductDataManager.swift
//  NetworkAwareFeed
//
//  Created by apple on 28/05/25.
//

import UIKit
import CoreData

final class ProductDataManager {
    
    // MARK: - Singleton Instance
    static let shared = ProductDataManager()
    private init() {}
    
    // MARK: - Create / Save Products
    func createData(_ productsData: [ProductsData]) {
        let context = CoreDataManager.shared.newBackgroundContext()
        
        context.perform {
            do {
                // First delete existing data
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.quantro)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try context.execute(deleteRequest)
                
                // Insert new products
                for productData in productsData {
                    let product = QuantroProduct(context: context)
                    product.id = Int64(productData.id ?? 0)
                    product.title = productData.title
                    product.desc = productData.description
                    product.category = productData.category
                    product.price = productData.price ?? 0.0
                    product.discountPercentage = productData.discountPercentage ?? 0.0
                    product.rating = productData.rating ?? 0.0
                    product.stock = Int64(productData.stock ?? 0)
                    product.tags = productData.tags as NSObject?
                    product.brand = productData.brand
                    product.sku = productData.sku
                    product.weight = Int64(productData.weight ?? 0)
                    product.warrantyInformation = productData.warrantyInformation
                    product.shippingInformation = productData.shippingInformation
                    product.availabilityStatus = productData.availabilityStatus
                    product.reviews = productData.reviews as NSObject?
                    product.returnPolicy = productData.returnPolicy
                    product.minimumOrderQuantity = Int64(productData.minimumOrderQuantity ?? 0)
                    product.images = productData.images as NSObject?
                    product.thumbnail = productData.thumbnail
                }
                
                // Save context
                CoreDataManager.shared.saveContext(context: context)
                print("✅ Successfully saved \(productsData.count) products to Core Data")
            } catch {
                print("❌ Could not create products: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Retrieve Products
    func retrieveData() -> [ProductsData] {
        let context = CoreDataManager.shared.mainContext
        var products: [ProductsData] = []
        
        context.performAndWait {
            let fetchRequest: NSFetchRequest<QuantroProduct> = QuantroProduct.fetchRequest()
            
            do {
                let result = try context.fetch(fetchRequest)
                for p in result {
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
                    products.append(product)
                }
                print("✅ Successfully retrieved \(products.count) products from Core Data")
            } catch {
                print("❌ Failed to retrieve products: \(error.localizedDescription)")
            }
        }
        
        return products
    }
    
    // MARK: - Update Products
    func updateData(_ productsData: [ProductsData]) {
        let context = CoreDataManager.shared.newBackgroundContext()
        
        context.perform {
            do {
                let fetchRequest: NSFetchRequest<QuantroProduct> = QuantroProduct.fetchRequest()
                let existingProducts = try context.fetch(fetchRequest)
                
                for productData in productsData {
                    let productId = Int64(productData.id ?? 0)
                    let quantroProduct = existingProducts.first(where: { $0.id == productId }) ?? QuantroProduct(context: context)
                    
                    quantroProduct.id = productId
                    quantroProduct.title = productData.title
                    quantroProduct.desc = productData.description
                    quantroProduct.category = productData.category
                    quantroProduct.price = productData.price ?? 0.0
                    quantroProduct.discountPercentage = productData.discountPercentage ?? 0.0
                    quantroProduct.rating = productData.rating ?? 0.0
                    quantroProduct.stock = Int64(productData.stock ?? 0)
                    quantroProduct.tags = productData.tags as NSObject?
                    quantroProduct.brand = productData.brand
                    quantroProduct.sku = productData.sku
                    quantroProduct.weight = Int64(productData.weight ?? 0)
                    quantroProduct.warrantyInformation = productData.warrantyInformation
                    quantroProduct.shippingInformation = productData.shippingInformation
                    quantroProduct.availabilityStatus = productData.availabilityStatus
                    quantroProduct.reviews = productData.reviews as NSObject?
                    quantroProduct.returnPolicy = productData.returnPolicy
                    quantroProduct.minimumOrderQuantity = Int64(productData.minimumOrderQuantity ?? 0)
                    quantroProduct.images = productData.images as NSObject?
                    quantroProduct.thumbnail = productData.thumbnail
                }
                
                CoreDataManager.shared.saveContext(context: context)
                print("✅ Successfully updated \(productsData.count) products")
            } catch {
                print("❌ Failed to update products: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Delete All Products
    func deleteData() {
        let context = CoreDataManager.shared.newBackgroundContext()
        
        context.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.quantro)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                CoreDataManager.shared.saveContext(context: context)
                print("✅ Successfully deleted all products")
            } catch {
                print("❌ Failed to delete products: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Download & Cache Images (optional utility)
    func downloadAndCacheImages(for product: ProductsData) {
        let productId = "\(product.id ?? 0)"
        
        // Cache thumbnail
        if let thumbnailUrl = product.thumbnail, let url = URL(string: thumbnailUrl) {
            downloadAndCacheImage(url: url, id: productId)
        }
        
        // Cache product images
        if let images = product.images {
            for (index, urlString) in images.enumerated() {
                if let url = URL(string: urlString) {
                    downloadAndCacheImage(url: url, id: productId + "_\(index)")
                }
            }
        }
    }
    
    private func downloadAndCacheImage(url: URL, id: String) {
        if ImageCacheManager.shared.getImage(for: url, id: id) != nil {
            // Already cached
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let image = UIImage(data: data) {
                ImageCacheManager.shared.save(image, for: url, id: id)
                print("✅ Cached image \(id)")
            } else if let error = error {
                print("❌ Error downloading image: \(error.localizedDescription)")
            }
        }.resume()
    }
}
