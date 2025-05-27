//
//  BeautyProductTableViewCell.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import UIKit
import SDWebImage

class BeautyProductTableViewCell: UITableViewCell {
    
    //MARK: - Outlet
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    //MARK: - Declaration
    static let identifier = "BeautyProductTableViewCell"
    
    //MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgView.layer.borderColor = UIColor.lightGray.cgColor
        self.imgView.layer.borderWidth = 0.5
        self.imgView.layer.cornerRadius = 8
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Set up Data
    func setUpData(img: String, title: String, desc: String) {
        self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imgView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(systemName: "photo.fill"), options: .refreshCached)
        self.titleLabel.text = title
        self.descLabel.text = desc
    }
}
