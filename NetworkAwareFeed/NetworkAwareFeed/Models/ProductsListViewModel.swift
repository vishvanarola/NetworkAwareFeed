//
//  ProductsListViewModel.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

class ProductsListViewModel {
    private let service: ProductServiceProtocol
    private(set) var products: [ProductsData] = []
    private(set) var filteredProducts: [ProductsData] = []
    private var selectedCategory: String?
    private var currentSortOption: SortOption = .none
    
    enum SortOption {
        case none
        case priceLowToHigh
        case priceHighToLow
        case nameAToZ
        case nameZToA
    }
    
    var onProductsFetched: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(service: ProductServiceProtocol = ProductService()) {
        self.service = service
    }
    
    func fetchProducts() {
        service.fetchQuantroProducts { [weak self] result in
            switch result {
            case .success(let products):
                self?.products = products
                self?.applyFiltersAndSort()
                self?.onProductsFetched?()
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func product(at index: Int) -> ProductsData {
        return filteredProducts[index]
    }
    
    var numberOfProducts: Int {
        return filteredProducts.count
    }
    
    func setLocalProducts(_ products: [ProductsData]) {
        self.products = products
        applyFiltersAndSort()
    }
    
    // MARK: - Sorting and Filtering
    
    func filterByCategory(_ category: String?) {
        selectedCategory = category
        applyFiltersAndSort()
    }
    
    func sort(by option: SortOption) {
        currentSortOption = option
        applyFiltersAndSort()
    }
    
    private func applyFiltersAndSort() {
        filteredProducts = products.filter { product in
            guard let selectedCategory = selectedCategory, selectedCategory != "All" else {
                return true
            }
            return product.category == selectedCategory
        }
        
        switch currentSortOption {
        case .none:
            break
        case .priceLowToHigh:
            filteredProducts.sort { (product1, product2) in
                return (product1.price ?? 0) < (product2.price ?? 0)
            }
        case .priceHighToLow:
            filteredProducts.sort { (product1, product2) in
                return (product1.price ?? 0) > (product2.price ?? 0)
            }
        case .nameAToZ:
            filteredProducts.sort { (product1, product2) in
                return (product1.title ?? "") < (product2.title ?? "")
            }
        case .nameZToA:
            filteredProducts.sort { (product1, product2) in
                return (product1.title ?? "") > (product2.title ?? "")
            }
        }
    }
}
