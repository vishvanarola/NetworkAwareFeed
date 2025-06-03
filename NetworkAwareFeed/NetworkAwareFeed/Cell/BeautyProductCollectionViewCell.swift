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
    private var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.image = nil
        activityIndicator.startAnimating()
    }
    
    //MARK: - UI Setup
    private func setupUI() {
        // Configure the image view
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.backgroundColor = .systemGray6
        imgView.layer.cornerRadius = 12
        
        // Add a subtle border
        imgView.layer.borderWidth = 0.5
        imgView.layer.borderColor = UIColor.systemGray5.cgColor
        
        // Setup activity indicator
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemGray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        // Start animating
        activityIndicator.startAnimating()
    }
    
    //MARK: - Set up Data
    func setUpData(imgUrl: String, id: Int) {
        activityIndicator.startAnimating()
        
        // Check if the URL is empty
        if imgUrl.isEmpty {
            imgView.image = UIImage(systemName: "photo.fill")
            activityIndicator.stopAnimating()
            return
        }
        
        if ReachabilityManager.shared.isNetworkAvailable {
            // Add a subtle zoom animation for image loading
            imgView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            
            self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imgView.sd_setImage(
                with: URL(string: imgUrl),
                placeholderImage: UIImage(systemName: "photo.fill"),
                options: [.refreshCached],
                completed: { [weak self] (image, error, cacheType, url) in
                    self?.activityIndicator.stopAnimating()
                    
                    // Animate image appearance with a smooth zoom
                    if image != nil {
                        UIView.animate(withDuration: 0.3) {
                            self?.imgView.transform = .identity
                            self?.imgView.alpha = 1.0
                        }
                    } else {
                        // Handle error state
                        self?.imgView.transform = .identity
                        self?.imgView.alpha = 0.8
                    }
                }
            )
        } else {
            // When offline, use our custom ImageCacheManager with unique URL-based keys
            if let url = URL(string: imgUrl) {
                if let cachedImage = ImageCacheManager.shared.getImage(for: url, id: "\(id)") {
                    // Add a subtle animation when loading cached images
                    UIView.transition(with: imgView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self.imgView.image = cachedImage
                    }, completion: { _ in
                        self.activityIndicator.stopAnimating()
                    })
                    
                } else {
                    imgView.image = UIImage(systemName: "photo.fill")
                    activityIndicator.stopAnimating()
                    
                    // Apply a visual indication that the image is missing
                    imgView.alpha = 0.7
                    imgView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
                }
            } else {
                imgView.image = UIImage(systemName: "photo.fill")
                activityIndicator.stopAnimating()
            }
        }
    }
    
    // Add a subtle highlighting effect when tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animateHighlight(true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateHighlight(false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateHighlight(false)
    }
    
    private func animateHighlight(_ highlighted: Bool) {
        UIView.animate(withDuration: 0.1) {
            self.transform = highlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
        }
    }
}
