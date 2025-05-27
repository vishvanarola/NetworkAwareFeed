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
        self.contentView.backgroundColor = .clear
        self.mainView.backgroundColor = .systemGray5.withAlphaComponent(0.7)
        self.mainView.layer.cornerRadius = 8
        self.imgView.backgroundColor = .white
        self.imgView.layer.borderColor = UIColor.lightGray.cgColor
        self.imgView.layer.borderWidth = 0.5
        self.imgView.layer.cornerRadius = 8
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Set up Data
    func setUpData(img: String, title: String, price: String) {
        self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imgView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(systemName: "photo.fill"), options: .refreshCached)
        self.titleLabel.text = title
        self.priceLabel.text = price
    }
}
