import UIKit

class CartViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var emptyCartLabel: UILabel!
    
    // MARK: - Properties
    private let cartManager = CartManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listTableView.reloadData()
        updateUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Shopping Cart"
        
        // Setup checkout button appearance
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
        emptyCartLabel.isHidden = !cartManager.items.isEmpty
        checkoutButton.isHidden = cartManager.items.isEmpty
        
        let total = String(format: "%.2f", cartManager.totalPrice)
        let newTitle = "Proceed to Checkout ($\(total))"
                
        switch cases {
        case 0:
            UIView.transition(with: checkoutButton, duration: 0.5, options: .transitionFlipFromBottom, animations: {
                self.checkoutButton.setTitle(newTitle, for: .normal)
            })
        case 1:
            UIView.transition(with: checkoutButton, duration: 0.5, options: .transitionFlipFromTop, animations: {
                self.checkoutButton.setTitle(newTitle, for: .normal)
            })
        default:
            UIView.transition(with: checkoutButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.checkoutButton.setTitle(newTitle, for: .normal)
            })
        }
    }
    
    // MARK: - Actions
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkoutButtonTapped(_ sender: UIButton) {
        // Show checkout confirmation
        let alert = UIAlertController(
            title: "Checkout",
            message: "Total amount: $\(String(format: "%.2f", cartManager.totalPrice))\nProceed with payment?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Proceed", style: .default) { [weak self] _ in
            // Here you would typically integrate with a payment gateway
            self?.showOrderConfirmation()
        })
        
        present(alert, animated: true)
    }
    
    private func showOrderConfirmation() {
        let alert = UIAlertController(
            title: "Order Confirmed!",
            message: "Thank you for your purchase.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.cartManager.clearCart()
            self?.listTableView.reloadData()
            self?.updateUI()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartManager.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartItemTableViewCell.identifier, for: indexPath) as! CartItemTableViewCell
        let item = cartManager.items[indexPath.row]
        cell.configure(with: item)
        cell.delegate = self
        return cell
    }
}

// MARK: - CartItemCellDelegate
extension CartViewController: CartItemCellDelegate {
    func cartItemCell(_ cell: CartItemTableViewCell, didUpdateQuantity quantity: Int, caseUpdate: Int) {
        guard let indexPath = listTableView.indexPath(for: cell) else { return }
        let item = cartManager.items[indexPath.row]
        cartManager.updateQuantity(productId: item.product.id ?? 0, quantity: quantity)
        updateUI(caseUpdate)
    }
    
    func cartItemCellDidTapRemove(_ cell: CartItemTableViewCell) {
        guard let indexPath = listTableView.indexPath(for: cell) else { return }
        let item = cartManager.items[indexPath.row]
        cartManager.removeFromCart(productId: item.product.id ?? 0)
        listTableView.deleteRows(at: [indexPath], with: .fade)
        updateUI()
    }
}
