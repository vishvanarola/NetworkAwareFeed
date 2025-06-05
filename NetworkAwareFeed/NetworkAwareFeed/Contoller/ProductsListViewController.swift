//
//  ProductsListViewController.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import UIKit

class ProductsListViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var listCollectionView: UICollectionView!
    @IBOutlet weak var footerView: UIView!
    
    // MARK: - Properties
    private let viewModel = ProductsListViewModel()
    private let dataManager = ProductDataManager()
    private let refreshControl = UIRefreshControl()
    private var loadingIndicator: UIActivityIndicatorView!
    private var connectionStatusView: UIView!
    private var connectionStatusLabel: UILabel!
    private var selectedCategory: String? = nil
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initializeProductData()
        configureSegment()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Setup the view
        view.backgroundColor = .systemBackground
        
        // Setup loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .systemBlue
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        // Footer View Shadow
        footerView.backgroundColor = .systemBackground
        footerView.layer.shadowColor = UIColor.black.cgColor
        footerView.layer.shadowOpacity = 0.1
        footerView.layer.shadowOffset = CGSize(width: 0, height: -3) // shadow appears from top
        footerView.layer.shadowRadius = 6
        footerView.layer.masksToBounds = false
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Setup connection status bar
        setupConnectionStatusBar()
    }
    
    private func setupConnectionStatusBar() {
        connectionStatusView = UIView()
        connectionStatusView.translatesAutoresizingMaskIntoConstraints = false
        connectionStatusView.backgroundColor = .systemRed
        view.addSubview(connectionStatusView)
        
        connectionStatusLabel = UILabel()
        connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        connectionStatusLabel.textColor = .white
        connectionStatusLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        connectionStatusLabel.textAlignment = .center
        connectionStatusView.addSubview(connectionStatusLabel)
        
        NSLayoutConstraint.activate([
            // Place it right below the navigation bar instead of at the top of the safe area
            connectionStatusView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            connectionStatusView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            connectionStatusView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            connectionStatusView.heightAnchor.constraint(equalToConstant: 0), // Initially hidden
            
            connectionStatusLabel.topAnchor.constraint(equalTo: connectionStatusView.topAnchor),
            connectionStatusLabel.leadingAnchor.constraint(equalTo: connectionStatusView.leadingAnchor, constant: 10),
            connectionStatusLabel.trailingAnchor.constraint(equalTo: connectionStatusView.trailingAnchor, constant: -10),
            connectionStatusLabel.bottomAnchor.constraint(equalTo: connectionStatusView.bottomAnchor)
        ])
    }
    
    private func updateConnectionStatusBar() {
        let isConnected = ReachabilityManager.shared.isNetworkAvailable
        
        // Update UI on main thread
        DispatchQueue.main.async {
            // Configure the status bar appearance
            self.connectionStatusView.backgroundColor = isConnected ? .systemGreen : .systemRed
            self.connectionStatusLabel.text = isConnected ? TextMessage.onlineMode : TextMessage.offlineMode
            
            // Show or hide with animation
            UIView.animate(withDuration: 0.3) {
                let constraint = self.connectionStatusView.constraints.first { $0.firstAttribute == .height }
                constraint?.constant = isConnected ? 30 : 30 // Show the bar
                
                self.view.layoutIfNeeded()
                
                // Auto-hide the online status after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    UIView.animate(withDuration: 0.3) {
                        constraint?.constant = 0
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    // MARK: - Setup Methods
    private func configureTableView() {
        // Table view styling
        self.listTableView.backgroundColor = .systemBackground
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        self.listTableView.separatorStyle = .none
        self.listTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        self.listTableView.scrollIndicatorInsets = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        
        // Cell registration
        self.listTableView.register(UINib(nibName: ProductsListTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ProductsListTableViewCell.identifier)
        
        // Configure pull-to-refresh
        refreshControl.tintColor = .systemBlue
        refreshControl.attributedTitle = NSAttributedString(string: TextMessage.pullToRefresh)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        listTableView.refreshControl = refreshControl
    }
    
    private func configureCollectionView() {
        // Collection view styling
        self.listCollectionView.backgroundColor = .systemBackground
        self.listCollectionView.delegate = self
        self.listCollectionView.dataSource = self
        self.listCollectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        self.listCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        
        // Cell registration
        self.listCollectionView.register(UINib(nibName: ProductsGridCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ProductsGridCollectionViewCell.identifier)
    }
    
    private func configureSegment() {
        self.setUpListGrid("list")
    }
    
    @objc private func refreshData() {
        if ReachabilityManager.shared.isNetworkAvailable {
            self.viewModel.fetchProducts()
        } else {
            // Show offline message
            self.refreshControl.endRefreshing()
            self.updateConnectionStatusBar()
            
            // Add haptic feedback for error
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    private func bindViewModel() {
        // Show loading indicator
        loadingIndicator.startAnimating()
        listTableView.alpha = 0.6
        
        self.viewModel.onProductsFetched = { [weak self] in
            DispatchQueue.main.async {
                // Hide loading UI
                self?.loadingIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
                
                // Animate table view update
                UIView.animate(withDuration: 0.3) {
                    self?.listTableView.alpha = 1.0
                }
                
                // Add success haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                // Reload with animation
                self?.listTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
            
            // Move database operations to background thread
            // Since our dataManager now handles main thread access properly, 
            // we can use a background thread without issues
            DispatchQueue.global(qos: .background).async {
                let products = self?.viewModel.products ?? [ProductsData]()
                if self?.retrieveProductsCount() == 0 {
                    self?.dataManager.createData(products)
                } else {
                    self?.dataManager.updateData(products)
                }
            }
        }
        
        self.viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                // Hide loading UI
                self?.loadingIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
                self?.listTableView.alpha = 1.0
                
                // Show error alert
                self?.showErrorAlert(message: error.localizedDescription)
                
                // Add error haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
            
            print("❌ Error: \(error.localizedDescription)")
        }
    }
    
    private func showErrorAlert(message: String) {
        AlertViewManager.showAlert(title: TextMessage.errorLoadingData, message: "Could not load products: \(message)")
    }
    
    // Helper method to get count from Core Data
    private func retrieveProductsCount() -> Int {
        return dataManager.retrieveData().count
    }
    
    private func initializeProductData() {
        // Update connection status to show offline mode
        updateConnectionStatusBar()
        
        if ReachabilityManager.shared.isNetworkAvailable {
            self.bindViewModel()
            self.viewModel.fetchProducts()
        } else {
            // Show loading indicator
            loadingIndicator.startAnimating()
            
            // Load local data on a background thread to prevent UI blocking
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let localProducts = self?.dataManager.retrieveData() ?? []
                
                self?.viewModel.setLocalProducts(localProducts)
                
                DispatchQueue.main.async {
                    self?.loadingIndicator.stopAnimating()
                    
                    // Add loading animation
                    self?.listTableView.alpha = 0
                    UIView.animate(withDuration: 0.3) {
                        self?.listTableView.alpha = 1.0
                    }
                    
                    self?.listTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Actions
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
    
    @IBAction func segmentListGrid(_ sender: UISegmentedControl) {
        self.setUpListGrid(sender.selectedSegmentIndex == 0 ? "list" : "grid")
    }
    
    func setUpListGrid(_ type: String) {
        let duration = 0.3
        
        let isSwitchingToList = type == "list"
        let fromView = isSwitchingToList ? listCollectionView! : listTableView!
        let toView = isSwitchingToList ? listTableView! : listCollectionView!
        
        if isSwitchingToList {
            configureTableView()
        } else {
            configureCollectionView()
        }
        
        toView.transform = CGAffineTransform(translationX: isSwitchingToList ? -view.frame.width : view.frame.width, y: 0)
        toView.alpha = 0
        toView.isHidden = false
        
        UIView.animate(withDuration: duration, animations: {
            fromView.transform = CGAffineTransform(translationX: isSwitchingToList ? self.view.frame.width : -self.view.frame.width, y: 0)
            fromView.alpha = 0
            toView.transform = .identity
            toView.alpha = 1
        }, completion: { _ in
            fromView.isHidden = true
            fromView.transform = .identity
            toView.isHidden = false
        })
    }
    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
        let popoverVC = SortPopoverViewController(products: viewModel.products)
        popoverVC.delegate = self
        popoverVC.modalPresentationStyle = .popover
        
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = [.up, .down]
            popoverController.delegate = self
        }
        
        self.present(popoverVC, animated: true, completion: nil)
    }
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        
        let lowToHigh = UIAlertAction(title: "Price: Low to High", style: .default) { _ in
            print("Selected Low to High")
        }
        
        let highToLow = UIAlertAction(title: "Price: High to Low", style: .default) { _ in
            print("Selected High to Low")
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(lowToHigh)
        alertController.addAction(highToLow)
        alertController.addAction(cancel)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}

//MARK: - Table View Delegate & Data Source
extension ProductsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfProducts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductsListTableViewCell.identifier, for: indexPath) as? ProductsListTableViewCell else {
            return UITableViewCell()
        }
        
        let product = self.viewModel.product(at: indexPath.row)
        cell.setUpData(imgUrl: product.thumbnail ?? "",
                       title: product.title ?? "",
                       price: "$\(product.price ?? 0.0)", id: product.id ?? 0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Add haptic feedback on selection
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        guard let nav: ProductDetailsViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController else { return }
        nav.productDetails = self.viewModel.product(at: indexPath.row)
        self.navigationController?.pushViewController(nav, animated: true)
    }
}

//MARK: - Collection View Delegate & Data Source
extension ProductsListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfProducts
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.listCollectionView.dequeueReusableCell(withReuseIdentifier: ProductsGridCollectionViewCell.identifier, for: indexPath) as! ProductsGridCollectionViewCell
        let product = self.viewModel.product(at: indexPath.row)
        cell.setUpData(imgUrl: product.thumbnail ?? "",
                       title: product.title ?? "",
                       price: "$\(product.price ?? 0.0)", id: product.id ?? 0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width/2
        return CGSize(width: cellWidth, height: cellWidth*1.2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Add haptic feedback on selection
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        guard let nav: ProductDetailsViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController else { return }
        nav.productDetails = self.viewModel.product(at: indexPath.row)
        self.navigationController?.pushViewController(nav, animated: true)
    }
}

// MARK: - Popover presentation delegate
extension ProductsListViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension ProductsListViewController: SortPopoverDelegate {
    
    func didSelectCategory(_ category: String) {
        print("Selected category: \(category)")
    }
}
