//
//  Network.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import UIKit
import Alamofire

// MARK: - Constants

struct APIConstants {
    static let baseURL = "https://dummyjson.com"
    static let beautyProductsEndpoint = "/products"
}

struct ParamVariables {
    static let get = "GET"
    static let post = "POST"
    static let put = "PUT"
    static let patch = "PATCH"
    static let delete = "DELETE"
}

// MARK: - Network Manager

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func apiCall(url: String,
                 method: String,
                 params: [String: AnyObject],
                 headers: HTTPHeaders?,
                 success: @escaping (Data) -> Void,
                 failure: @escaping (String) -> Void) {
        
        guard ReachabilityManager.shared.isNetworkAvailable else {
            AlertPresenter.shared.presentNoInternetAlert()
            return
        }
        
        let httpMethod = HTTPMethod(rawValue: method)
        let encoding: ParameterEncoding = (method == ParamVariables.get || method == ParamVariables.put) ? URLEncoding.default : JSONEncoding.default
        
        AF.request(url,
                   method: httpMethod,
                   parameters: params,
                   encoding: encoding,
                   headers: headers)
        .responseData { response in
            switch response.result {
            case .success(let data):
                if let statusCode = response.response?.statusCode, (200...299).contains(statusCode) {
                    success(data)
                } else {
                    failure("Server error with code: \(response.debugDescription)")
                }
            case .failure(let error):
                failure(error.localizedDescription)
            }
        }
    }
}

// MARK: - Alert Presenter

class AlertPresenter {
    static let shared = AlertPresenter()
    
    private init() {}
    
    func presentNoInternetAlert() {
        let alert = UIAlertController(title: TextMessage.alert, message: TextMessage.pleaseCheckInternet, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            
            var topController = rootVC
            while let presented = topController.presentedViewController {
                topController = presented
            }
            
            DispatchQueue.main.async {
                topController.present(alert, animated: true)
            }
        }
    }
}
