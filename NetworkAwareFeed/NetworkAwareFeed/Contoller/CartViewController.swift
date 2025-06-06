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
    @IBOutlet weak var emptyCartView: UIView!
    @IBOutlet weak var ohhHoLabel: UILabel!
    @IBOutlet weak var cartEmptyLabel: UILabel!
    @IBOutlet weak var continueShoppingButton: UIButton!
    
    // MARK: - Properties
    private let cartDataManager = CartDataManager.shared
//    private var cartItems: [(product: ProductsData, quantity: Int)] = []
    private var cartItems: [CartProduct] = []
    
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
        continueShoppingButton.layer.cornerRadius = 12
        emptyCartView.backgroundColor = .systemBackground
        emptyCartView.layer.cornerRadius = 12
        emptyCartView.clipsToBounds = false
        emptyCartView.layer.shadowColor = UIColor.black.cgColor
        emptyCartView.layer.shadowOffset = CGSize(width: 0, height: 2)
        emptyCartView.layer.shadowOpacity = 0.1
        emptyCartView.layer.shadowRadius = 4
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
        emptyCartView.isHidden = !cartItems.isEmpty
        ohhHoLabel.isHidden = !cartItems.isEmpty
        cartEmptyLabel.isHidden = !cartItems.isEmpty
        checkoutButton.isHidden = cartItems.isEmpty
        
        let total = cartItems.reduce(0) { $0 + (($1.product?.price ?? 0) * Double($1.quantity)) }
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
        let total = cartItems.reduce(0) { $0 + (($1.product?.price ?? 0) * Double($1.quantity)) }
        let totalFormatted = String(format: "%.2f", total)
                
        AlertViewManager.showAlert(title: TextMessage.checkout, message: "\(TextMessage.totalAmount): $\(totalFormatted)\n\(TextMessage.proceedWithPayment)?", alertButtonTypes: [.Cancel, .Proceed], alertStyle: .alert) { alertType in
            if alertType == .Proceed {
                self.showOrderConfirmation()
            }
        }
    }
    
    @IBAction func continueShoppingButtonTapped(_ sender: UIButton) {
        if let viewControllers = navigationController?.viewControllers {
            for vc in viewControllers {
                if vc is ProductsListViewController {
                    navigationController?.popToViewController(vc, animated: true)
                    break
                }
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
        cell.configure(with: item)
        cell.delegate = self
        return cell
    }
}

// MARK: - CartItemCellDelegate
extension CartViewController: CartItemCellDelegate {
    func cartItemCell(_ cell: CartItemTableViewCell, didUpdateQuantity quantity: Int, caseUpdate: Int) {
        guard let indexPath = listTableView.indexPath(for: cell) else { return }
        let item = cartItems[indexPath.row]
        cartDataManager.updateQuantity(productId: Int(item.product?.id ?? 0), quantity: quantity) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.cartItems[indexPath.row].quantity = Int64(quantity)
                self.listTableView.reloadRows(at: [indexPath], with: .automatic)
                self.updateUI(caseUpdate)
            }
        }
    }
    
    func cartItemCellDidTapRemove(_ cell: CartItemTableViewCell) {
        guard let indexPath = listTableView.indexPath(for: cell) else { return }
        let item = cartItems[indexPath.row]
        cartDataManager.removeProductFromCart(productId: Int(item.product?.id ?? 0))
        cartItems.remove(at: indexPath.row)
        listTableView.deleteRows(at: [indexPath], with: .fade)
        updateUI()
    }
    
    func cartItemCellStockLimitReached(_ cell: CartItemTableViewCell, quantity: Int) {
        AlertViewManager.showAlert(title: TextMessage.stockLimitReached, message: "You can not add more than \(quantity) of this product.")
    }
}
