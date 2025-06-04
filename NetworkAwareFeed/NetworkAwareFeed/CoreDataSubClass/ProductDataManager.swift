//
//  ProductDataManager.swift
//  NetworkAwareFeed
//
//  Created by apple on 28/05/25.
//

import UIKit
import CoreData

final class ProductDataManager {
    
    private let entityName = "QuantroProduct"
    
    // Helper function to safely perform work on the main thread
    private func performOnMainThread(_ block: () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
    }
    
    // Convert arrays to Data for Core Data storage
    private func convertToData<T: Encodable>(_ value: T?) -> Data? {
        guard let value = value else { return nil }
        return try? JSONEncoder().encode(value)
    }
    
    // Convert Data back to arrays from Core Data
    private func convertFromData<T: Decodable>(_ data: Any?) -> T? {
        guard let data = data as? Data else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func createData(_ productsData: [ProductsData]) {
        var appDelegate: AppDelegate?
        
        performOnMainThread {
            appDelegate = UIApplication.shared.delegate as? AppDelegate
        }
        
        guard let appDelegate = appDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        performOnMainThread {
            // First, delete existing data
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try managedContext.execute(deleteRequest)
            } catch {
                print("❌ Could not delete existing data: \(error)")
            }
            
            let productEntity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
            
            for productData in productsData {
                let product = NSManagedObject(entity: productEntity, insertInto: managedContext)
                
                // Convert arrays to Data
                let reviewsData = convertToData(productData.reviews)
                let tagsData = convertToData(productData.tags)
                let imagesData = convertToData(productData.images)
                
                product.setValue(productData.id, forKey: "id")
                product.setValue(productData.title, forKey: "title")
                product.setValue(productData.description, forKey: "desc")
                product.setValue(productData.category, forKey: "category")
                product.setValue(productData.price, forKey: "price")
                product.setValue(productData.discountPercentage, forKey: "discountPercentage")
                product.setValue(productData.rating, forKey: "rating")
                product.setValue(productData.stock, forKey: "stock")
                product.setValue(tagsData, forKey: "tags")
                product.setValue(productData.brand, forKey: "brand")
                product.setValue(productData.sku, forKey: "sku")
                product.setValue(productData.weight, forKey: "weight")
                product.setValue(productData.warrantyInformation, forKey: "warrantyInformation")
                product.setValue(productData.shippingInformation, forKey: "shippingInformation")
                product.setValue(productData.availabilityStatus, forKey: "availabilityStatus")
                product.setValue(reviewsData, forKey: "reviews")
                product.setValue(productData.returnPolicy, forKey: "returnPolicy")
                product.setValue(productData.minimumOrderQuantity, forKey: "minimumOrderQuantity")
                product.setValue(imagesData, forKey: "images")
                product.setValue(productData.thumbnail, forKey: "thumbnail")
            }
            
            do {
                try managedContext.save()
                print("✅ Successfully saved \(productsData.count) products to Core Data")
            } catch let error as NSError {
                print("❌ Could not save to Core Data: \(error), \(error.userInfo)")
            }
        }
        
        // Do image downloading outside of the main thread
        for product in productsData {
            downloadAndCacheImages(for: product)
        }
    }
    
    func retrieveData() -> [ProductsData] {
        var products: [ProductsData] = []
        var appDelegate: AppDelegate?
        
        performOnMainThread {
            appDelegate = UIApplication.shared.delegate as? AppDelegate
        }
        
        guard let appDelegate = appDelegate else { return [] }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        performOnMainThread {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            
            do {
                let result = try managedContext.fetch(fetchRequest)
                for data in result {
                    // Convert Data back to arrays
                    let reviews: [ReviewsData]? = convertFromData(data.value(forKey: "reviews"))
                    let tags: [String]? = convertFromData(data.value(forKey: "tags"))
                    let images: [String]? = convertFromData(data.value(forKey: "images"))
                    
                    let product = ProductsData(
                        id: data.value(forKey: "id") as? Int,
                        title: data.value(forKey: "title") as? String,
                        description: data.value(forKey: "desc") as? String,
                        category: data.value(forKey: "category") as? String,
                        price: data.value(forKey: "price") as? Double,
                        discountPercentage: data.value(forKey: "discountPercentage") as? Double,
                        rating: data.value(forKey: "rating") as? Double,
                        stock: data.value(forKey: "stock") as? Int,
                        tags: tags,
                        brand: data.value(forKey: "brand") as? String,
                        sku: data.value(forKey: "sku") as? String,
                        weight: data.value(forKey: "weight") as? Int,
                        warrantyInformation: data.value(forKey: "warrantyInformation") as? String,
                        shippingInformation: data.value(forKey: "shippingInformation") as? String,
                        availabilityStatus: data.value(forKey: "availabilityStatus") as? String,
                        reviews: reviews,
                        returnPolicy: data.value(forKey: "returnPolicy") as? String,
                        minimumOrderQuantity: data.value(forKey: "minimumOrderQuantity") as? Int,
                        images: images,
                        thumbnail: data.value(forKey: "thumbnail") as? String
                    )
                    products.append(product)
                }
                print("✅ Successfully retrieved \(products.count) products from Core Data")
            } catch {
                print("❌ Error fetching from Core Data: \(error)")
            }
        }
        
        return products
    }
    
