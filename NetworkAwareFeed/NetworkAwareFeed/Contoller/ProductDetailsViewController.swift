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
    
    // MARK: - Properties
    var beautyProductDetails: BeautyProducts?
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.configureUI()
    }
    
    // MARK: - UI Configuration
    /// Configures the collection view layout, delegate, and data source.
    private func configureCollectionView() {
        self.listCollectionView.backgroundColor = .clear
        self.listCollectionView.delegate = self
        self.listCollectionView.dataSource = self
        self.listCollectionView.isPagingEnabled = true
        self.listCollectionView.showsHorizontalScrollIndicator = false
        
        self.listCollectionView.register(
            UINib(nibName: BeautyProductCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: BeautyProductCollectionViewCell.identifier
        )
    }
    
    /// Sets up the UI elements with the product data.
    private func configureUI() {
        guard let product = self.beautyProductDetails else { return }
        self.headingLabel.text = product.title
        let imageCount = product.images?.count ?? 0
        self.pageControl.isHidden = imageCount <= 1
        self.pageControl.numberOfPages = imageCount
        self.pageControl.currentPage = 0
        self.brandLabel.text = "Brand: " + (product.brand ?? "")
        self.categoryLabel.text = "Category: " + (product.category ?? "")
        self.priceLabel.text = "$\(product.price ?? 0.0)"
        self.discountLabel.text = "\(product.discountPercentage ?? 0.0)% OFF"
        self.stockLabel.isHidden = (product.stock ?? 0) >= 10
        self.stockHeightConstraint.constant = (product.stock ?? 0) >= 10 ? 0 : 17
        self.availabilityLabel.text = (product.availabilityStatus ?? "")
        self.availabilityLabel.textColor = (product.availabilityStatus ?? "").contains("In") ? .systemGreen : .systemRed
        self.minOrderLabel.text = "Min Order Quantity: \(product.minimumOrderQuantity ?? 0)"
        self.descriptionLabel.text = (product.description ?? "")
        self.weightLabel.text = "Weight: \(product.weight ?? 0)"
        self.ratingLabel.text = "Rating: ⭐️ \(product.rating ?? 0.0)/5"
        self.warrantyLabel.text = "Warranty: " + (product.warrantyInformation ?? "")
        self.shippingLabel.text = "Shipping: " + (product.shippingInformation ?? "")
        self.returnsLabel.text = "Returns: " + (product.returnPolicy ?? "")
        if let tags = product.tags, !tags.isEmpty {
            self.tagsLabel.text = "Tags: \(tags.joined(separator: ", "))"
        }
    }
    
    // MARK: - Actions
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - Collection View Delegate & Data Source
extension ProductDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.beautyProductDetails?.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.listCollectionView.dequeueReusableCell(withReuseIdentifier: BeautyProductCollectionViewCell.identifier, for: indexPath) as! BeautyProductCollectionViewCell
        cell.setUpData(imgUrl: self.beautyProductDetails?.images?[indexPath.row] ?? "")
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
