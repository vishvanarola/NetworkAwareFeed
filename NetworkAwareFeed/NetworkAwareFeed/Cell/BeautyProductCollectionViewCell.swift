//
//  BeautyProductCollectionViewCell.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import UIKit
import SDWebImage

class BeautyProductCollectionViewCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var imgView: UIImageView!
    
    //MARK: - Properties
    static let identifier = "BeautyProductCollectionViewCell"
    
    //MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - Set up Data
    func setUpData(imgUrl: String) {
        self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imgView.sd_setImage(
            with: URL(string: imgUrl),
            placeholderImage: UIImage(systemName: "photo.fill"),
            options: ReachabilityManager.shared.isNetworkAvailable ? [.refreshCached] : [.fromCacheOnly]
        )
    }
}
