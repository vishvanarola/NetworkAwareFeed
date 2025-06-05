//
//  SortPopoverViewController.swift
//  NetworkAwareFeed
//
//  Created by apple on 05/06/25.
//

import UIKit

protocol SortPopoverDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

class SortPopoverViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var listTableView: UITableView!
    
    // MARK: - Properties
    private var categoryData = [String]()
    weak var delegate: SortPopoverDelegate?
    
    // MARK: - Initializer
    init(products: [ProductsData]) {
        let uniqueCategories = Set(products.compactMap { $0.category })
        var categories = Array(uniqueCategories).sorted()
        categories.insert("All", at: 0)  // Add "All" at the beginning
        self.categoryData = categories
        super.init(nibName: "SortPopoverViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        listTableView.layoutIfNeeded()
        let maxHeight: CGFloat = 400
        let calculatedHeight = listTableView.contentSize.height + 20
        preferredContentSize = CGSize(width: 250, height: min(calculatedHeight, maxHeight))
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Setup the view
        view.backgroundColor = .systemBackground
    }
    
    // MARK: - Setup Methods
    private func configureTableView() {
        // Table view styling
        self.listTableView.backgroundColor = .systemBackground
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        self.listTableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 0)
        
        // Cell registration
        self.listTableView.register(UINib(nibName: CategoriesTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: CategoriesTableViewCell.identifier)
    }
}

//MARK: - Table View Delegate & Data Source
extension SortPopoverViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesTableViewCell.identifier, for: indexPath) as? CategoriesTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(category: self.categoryData[indexPath.row].capitalized)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: {
            let selectedCategory = self.categoryData[indexPath.row]
            self.delegate?.didSelectCategory(selectedCategory)
        })
    }
}
