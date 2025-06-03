//
//  CartItemTableViewCell.swift
//  NetworkAwareFeed
//
//  Created by apple on 29/05/25.
//

import UIKit
import SDWebImage

// MARK: - CartItemCell Protocol
protocol CartItemCellDelegate: AnyObject {
    func cartItemCell(_ cell: CartItemTableViewCell, didUpdateQuantity quantity: Int, caseUpdate: Int)
    func cartItemCellDidTapRemove(_ cell: CartItemTableViewCell)
    func cartItemCellStockLimitReached(_ cell: CartItemTableViewCell, quantity: Int)
}

class CartItemTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    //MARK: - Properties
    static let identifier = "CartItemTableViewCell"
    weak var delegate: CartItemCellDelegate?
    private var quantity: Int = 1
    private var stock: Int = 1
    
    //MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
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
        
        // Buttons
        self.minusButton.layer.cornerRadius = 5
        self.plusButton.layer.cornerRadius = 5
    }
    
    // MARK: - Configuration
    func configure(with product: BeautyProducts, quantity: Int) {
        self.quantity = quantity
        self.stock = product.stock ?? 1
        titleLabel.text = product.title
        priceLabel.text = "$\(String(format: "%.2f", (product.price ?? 0) * Double(quantity)))"
        quantityLabel.text = "\(quantity)"
        
        if let thumbnail = product.thumbnail, let url = URL(string: thumbnail) {
            imgView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
        } else {
            imgView.image = UIImage(systemName: "photo")
        }
    }
    
    // MARK: - Actions
    @IBAction func minusButtonTapped() {
        if quantity > 1 {
            quantity -= 1
            quantityLabel.text = "\(quantity)"
            delegate?.cartItemCell(self, didUpdateQuantity: quantity, caseUpdate: 0)
        }
    }
    
    @IBAction private func plusButtonTapped() {
        if quantity < stock {
            quantity += 1
            delegate?.cartItemCell(self, didUpdateQuantity: quantity, caseUpdate: 1)
        } else {
            delegate?.cartItemCellStockLimitReached(self, quantity: quantity)
        }
    }
    
    @IBAction private func removeButtonTapped() {
        delegate?.cartItemCellDidTapRemove(self)
    }
}
