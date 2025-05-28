//
//  BeautyProductTableViewCell.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import UIKit
import SDWebImage

class BeautyProductTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    //MARK: - Properties
    static let identifier = "BeautyProductTableViewCell"
    
    //MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        animateSelection(selected)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.mainView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
    
    //MARK: - UI Setup
    private func setupUI() {
        // Cell configuration
        self.selectionStyle = .none
        self.contentView.backgroundColor = .clear
        
        // Main view styling
        self.mainView.backgroundColor = .systemBackground
        self.mainView.layer.cornerRadius = 12
        self.mainView.clipsToBounds = false
        
        // Add shadow
        self.mainView.layer.shadowColor = UIColor.black.cgColor
        self.mainView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.mainView.layer.shadowOpacity = 0.1
        self.mainView.layer.shadowRadius = 4
        
        // Image view styling
        self.imgView.backgroundColor = .systemGray6
        self.imgView.contentMode = .scaleAspectFill
        self.imgView.layer.cornerRadius = 10
        self.imgView.clipsToBounds = true
        
        // Label styling
        self.titleLabel.textColor = .label
        self.titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        self.titleLabel.numberOfLines = 2
        
        self.priceLabel.textColor = .systemBlue
        self.priceLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    private func animateSelection(_ selected: Bool) {
        if selected {
            UIView.animate(withDuration: 0.2, animations: {
                self.mainView.backgroundColor = UIColor.systemGray6
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.mainView.backgroundColor = .systemBackground
            })
        }
    }
    
    //MARK: - Set up Data
    func setUpData(imgUrl: String, title: String, price: String, id: Int) {
        // Handle title - hide if empty
        if !title.isEmpty {
            self.titleLabel.text = title
            self.titleLabel.isHidden = false
        } else {
            self.titleLabel.isHidden = true
        }
        
        // Handle price - hide if empty or zero
        if !price.isEmpty && price != "$0.0" {
            self.priceLabel.text = price
            self.priceLabel.isHidden = false
        } else {
            self.priceLabel.isHidden = true
        }
        
        // Add subtle loading animation
        UIView.transition(with: self.imgView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            // Don't try to load image if URL is empty
            if !imgUrl.isEmpty {
                if ReachabilityManager.shared.isNetworkAvailable {
                    self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    self.imgView.sd_setImage(
                        with: URL(string: imgUrl),
                        placeholderImage: UIImage(systemName: "photo.fill"),
                        options: [.refreshCached],
                        completed: { (image, error, cacheType, url) in
                            // Apply subtle zoom animation for newly loaded images
                            if cacheType == .none, image != nil {
                                self.imgView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                                UIView.animate(withDuration: 0.3) {
                                    self.imgView.transform = .identity
                                }
                            }
                        }
                    )
                } else {
                    if let url = URL(string: imgUrl) {
                        if let cachedImage = ImageCacheManager.shared.getImage(for: url, id: "\(id)") {
                            self.imgView.image = cachedImage
                        } else {
                            self.imgView.image = UIImage(systemName: "photo.fill")
                        }
                    } else {
                        self.imgView.image = UIImage(systemName: "photo.fill")
                    }
                }
            } else {
                // No image URL provided
                self.imgView.image = UIImage(systemName: "photo.fill")
            }
        })
    }
}
