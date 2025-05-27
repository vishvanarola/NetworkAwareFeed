//
//  Network.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import UIKit
import Alamofire

enum ParamVariables {
    //Used in API Method Types
    static let get = "GET"
    static let post = "POST"
    static let put = "PUT"
    static let patch = "PATCH"
    static let delete = "DELETE"
}

class Network: UIViewController {
    var window: UIWindow?
    
    func apiCall(url: String, methodTypeString: String, params: [String:AnyObject], headers: HTTPHeaders?, success: @escaping (_ parsedJSON: Data) -> Void, failed: @escaping (_ errorMsg: String) -> Void) {
        
        let methodType = HTTPMethod(rawValue: methodTypeString)
        var encoding : ParameterEncoding?
        
        
        if (methodTypeString == ParamVariables.get) {
            encoding = URLEncoding.default as URLEncoding?
        } else if (methodTypeString == ParamVariables.put) {
            encoding = URLEncoding.default
        } else {
            encoding = JSONEncoding.default as JSONEncoding?
        }
        
        if ReachabilityManager.shared.isNetworkAvailable {
            AF.request(url,method: methodType, parameters: params,encoding: encoding!, headers: headers).responseData (completionHandler: { response in
                
                switch response.result {
                case .success(let res):
                    if let code = response.response?.statusCode {
                        switch code {
                        case 200...299:
                            success(res)
                        default:
                            failed(response.debugDescription)
                        }
                    }
                case .failure(let error):
                    failed(error.errorDescription ?? "")
                }
            })
        } else {
            presentAlert()
        }
    }
    
    func presentAlert() {
        activityIndicator.stopAnimating()
        
        let alertController = UIAlertController(title: TextMessage.alert, message: TextMessage.pleaseCheckInternet, preferredStyle: .alert)
        
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }),
           var rootViewController = window.rootViewController {
            
            if let navigationController = rootViewController as? UINavigationController {
                rootViewController = navigationController.viewControllers.first ?? navigationController
            }
            
            if let tabBarController = rootViewController as? UITabBarController {
                rootViewController = tabBarController.selectedViewController ?? tabBarController
            }
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
}
