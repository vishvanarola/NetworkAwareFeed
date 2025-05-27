//
//  ImageCacheManager.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import Foundation
import UIKit

// MARK: - Image Cache Manager

class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
