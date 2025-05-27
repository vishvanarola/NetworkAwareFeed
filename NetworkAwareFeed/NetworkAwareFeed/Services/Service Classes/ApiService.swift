//
//  ApiService.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import Foundation

// MARK: - API Service Protocol

protocol BeautyProductServiceProtocol {
    func fetchBeautyProducts(completion: @escaping (Result<[BeautyProducts], Error>) -> Void)
}

// MARK: - API Service

class BeautyProductService: BeautyProductServiceProtocol {
    func fetchBeautyProducts(completion: @escaping (Result<[BeautyProducts], Error>) -> Void) {
        let url = APIConstants.baseURL + APIConstants.beautyProductsEndpoint
        
        NetworkManager.shared.apiCall(url: url,
                                      method: ParamVariables.get,
                                      params: [:],
                                      headers: nil,
                                      success: { data in
            do {
                let decoded = try JSONDecoder().decode(BeautyProductModel.self, from: data)
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
