//
//  ApiService.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import Foundation

// MARK: - API Service Protocol

protocol ProductServiceProtocol {
    func fetchQuantroProducts(completion: @escaping (Result<[ProductsData], Error>) -> Void)
}

// MARK: - API Service

class ProductService: ProductServiceProtocol {
    func fetchQuantroProducts(completion: @escaping (Result<[ProductsData], Error>) -> Void) {
        let url = APIConstants.baseURL + APIConstants.quantroProductsEndpoint
        
        NetworkManager.shared.apiCall(url: url,
                                      method: ParamVariables.get,
                                      params: [:],
                                      headers: nil,
                                      success: { data in
            do {
                let decoded = try JSONDecoder().decode(ProductModel.self, from: data)
                completion(.success(decoded.products ?? []))
            } catch {
                completion(.failure(error))
            }
        },
                                      failure: { errorString in
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorString])))
        })
    }
}
