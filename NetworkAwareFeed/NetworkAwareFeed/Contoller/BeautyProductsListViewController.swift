//
//  BeautyProductsListViewController.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import UIKit

class BeautyProductsListViewController: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var listTableView: UITableView!
    
    // MARK: - Properties
    private let viewModel = BeautyProductsListViewModel()
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.bindViewModel()
        self.viewModel.fetchProducts()
    }
    
    // MARK: - Setup Methods
    private func configureTableView() {
        self.listTableView.backgroundColor = .clear
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        self.listTableView.register(UINib(nibName: BeautyProductTableViewCell.identifier, bundle: nil),
                               forCellReuseIdentifier: BeautyProductTableViewCell.identifier)
    }
    
    private func bindViewModel() {
        self.viewModel.onProductsFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.listTableView.reloadData()
            }
        }
        
        self.viewModel.onError = { error in
            print("❌ Error: \(error.localizedDescription)")
        }
    }
}

//MARK: - Table View Delegate & Data Source
extension BeautyProductsListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfProducts
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BeautyProductTableViewCell.identifier, for: indexPath) as? BeautyProductTableViewCell else {
            return UITableViewCell()
        }

        let product = viewModel.product(at: indexPath.row)
        cell.setUpData(img: product.thumbnail ?? "",
                       title: product.title ?? "",
                       desc: product.description ?? "")

        return cell
    }
}
