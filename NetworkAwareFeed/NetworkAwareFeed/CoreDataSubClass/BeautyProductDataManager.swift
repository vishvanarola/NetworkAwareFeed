//
//  BeautyProductDataManager.swift
//  NetworkAwareFeed
//
//  Created by apple on 28/05/25.
//

import UIKit
import CoreData

final class BeautyProductDataManager {
    
    func createData(_ beautyProducts: [BeautyProducts]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let productEntity = NSEntityDescription.entity(forEntityName: entityBeautyProduct, in: managedContext)!
        
        for beautyProduct in beautyProducts {
            let product = NSManagedObject(entity: productEntity, insertInto: managedContext)
            product.setValue(beautyProduct.id, forKey: "id")
            product.setValue(beautyProduct.title, forKey: "title")
            product.setValue(beautyProduct.description, forKey: "desc")
            product.setValue(beautyProduct.category, forKey: "category")
            product.setValue(beautyProduct.price, forKey: "price")
            product.setValue(beautyProduct.discountPercentage, forKey: "discountPercentage")
            product.setValue(beautyProduct.rating, forKey: "rating")
            product.setValue(beautyProduct.stock, forKey: "stock")
            product.setValue(beautyProduct.tags, forKey: "tags")
            product.setValue(beautyProduct.brand, forKey: "brand")
            product.setValue(beautyProduct.sku, forKey: "sku")
            product.setValue(beautyProduct.weight, forKey: "weight")
            product.setValue(beautyProduct.warrantyInformation, forKey: "warrantyInformation")
            product.setValue(beautyProduct.shippingInformation, forKey: "shippingInformation")
            product.setValue(beautyProduct.availabilityStatus, forKey: "availabilityStatus")
            product.setValue(beautyProduct.returnPolicy, forKey: "returnPolicy")
            product.setValue(beautyProduct.minimumOrderQuantity, forKey: "minimumOrderQuantity")
            product.setValue(beautyProduct.images, forKey: "images")
            product.setValue(beautyProduct.thumbnail, forKey: "thumbnail")
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save, \(error), \(error.userInfo)")
        }
    }
    
    func retrieveData() -> [BeautyProducts] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityBeautyProduct)
        
        var beautyProducts: [BeautyProducts] = []
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            print("Result = \(result)")
            for data in result {
                let product = BeautyProducts(
                    id: data.value(forKey: "id") as? Int,
                    title: data.value(forKey: "title") as? String,
                    description: data.value(forKey: "desc") as? String,
                    category: data.value(forKey: "category") as? String,
                    price: data.value(forKey: "price") as? Double,
                    discountPercentage: data.value(forKey: "discountPercentage") as? Double,
                    rating: data.value(forKey: "rating") as? Double,
                    stock: data.value(forKey: "stock") as? Int,
                    tags: data.value(forKey: "tags") as? [String],
                    brand: data.value(forKey: "brand") as? String,
                    sku: data.value(forKey: "sku") as? String,
                    weight: data.value(forKey: "weight") as? Int,
                    warrantyInformation: data.value(forKey: "warrantyInformation") as? String,
                    shippingInformation: data.value(forKey: "shippingInformation") as? String,
                    availabilityStatus: data.value(forKey: "availabilityStatus") as? String,
                    returnPolicy: data.value(forKey: "returnPolicy") as? String,
                    minimumOrderQuantity: data.value(forKey: "minimumOrderQuantity") as? Int,
                    images: data.value(forKey: "images") as? [String],
                    thumbnail: data.value(forKey: "thumbnail") as? String
                )
                beautyProducts.append(product)
            }
            
        } catch {
            print("error fetching data")
        }
        print("\n\nData\n\(beautyProducts)\n\n")
        return beautyProducts
    }
    
    func updateData(_ beautyProducts: [BeautyProducts]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityBeautyProduct)
        
        do {
            let existingProducts = try managedContext.fetch(fetchRequest)
            
            for product in beautyProducts {
                let productId = product.id ?? 0
                
                let targetProduct = existingProducts.first(where: {
                    ($0.value(forKey: "id") as? Int) == productId
                }) ?? {
                    let entity = NSEntityDescription.entity(forEntityName: entityBeautyProduct, in: managedContext)!
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
    
    func deleteData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityBeautyProduct)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete all data. \(error), \(error.userInfo)")
        }
    }
}
