//
//  ApiService.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import Foundation

class ApiService {
    
    func beautyProductListApiCall(success : @escaping (BeautyProductModel) -> Void, failure :@escaping (String) -> Void) {
                
        Network().apiCall(url: "https://dummyjson.com/products", methodTypeString: ParamVariables.get, params: [:], headers: [:], success: {response in
            do {
                let jsonDecoder = JSONDecoder()
                let responseModel = try jsonDecoder.decode(BeautyProductModel.self, from: response)
                success(responseModel)

            } catch let error {
                print(error)
                failure(TextMessage.somethingIsWrong)
            }
            
        }, failed: {error in
            failure(error)
        })
    }
}
