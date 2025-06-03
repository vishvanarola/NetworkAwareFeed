//
//  ProductsListViewModel.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

class ProductsListViewModel {
    private let service: ProductServiceProtocol
    private(set) var products: [ProductsData] = []
    
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
                self?.onProductsFetched?()
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func product(at index: Int) -> ProductsData {
        return products[index]
    }
    
    var numberOfProducts: Int {
        return products.count
    }
    
    func setLocalProducts(_ products: [ProductsData]) {
        self.products = products
    }
}