    func updateData(_ products: [ProductsData]) {
        var appDelegate: AppDelegate?
        
        // Get app delegate on main thread
        performOnMainThread {
            appDelegate = UIApplication.shared.delegate as? AppDelegate
        }
        
        guard let appDelegate = appDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Perform Core Data operations on main thread
        performOnMainThread {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            
            do {
                let existingProducts = try managedContext.fetch(fetchRequest)
                
                for product in products {
                    let productId = product.id ?? 0
                    
                    let targetProduct = existingProducts.first(where: {
                        ($0.value(forKey: "id") as? Int) == productId
                    }) ?? {
                        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
                        let newProduct = NSManagedObject(entity: entity, insertInto: managedContext)
                        newProduct.setValue(productId, forKey: "id")
                        return newProduct
                    }()
                    
                    targetProduct.setValue(product.title, forKey: "title")
                    targetProduct.setValue(product.description, forKey: "desc")
                    targetProduct.setValue(product.category, forKey: "category")
                    targetProduct.setValue(product.price, forKey: "price")
                    targetProduct.setValue(product.discountPercentage, forKey: "discountPercentage")
                    targetProduct.setValue(product.rating, forKey: "rating")
                    targetProduct.setValue(product.stock, forKey: "stock")
                    targetProduct.setValue(product.tags, forKey: "tags")
                    targetProduct.setValue(product.brand, forKey: "brand")
                    targetProduct.setValue(product.sku, forKey: "sku")
                    targetProduct.setValue(product.weight, forKey: "weight")
                    targetProduct.setValue(product.warrantyInformation, forKey: "warrantyInformation")
                    targetProduct.setValue(product.shippingInformation, forKey: "shippingInformation")
                    targetProduct.setValue(product.availabilityStatus, forKey: "availabilityStatus")
                    targetProduct.setValue(product.reviews, forKey: "reviews")
                    targetProduct.setValue(product.returnPolicy, forKey: "returnPolicy")
                    targetProduct.setValue(product.minimumOrderQuantity, forKey: "minimumOrderQuantity")
                    targetProduct.setValue(product.images, forKey: "images")
                    targetProduct.setValue(product.thumbnail, forKey: "thumbnail")
                }
                
                try managedContext.save()
                
            } catch let error as NSError {
                print("Could not update. \(error), \(error.userInfo)")
            }
        }
        
        // Do image downloading outside of the main thread
        for product in products {
            downloadAndCacheImages(for: product)
        }
    }
    
    func deleteData() {
        var appDelegate: AppDelegate?
        
        // Get app delegate on main thread
        performOnMainThread {
            appDelegate = UIApplication.shared.delegate as? AppDelegate
        }
        
        guard let appDelegate = appDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Perform Core Data operations on main thread
        performOnMainThread {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try managedContext.execute(deleteRequest)
                try managedContext.save()
            } catch let error as NSError {
                print("Could not delete all data. \(error), \(error.userInfo)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Downloads and caches images for a product
    private func downloadAndCacheImages(for product: ProductsData) {
        let productId = "\(product.id ?? 0)"
        
        // Cache thumbnail image
        if let thumbnailUrl = product.thumbnail, let url = URL(string: thumbnailUrl) {
            downloadAndCacheImage(url: url, id: productId)
        }
        
        // Cache all product images with unique keys for each image
        if let images = product.images {
            for (index, urlString) in images.enumerated() {
                if let url = URL(string: urlString) {
                    // Explicitly add index information to ensure each image has a unique cache
                    downloadAndCacheImage(url: url, id: productId)
                    print("Cached image \(index) for product \(productId): \(urlString)")
                }
            }
        }
    }
    
    /// Downloads and caches a single image asynchronously
    private func downloadAndCacheImage(url: URL, id: String) {
        // First check if the image is already cached
        if ImageCacheManager.shared.getImage(for: url, id: id) != nil {
            // Image already cached, no need to download again
            return
        }
        
        // Download asynchronously
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                ImageCacheManager.shared.save(image, for: url, id: id)
            } else if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
            }
        }.resume()
    }
}
