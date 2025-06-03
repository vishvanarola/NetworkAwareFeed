//
//  ProductModel.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import Foundation

struct ProductModel : Codable {
    let products : [ProductsData]?
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
        products = try values.decodeIfPresent([ProductsData].self, forKey: .products)
        total = try values.decodeIfPresent(Int.self, forKey: .total)
        skip = try values.decodeIfPresent(Int.self, forKey: .skip)
        limit = try values.decodeIfPresent(Int.self, forKey: .limit)
    }
    
}

struct ProductsData: Codable {
    let id: Int?
    let title: String?
    let description: String?
    let category: String?
    let price: Double?
    let discountPercentage: Double?
    let rating: Double?
    let stock: Int?
    let tags: [String]?
    let brand: String?
    let sku: String?
    let weight: Int?
    let warrantyInformation: String?
    let shippingInformation: String?
    let availabilityStatus: String?
    let reviews: [ReviewsData]?
    let returnPolicy: String?
    let minimumOrderQuantity: Int?
    let images: [String]?
    let thumbnail: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, category, price, discountPercentage, rating, stock, tags, brand, sku, weight, warrantyInformation, shippingInformation, availabilityStatus, reviews, returnPolicy, minimumOrderQuantity, images, thumbnail
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
        reviews = try values.decodeIfPresent([ReviewsData].self, forKey: .reviews)
        returnPolicy = try values.decodeIfPresent(String.self, forKey: .returnPolicy)
        minimumOrderQuantity = try values.decodeIfPresent(Int.self, forKey: .minimumOrderQuantity)
        images = try values.decodeIfPresent([String].self, forKey: .images)
        thumbnail = try values.decodeIfPresent(String.self, forKey: .thumbnail)
    }
    
    // ✅ Manual initializer for Core Data mapping
    init(
        id: Int?,
        title: String?,
        description: String?,
        category: String?,
        price: Double?,
        discountPercentage: Double?,
        rating: Double?,
        stock: Int?,
        tags: [String]?,
        brand: String?,
        sku: String?,
        weight: Int?,
        warrantyInformation: String?,
        shippingInformation: String?,
        availabilityStatus: String?,
        reviews: [ReviewsData]?,
        returnPolicy: String?,
        minimumOrderQuantity: Int?,
        images: [String]?,
        thumbnail: String?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.price = price
        self.discountPercentage = discountPercentage
        self.rating = rating
        self.stock = stock
        self.tags = tags
        self.brand = brand
        self.sku = sku
        self.weight = weight
        self.warrantyInformation = warrantyInformation
        self.shippingInformation = shippingInformation
        self.availabilityStatus = availabilityStatus
        self.reviews = reviews
        self.returnPolicy = returnPolicy
        self.minimumOrderQuantity = minimumOrderQuantity
        self.images = images
        self.thumbnail = thumbnail
    }
}

struct ReviewsData: Codable {
    let rating: Int?
    let comment: String?
    let date: String?
    let reviewerName: String?
    let reviewerEmail: String?
    
    enum CodingKeys: String, CodingKey {
        case rating, comment, date, reviewerName, reviewerEmail
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        rating = try values.decodeIfPresent(Int.self, forKey: .rating)
        comment = try values.decodeIfPresent(String.self, forKey: .comment)
        date = try values.decodeIfPresent(String.self, forKey: .date)
        reviewerName = try values.decodeIfPresent(String.self, forKey: .reviewerName)
        reviewerEmail = try values.decodeIfPresent(String.self, forKey: .reviewerEmail)
    }
    
    init(
        rating: Int?,
        comment: String?,
        date: String?,
        reviewerName: String?,
        reviewerEmail: String?
    ) {
        self.rating = rating
        self.comment = comment
        self.date = date
        self.reviewerName = reviewerName
        self.reviewerEmail = reviewerEmail
    }
}
