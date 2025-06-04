//
//  ProductDetailsViewController.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import UIKit
import Cosmos

class ProductDetailsViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var listCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var onlyLeftLabel: UILabel!
    @IBOutlet weak var stockHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
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
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var reviewsButton: UIButton!
    @IBOutlet weak var reviewCountLabel: UILabel!
    
    // MARK: - Properties
    var productDetails: ProductsData?
    private lazy var scrollViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCollectionViewTap))
    private let cartDataManager = CartDataManager()
    
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
        onlyLeftLabel.backgroundColor = .systemRed.withAlphaComponent(0.1)
        onlyLeftLabel.textColor = .systemRed
        onlyLeftLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        onlyLeftLabel.layer.cornerRadius = 8
        onlyLeftLabel.layer.masksToBounds = true
        onlyLeftLabel.textAlignment = .center
        
        // Description styling
        descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        
        // Style info labels
        let infoLabels = [brandLabel, categoryLabel, availabilityLabel, stockLabel, minOrderLabel, weightLabel, ratingLabel, warrantyLabel, shippingLabel, returnsLabel, tagsLabel]
        
        for label in infoLabels {
            label?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label?.textColor = .secondaryLabel
        }
        
        // Add tap gesture to collection view
        listCollectionView.addGestureRecognizer(scrollViewGestureRecognizer)
        
        //Button Coreners
        addToCartButton.layer.cornerRadius = 12
        buyNowButton.layer.cornerRadius = 12
        
        //Cosmos View
        cosmosView.settings.fillMode = .precise
        cosmosView.settings.updateOnTouch = false
        cosmosView.isUserInteractionEnabled = false
        cosmosView.settings.starMargin = 0
        cosmosView.settings.filledColor = yellowColor
        cosmosView.settings.emptyBorderColor = yellowColor
        cosmosView.settings.filledBorderColor = yellowColor
        cosmosView.settings.emptyBorderWidth = 1.2
    }
    
    private func setupCartButtons() {
        // Update buttons state based on stock availability
        let isOutOfStock = productDetails?.stock == 0
        addToCartButton.isEnabled = !isOutOfStock
        buyNowButton.isEnabled = !isOutOfStock
        
        if isOutOfStock {
            addToCartButton.backgroundColor = .systemGray3
            buyNowButton.backgroundColor = .systemGray3
            addToCartButton.setTitle(TextMessage.outOfStock, for: .disabled)
            buyNowButton.setTitle(TextMessage.outOfStock, for: .disabled)
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
        self.listCollectionView.layer.shadowColor = UIColor.black.cgColor
        self.listCollectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.listCollectionView.layer.shadowOpacity = 0.1
        self.listCollectionView.layer.shadowRadius = 6
        
        self.listCollectionView.register(
            UINib(nibName: ProductCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: ProductCollectionViewCell.identifier
        )
    }
    
    /// Sets up the UI elements with the product data.
    private func configureProductData() {
        guard let product = self.productDetails else { return }
        
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
                self.brandLabel.text = "🏷️ \(TextMessage.brand): " + brand
                self.brandLabel.isHidden = false
            } else {
                self.brandLabel.isHidden = true
            }
            
            // Category with conditional display
            if let category = product.category, !category.isEmpty {
                self.categoryLabel.text = "🗂️ \(TextMessage.category): " + category
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
            self.onlyLeftLabel.isHidden = stockValue >= 10
            self.stockHeightConstraint.constant = stockValue >= 10 ? 0 : 26
            if stockValue < 10 && stockValue > 0 {
                self.onlyLeftLabel.text = "  Only \(stockValue) left in stock!  "
            } else if stockValue == 0 {
                self.onlyLeftLabel.text = "  \(TextMessage.outOfStock)!  "
                self.onlyLeftLabel.isHidden = false
                self.stockHeightConstraint.constant = 26
            }
            
            // Availability status with conditional display
            if let availability = product.availabilityStatus, !availability.isEmpty {
                self.stockLabel.text = "📦 \(TextMessage.status): " + availability
                self.stockLabel.textColor = availability.contains("In") ? .systemGreen : .systemRed
                self.stockLabel.isHidden = false
            } else {
                self.stockLabel.isHidden = true
            }
            
            // Min order quantity with conditional display
            if let minOrderQty = product.minimumOrderQuantity, minOrderQty > 0 {
                self.minOrderLabel.text = "🛒 \(TextMessage.minOrder): \(minOrderQty) \(TextMessage.units)"
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
                self.weightLabel.text = "⚖️ \(TextMessage.weight): \(weight)g"
                self.weightLabel.isHidden = false
            } else {
                self.weightLabel.isHidden = true
            }
            
            // Rating with conditional display and visualization
            if let rating = product.rating, rating > 0 {
                self.ratingLabel.text = "⭐️ \(TextMessage.rating): \(rating)/5"
                self.ratingLabel.isHidden = false
                print(rating)
                self.cosmosView.rating = rating
            } else {
                self.ratingLabel.isHidden = true
            }
            
            // Warranty with conditional display
            if let warranty = product.warrantyInformation, !warranty.isEmpty {
                self.warrantyLabel.text = "🔒 \(TextMessage.warranty): " + warranty
                self.warrantyLabel.isHidden = false
            } else {
                self.warrantyLabel.isHidden = true
            }
            
            // Shipping with conditional display
            if let shipping = product.shippingInformation, !shipping.isEmpty {
                self.shippingLabel.text = "🚚 \(TextMessage.shipping): " + shipping
                self.shippingLabel.isHidden = false
            } else {
                self.shippingLabel.isHidden = true
            }
            
            // Returns with conditional display
            if let returns = product.returnPolicy, !returns.isEmpty {
                self.returnsLabel.text = "↩️ \(TextMessage.returns): " + returns
                self.returnsLabel.isHidden = false
            } else {
                self.returnsLabel.isHidden = true
            }
            
            // Tags with conditional display
            if let tags = product.tags, !tags.isEmpty {
                self.tagsLabel.text = "🏷️ \(TextMessage.tags): " + tags.map { "• \($0)" }.joined(separator: " ")
                self.tagsLabel.isHidden = false
            } else {
                self.tagsLabel.isHidden = true
            }
            
            // Configure Reviews Button
            let reviewCount = product.reviews?.count ?? 0
            self.reviewCountLabel.text = "(\(reviewCount) \(reviewCount == 1 ? "Review" : "Reviews"))"
            self.reviewsButton.isHidden = reviewCount == 0
            self.reviewCountLabel.isHidden = reviewCount == 0
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
        if let cell = listCollectionView.cellForItem(at: indexPath) as? ProductCollectionViewCell {
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
        guard let product = productDetails else { return }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let alert = UIAlertController(title: TextMessage.selectQuantity, message: TextMessage.howManyItemsAddToCart, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.text = "1"
        }
        
        alert.addAction(UIAlertAction(title: TextMessage.cancel, style: .cancel))
        
        alert.addAction(UIAlertAction(title: TextMessage.addToCart, style: .default) { [weak self] _ in
            guard let self = self,
                  let quantityText = alert.textFields?.first?.text,
                  let quantity = Int(quantityText),
                  quantity > 0 else {
                AlertViewManager.showAlert(title: TextMessage.invalidQuantity, message: TextMessage.enterValidNumber)
                return
            }
            
            let totalStock = product.stock ?? 0
            let alreadyInCart = self.cartDataManager.getQuantityForProduct(product.id ?? 0)
            let availableStock = totalStock - alreadyInCart
            
            guard availableStock > 0 else {
                AlertViewManager.showAlert(title: TextMessage.stockUnavailable, message: TextMessage.allAvailableStockInYourCart)
                return
            }
            
            if quantity > availableStock {
                AlertViewManager.showAlert(title: TextMessage.stockLimitExceeded, message: "You can only add \(availableStock) more item(s) to the cart.")
                return
            }
            
            self.cartDataManager.addProductToCart(product, quantity: quantity)
            
            let successAlert = UIAlertController(title: TextMessage.addToCart, message: "\(quantity) item(s) added to your cart", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: TextMessage.continueShopping, style: .default))
            successAlert.addAction(UIAlertAction(title: TextMessage.viewCart, style: .default) { _ in
                self.showCart()
            })
            self.present(successAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
    
    @IBAction private func buyNowTapped() {
        guard let product = productDetails else { return }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        cartDataManager.clearCart()
        cartDataManager.addProductToCart(product, quantity: 1)
        
        DispatchQueue.main.async {
            self.showCart()
        }
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
    
    @IBAction private func reviewsButtonTapped() {
        guard let reviewVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ReviewsViewController") as? ReviewsViewController else { return }
        reviewVC.fetchedData = productDetails?.reviews ?? []
        navigationController?.pushViewController(reviewVC, animated: true)
        
    }
}

//MARK: - Collection View Delegate & Data Source
extension ProductDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productDetails?.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.listCollectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewCell.identifier, for: indexPath) as! ProductCollectionViewCell
        cell.setUpData(imgUrl: self.productDetails?.images?[indexPath.row] ?? "", id: self.productDetails?.id ?? 0)
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
