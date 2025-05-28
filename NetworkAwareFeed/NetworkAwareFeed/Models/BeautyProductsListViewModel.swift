//
//  BeautyProductsListViewModel.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

class BeautyProductsListViewModel {
    private let service: BeautyProductServiceProtocol
    private(set) var products: [BeautyProducts] = []
    
    var onProductsFetched: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(service: BeautyProductServiceProtocol = BeautyProductService()) {
        self.service = service
    }
    
    func fetchProducts() {
        service.fetchBeautyProducts { [weak self] result in
            switch result {
            case .success(let products):
                self?.products = products
                self?.onProductsFetched?()
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func product(at index: Int) -> BeautyProducts {
        return products[index]
    }
    
    var numberOfProducts: Int {
        return products.count
    }
    
    func setLocalProducts(_ products: [BeautyProducts]) {
        self.products = products
    }
}
