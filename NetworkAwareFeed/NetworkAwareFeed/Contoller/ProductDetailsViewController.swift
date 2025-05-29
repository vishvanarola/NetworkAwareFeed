//
//  ProductDetailsViewController.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import UIKit

class ProductDetailsViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var listCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var stockHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var minOrderLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var warrantyLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var returnsLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var buyNowButton: UIButton!
    
    // MARK: - Properties
    var beautyProductDetails: BeautyProducts?
    private lazy var scrollViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCollectionViewTap))
    private let cartManager = CartManager.shared
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureCollectionView()
        configureProductData()
        setupCartButtons()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Apply a unified style to the view
        view.backgroundColor = .systemBackground
        
        // Style the header
        headingLabel.textColor = .label
        
        // Configure page control
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.pageIndicatorTintColor = .systemGray3
        
        // Style price and discount labels
        priceLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        priceLabel.textColor = .systemBlue
        
        discountLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        discountLabel.textColor = .systemGreen
        discountLabel.layer.cornerRadius = 8
        discountLabel.layer.masksToBounds = true
        discountLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        discountLabel.textAlignment = .center
        
        // Style stock label
        stockLabel.backgroundColor = .systemRed.withAlphaComponent(0.1)
        stockLabel.textColor = .systemRed
        stockLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        stockLabel.layer.cornerRadius = 8
        stockLabel.layer.masksToBounds = true
        stockLabel.textAlignment = .center
        
        // Description styling
        descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        
        // Style info labels
        let infoLabels = [brandLabel, categoryLabel, availabilityLabel, minOrderLabel, 
                          weightLabel, ratingLabel, warrantyLabel, shippingLabel, 
                          returnsLabel, tagsLabel]
        
        for label in infoLabels {
            label?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label?.textColor = .secondaryLabel
        }
        
        // Add tap gesture to collection view
        listCollectionView.addGestureRecognizer(scrollViewGestureRecognizer)
                
        addToCartButton.layer.cornerRadius = 12
        buyNowButton.layer.cornerRadius = 12
    }
    
    private func setupCartButtons() {
        // Update buttons state based on stock availability
        let isOutOfStock = beautyProductDetails?.stock == 0
        addToCartButton.isEnabled = !isOutOfStock
        buyNowButton.isEnabled = !isOutOfStock
        
        if isOutOfStock {
            addToCartButton.backgroundColor = .systemGray3
            buyNowButton.backgroundColor = .systemGray3
            addToCartButton.setTitle("Out of Stock", for: .disabled)
            buyNowButton.setTitle("Out of Stock", for: .disabled)
        }
    }
    
    // MARK: - UI Configuration
    /// Configures the collection view layout, delegate, and data source.
    private func configureCollectionView() {
        self.listCollectionView.backgroundColor = .clear
        self.listCollectionView.delegate = self
        self.listCollectionView.dataSource = self
        self.listCollectionView.isPagingEnabled = true
        self.listCollectionView.showsHorizontalScrollIndicator = false
        
        // Add a shadow to the collection view
        listCollectionView.layer.shadowColor = UIColor.black.cgColor
        listCollectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        listCollectionView.layer.shadowOpacity = 0.1
        listCollectionView.layer.shadowRadius = 6
        
        self.listCollectionView.register(
            UINib(nibName: BeautyProductCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: BeautyProductCollectionViewCell.identifier
        )
    }
    
    /// Sets up the UI elements with the product data.
    private func configureProductData() {
        guard let product = self.beautyProductDetails else { return }
        
        // Animate the content appearance
        UIView.animate(withDuration: 0.3) {
            // Product title
            self.headingLabel.text = product.title
            self.headingLabel.isHidden = product.title?.isEmpty ?? true
            
            // Configure page control
            let imageCount = product.images?.count ?? 0
            self.pageControl.isHidden = imageCount <= 1
            self.pageControl.numberOfPages = imageCount
            self.pageControl.currentPage = 0
            
            // Brand with conditional display
            if let brand = product.brand, !brand.isEmpty {
                self.brandLabel.text = "🏷️ Brand: " + brand
                self.brandLabel.isHidden = false
            } else {
                self.brandLabel.isHidden = true
            }
            
            // Category with conditional display
            if let category = product.category, !category.isEmpty {
                self.categoryLabel.text = "🗂️ Category: " + category
                self.categoryLabel.isHidden = false
            } else {
                self.categoryLabel.isHidden = true
            }
            
            // Price with conditional display
            if let price = product.price, price > 0 {
                self.priceLabel.text = "$\(price)"
                self.priceLabel.isHidden = false
            } else {
                self.priceLabel.isHidden = true
            }
            
            // Discount with conditional display
            if let discount = product.discountPercentage, discount > 0 {
                self.discountLabel.text = "  \(discount)% OFF  "
                self.discountLabel.isHidden = false
            } else {
                self.discountLabel.isHidden = true
            }
            
            // Stock status
            let stockValue = product.stock ?? 0
            self.stockLabel.isHidden = stockValue >= 10
            self.stockHeightConstraint.constant = stockValue >= 10 ? 0 : 26
            if stockValue < 10 && stockValue > 0 {
                self.stockLabel.text = "  Only \(stockValue) left in stock!  "
            } else if stockValue == 0 {
                self.stockLabel.text = "  Out of stock!  "
                self.stockLabel.isHidden = false
                self.stockHeightConstraint.constant = 26
            }
            
            // Availability status with conditional display
            if let availability = product.availabilityStatus, !availability.isEmpty {
                self.availabilityLabel.text = "📦 Status: " + availability
                self.availabilityLabel.textColor = availability.contains("In") ? .systemGreen : .systemRed
                self.availabilityLabel.isHidden = false
            } else {
                self.availabilityLabel.isHidden = true
            }
            
            // Min order quantity with conditional display
            if let minOrderQty = product.minimumOrderQuantity, minOrderQty > 0 {
                self.minOrderLabel.text = "🛒 Min Order: \(minOrderQty) units"
                self.minOrderLabel.isHidden = false
            } else {
                self.minOrderLabel.isHidden = true
            }
            
            // Description with conditional display
            if let description = product.description, !description.isEmpty {
                self.descriptionLabel.text = description
                self.descriptionLabel.isHidden = false
            } else {
                self.descriptionLabel.isHidden = true
            }
            
            // Weight with conditional display
            if let weight = product.weight, weight > 0 {
                self.weightLabel.text = "⚖️ Weight: \(weight)g"
                self.weightLabel.isHidden = false
            } else {
                self.weightLabel.isHidden = true
            }
            
            // Rating with conditional display and visualization
            if let rating = product.rating, rating > 0 {
                let fullStars = Int(rating)
                let halfStar = rating - Double(fullStars) >= 0.5
                
                var ratingText = "⭐️ Rating: "
                for _ in 0..<fullStars {
                    ratingText += "★"
                }
                if halfStar {
                    ratingText += "½"
                }
                for _ in 0..<(5-fullStars-(halfStar ? 1 : 0)) {
                    ratingText += "☆"
                }
                ratingText += " (\(rating)/5)"
                self.ratingLabel.text = ratingText
                self.ratingLabel.isHidden = false
            } else {
                self.ratingLabel.isHidden = true
            }
            
            // Warranty with conditional display
            if let warranty = product.warrantyInformation, !warranty.isEmpty {
                self.warrantyLabel.text = "🔒 Warranty: " + warranty
                self.warrantyLabel.isHidden = false
            } else {
                self.warrantyLabel.isHidden = true
            }
            
            // Shipping with conditional display
            if let shipping = product.shippingInformation, !shipping.isEmpty {
                self.shippingLabel.text = "🚚 Shipping: " + shipping
                self.shippingLabel.isHidden = false
            } else {
                self.shippingLabel.isHidden = true
            }
            
            // Returns with conditional display
            if let returns = product.returnPolicy, !returns.isEmpty {
                self.returnsLabel.text = "↩️ Returns: " + returns
                self.returnsLabel.isHidden = false
            } else {
                self.returnsLabel.isHidden = true
            }
            
            // Tags with conditional display
            if let tags = product.tags, !tags.isEmpty {
                self.tagsLabel.text = "🏷️ Tags: " + tags.map { "• \($0)" }.joined(separator: " ")
                self.tagsLabel.isHidden = false
            } else {
                self.tagsLabel.isHidden = true
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleCollectionViewTap(_ gesture: UITapGestureRecognizer) {
        // Enhance the viewing experience by zooming in the image when tapped
        let location = gesture.location(in: listCollectionView)
        if let indexPath = listCollectionView.indexPathForItem(at: location) {
            // Could implement a full-screen image viewer here
            animateImageTap(at: indexPath)
        }
    }
    
    private func animateImageTap(at indexPath: IndexPath) {
        if let cell = listCollectionView.cellForItem(at: indexPath) as? BeautyProductCollectionViewCell {
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    cell.transform = .identity
                }
            })
        }
    }
    
    @IBAction private func addToCartTapped() {
        guard let product = beautyProductDetails else { return }
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Show quantity selector
        let alert = UIAlertController(
            title: "Select Quantity",
            message: "How many items would you like to add to cart?",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.text = "1"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add to Cart", style: .default) { [weak self] _ in
            guard let quantity = Int(alert.textFields?.first?.text ?? "1") else { return }
            self?.cartManager.addToCart(product: product, quantity: quantity)
            
            // Show success message
            let successAlert = UIAlertController(
                title: "Added to Cart",
                message: "\(quantity) item(s) added to your cart",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "Continue Shopping", style: .default))
            successAlert.addAction(UIAlertAction(title: "View Cart", style: .default) { [weak self] _ in
                self?.showCart()
            })
            self?.present(successAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
    
    @IBAction private func buyNowTapped() {
        guard let product = beautyProductDetails else { return }
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Clear cart and add this item
        cartManager.clearCart()
        cartManager.addToCart(product: product)
        
        // Show cart/checkout screen
        showCart()
    }
    
    @IBAction private func cartButtonTapped() {
        showCart()
    }
    
    private func showCart() {
        guard let cartVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "CartViewController") as? CartViewController else {
            return
        }
        navigationController?.pushViewController(cartVC, animated: true)
    }
}

//MARK: - Collection View Delegate & Data Source
extension ProductDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.beautyProductDetails?.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.listCollectionView.dequeueReusableCell(withReuseIdentifier: BeautyProductCollectionViewCell.identifier, for: indexPath) as! BeautyProductCollectionViewCell
        cell.setUpData(imgUrl: self.beautyProductDetails?.images?[indexPath.row] ?? "", id: self.beautyProductDetails?.id ?? 0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.listCollectionView.frame.width, height: self.listCollectionView.frame.height)
    }
}

//MARK: - Scroll View Delegate
extension ProductDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        self.pageControl.currentPage = page
    }
}
