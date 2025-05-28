//
//  BeautyProductsListViewController.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import UIKit

class BeautyProductsListViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var listTableView: UITableView!
    
    // MARK: - Properties
    private let viewModel = BeautyProductsListViewModel()
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.initializeProductData()
    }
    
    // MARK: - Setup Methods
    private func configureTableView() {
        self.listTableView.backgroundColor = .clear
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        self.listTableView.separatorStyle = .none
        self.listTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        self.listTableView.register(UINib(nibName: BeautyProductTableViewCell.identifier, bundle: nil),
                                    forCellReuseIdentifier: BeautyProductTableViewCell.identifier)
    }
    
    private func bindViewModel() {
        self.viewModel.onProductsFetched = { [weak self] in
            self?.listTableView.reloadData()
            DispatchQueue.main.async {
                if BeautyProductDataManager().retrieveData().isEmpty {
                    BeautyProductDataManager().createData(self?.viewModel.products ?? [BeautyProducts]())
                } else {
                    BeautyProductDataManager().updateData(self?.viewModel.products ?? [BeautyProducts]())
                }
            }
        }
        
        self.viewModel.onError = { error in
            print("❌ Error: \(error.localizedDescription)")
        }
    }
    
    private func initializeProductData() {
        if ReachabilityManager.shared.isNetworkAvailable {
            self.bindViewModel()
            self.viewModel.fetchProducts()
        } else {
            self.viewModel.setLocalProducts(BeautyProductDataManager().retrieveData())
            DispatchQueue.main.async {
                self.listTableView.reloadData()
            }
        }
    }
}

//MARK: - Table View Delegate & Data Source
extension BeautyProductsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfProducts
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BeautyProductTableViewCell.identifier, for: indexPath) as? BeautyProductTableViewCell else {
            return UITableViewCell()
        }
        
        let product = self.viewModel.product(at: indexPath.row)
        cell.setUpData(imgUrl: product.thumbnail ?? "",
                       title: product.title ?? "",
                       price: "$\(product.price ?? 0.0)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nav: ProductDetailsViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController else { return }
        nav.beautyProductDetails = self.viewModel.product(at: indexPath.row)
        self.navigationController?.pushViewController(nav, animated: true)
    }
}
