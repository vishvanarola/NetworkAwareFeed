//
//  BeautyProductModel.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import Foundation

struct BeautyProductModel : Codable {
    let products : [BeautyProducts]?
    let total : Int?
    let skip : Int?
    let limit : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case products = "products"
        case total = "total"
        case skip = "skip"
        case limit = "limit"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        products = try values.decodeIfPresent([BeautyProducts].self, forKey: .products)
        total = try values.decodeIfPresent(Int.self, forKey: .total)
        skip = try values.decodeIfPresent(Int.self, forKey: .skip)
        limit = try values.decodeIfPresent(Int.self, forKey: .limit)
    }
    
}

struct BeautyProducts : Codable {
    let id : Int?
    let title : String?
    let description : String?
    let category : String?
    let price : Double?
    let discountPercentage : Double?
    let rating : Double?
    let stock : Int?
    let tags : [String]?
    let brand : String?
    let sku : String?
    let weight : Int?
    let warrantyInformation : String?
    let shippingInformation : String?
    let availabilityStatus : String?
    let returnPolicy : String?
    let minimumOrderQuantity : Int?
    let images : [String]?
    let thumbnail : String?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case title = "title"
        case description = "description"
        case category = "category"
        case price = "price"
        case discountPercentage = "discountPercentage"
        case rating = "rating"
        case stock = "stock"
        case tags = "tags"
        case brand = "brand"
        case sku = "sku"
        case weight = "weight"
        case warrantyInformation = "warrantyInformation"
        case shippingInformation = "shippingInformation"
        case availabilityStatus = "availabilityStatus"
        case returnPolicy = "returnPolicy"
        case minimumOrderQuantity = "minimumOrderQuantity"
        case images = "images"
        case thumbnail = "thumbnail"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        category = try values.decodeIfPresent(String.self, forKey: .category)
        price = try values.decodeIfPresent(Double.self, forKey: .price)
        discountPercentage = try values.decodeIfPresent(Double.self, forKey: .discountPercentage)
        rating = try values.decodeIfPresent(Double.self, forKey: .rating)
        stock = try values.decodeIfPresent(Int.self, forKey: .stock)
        tags = try values.decodeIfPresent([String].self, forKey: .tags)
        brand = try values.decodeIfPresent(String.self, forKey: .brand)
        sku = try values.decodeIfPresent(String.self, forKey: .sku)
        weight = try values.decodeIfPresent(Int.self, forKey: .weight)
        warrantyInformation = try values.decodeIfPresent(String.self, forKey: .warrantyInformation)
        shippingInformation = try values.decodeIfPresent(String.self, forKey: .shippingInformation)
        availabilityStatus = try values.decodeIfPresent(String.self, forKey: .availabilityStatus)
        returnPolicy = try values.decodeIfPresent(String.self, forKey: .returnPolicy)
        minimumOrderQuantity = try values.decodeIfPresent(Int.self, forKey: .minimumOrderQuantity)
        images = try values.decodeIfPresent([String].self, forKey: .images)
        thumbnail = try values.decodeIfPresent(String.self, forKey: .thumbnail)
    }
    
}
