//
//  ImageCacheManager.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import Foundation
import UIKit

// MARK: - Image Cache Manager

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let diskCacheURL: URL
    
    private init() {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cacheDirectory.appendingPathComponent("ImageCache")
        
        if !fileManager.fileExists(atPath: diskCacheURL.path) {
            try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        }
    }
    
    func getImage(for url: URL, id: String) -> UIImage? {
        // Create a unique key using both product ID and URL
        let uniqueKey = "\(id)_\(url.absoluteString.hash)" as NSString
        
        // First try memory cache
        if let image = memoryCache.object(forKey: uniqueKey) {
            return image
        }
        
        // Then try disk cache with unique filename based on product ID and URL hash
        let filePath = diskCacheURL.appendingPathComponent("image_\(id)_\(url.absoluteString.hash)")
        if let data = try? Data(contentsOf: filePath), let image = UIImage(data: data) {
            // Cache the image in memory for faster future access
            memoryCache.setObject(image, forKey: uniqueKey)
            return image
        }
        
        return nil
    }
    
    func save(_ image: UIImage, for url: URL, id: String) {
        // Create a unique key using both product ID and URL
        let uniqueKey = "\(id)_\(url.absoluteString.hash)" as NSString
        
        // Save to memory cache
        memoryCache.setObject(image, forKey: uniqueKey)
        
        // Save to disk with unique filename based on product ID and URL hash
        let filePath = diskCacheURL.appendingPathComponent("image_\(id)_\(url.absoluteString.hash)")
        if let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: filePath)
        }
    }
}
