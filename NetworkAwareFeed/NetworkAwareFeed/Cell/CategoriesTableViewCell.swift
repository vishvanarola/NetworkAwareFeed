//
//  CategoriesTableViewCell.swift
//  NetworkAwareFeed
//
//  Created by apple on 05/06/25.
//

import UIKit

class CategoriesTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    //MARK: - Properties
    static let identifier = "CategoriesTableViewCell"
    
    //MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK: - UI Setup
    private func setupUI() {
        // Cell configuration
        self.selectionStyle = .none
        self.contentView.backgroundColor = .clear
        
        // Main view styling
        self.mainView.backgroundColor = .systemBackground
        
        // Label styling
        self.categoryLabel.textColor = .label
        self.categoryLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        self.categoryLabel.numberOfLines = 2
    }
    
    // MARK: - Configuration
    func configure(category: String) {
        self.categoryLabel.text = category
    }
}
