//
//  ReviewsTableViewCell.swift
//  NetworkAwareFeed
//
//  Created by apple on 03/06/25.
//

import UIKit

class ReviewsTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var reviewerNameLabel: UILabel!
    
    //MARK: - Properties
    static let identifier = "ReviewsTableViewCell"
    
    //MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
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
        
        // Rating view
        self.ratingView.layer.cornerRadius = 10
    }
    
    //MARK: - Set up Data
    func setUpData(rating: Int, date: String, comment: String, name: String) {
        self.ratingLabel.text = "\(rating)"
        self.dateLabel.text = date.relativeTimeFromNow()
        self.commentLabel.text = comment
        self.reviewerNameLabel.text = name
    }
}
