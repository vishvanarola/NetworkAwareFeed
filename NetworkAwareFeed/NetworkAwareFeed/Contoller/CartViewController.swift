//
//  CartViewController.swift
//  NetworkAwareFeed
//
//  Created by apple on 29/05/25.
//

import UIKit

class CartViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var emptyCartLabel: UILabel!
    
    // MARK: - Properties
    private let cartDataManager = CartDataManager()
    private var cartItems: [(product: ProductsData, quantity: Int)] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCartItems()
    }
    
    // MARK: - Load Cart Items
    private func loadCartItems() {
        cartItems = cartDataManager.getCartItems()
        listTableView.reloadData()
        updateUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        checkoutButton.layer.cornerRadius = 12
        updateUI()
    }
    
    private func setupTableView() {
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.register(UINib(nibName: CartItemTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: CartItemTableViewCell.identifier)
        listTableView.separatorStyle = .none
        listTableView.backgroundColor = .systemBackground
    }
    
    private func updateUI(_ cases: Int = 2) {
        emptyCartLabel.isHidden = !cartItems.isEmpty
        checkoutButton.isHidden = cartItems.isEmpty
        
        let total = cartItems.reduce(0) { $0 + (($1.product.price ?? 0) * Double($1.quantity)) }
        let totalFormatted = String(format: "%.2f", total)
        let newTitle = "\(TextMessage.proceedToCheckout) ($\(totalFormatted))"
        
        let animationOption: UIView.AnimationOptions = {
            switch cases {
            case 0: return .transitionFlipFromBottom
            case 1: return .transitionFlipFromTop
            default: return .transitionCrossDissolve
            }
        }()
        
        UIView.transition(with: checkoutButton, duration: 0.5, options: animationOption, animations: {
            self.checkoutButton.setTitle(newTitle, for: .normal)
        })
    }
    
    // MARK: - Actions
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkoutButtonTapped(_ sender: UIButton) {
        let total = cartItems.reduce(0) { $0 + (($1.product.price ?? 0) * Double($1.quantity)) }
        let totalFormatted = String(format: "%.2f", total)
                
        AlertViewManager.showAlert(title: TextMessage.checkout, message: "\(TextMessage.totalAmount): $\(totalFormatted)\n\(TextMessage.proceedWithPayment)?", alertButtonTypes: [.Cancel, .Proceed], alertStyle: .alert) { alertType in
            if alertType == .Proceed {
                self.showOrderConfirmation()
            }
        }
    }
    
    private func showOrderConfirmation() {
        AlertViewManager.showAlert(title: TextMessage.orderConfirmed, message: TextMessage.thankYouForYourPurchase, alertButtonTypes: [.Okay], alertStyle: .alert) { alertType in
            self.cartDataManager.clearCart()
            self.loadCartItems()
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartItemTableViewCell.identifier, for: indexPath) as! CartItemTableViewCell
        let item = cartItems[indexPath.row]
        cell.configure(with: item.product, quantity: item.quantity)
        cell.delegate = self
        return cell
    }
}

// MARK: - CartItemCellDelegate
extension CartViewController: CartItemCellDelegate {
    func cartItemCell(_ cell: CartItemTableViewCell, didUpdateQuantity quantity: Int, caseUpdate: Int) {
        guard let indexPath = listTableView.indexPath(for: cell) else { return }
        let item = cartItems[indexPath.row]

        cartDataManager.updateQuantity(productId: item.product.id ?? 0, quantity: quantity) { [weak self] in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.cartItems = self.cartDataManager.getCartItems()
                self.listTableView.reloadRows(at: [indexPath], with: .automatic)
                self.updateUI(caseUpdate)
            }
        }
    }
    
    func cartItemCellDidTapRemove(_ cell: CartItemTableViewCell) {
        guard let indexPath = listTableView.indexPath(for: cell) else { return }
        let item = cartItems[indexPath.row]
        cartDataManager.removeProductFromCart(productId: item.product.id ?? 0)
        cartItems.remove(at: indexPath.row)
        listTableView.deleteRows(at: [indexPath], with: .fade)
        updateUI()
    }
    
    func cartItemCellStockLimitReached(_ cell: CartItemTableViewCell, quantity: Int) {
        AlertViewManager.showAlert(title: TextMessage.stockLimitReached, message: "You can not add more than \(quantity) of this product.")
    }
}
