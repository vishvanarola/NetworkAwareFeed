//
//  AlertViewManager.swift
//  NetworkAwareFeed
//
//  Created by apple on 02/06/25.
//

import UIKit

enum AlertButtonType: String {
    case Photos = "PHOTOS"
    case Camera = "CAMERA"
    case Yes = "Yes"
    case No = "No"
    case Cancel = "Cancel"
    case Okay = "OK"
    case UploadMedia = "Upload Media"
    case CreateNewFolder = "Create new folder"
    case updateApp = "Update App"
    case later = "Later"
    case exit = "Exit"
    case yesLogOut = "Yes, log out"
    case Edit = "Edit"
    case Delete = "Delete"
    case GoToSetting = "Go to Settings"
    case RemoveAds = "Remove Ads"
    case Proceed = "Proceed"
}

class AlertViewManager: NSObject {
    
    /// This function show alert on current screen with dynamic functions
    static func showAlert(title: String? = nil, message: String, alertButtonTypes: [AlertButtonType]? = [.Okay],   alertStyle: UIAlertController.Style? = nil, completion: ((AlertButtonType) -> () )? = nil ) {
        
        let titleFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold),
                         NSAttributedString.Key.foregroundColor: UIColor.black]
        let titleAttrString = NSMutableAttributedString(string: title ?? "", attributes: titleFont)
        let messageFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular),
                           NSAttributedString.Key.foregroundColor: UIColor.black]
        let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont)
        
        let style: UIAlertController.Style = alertStyle ?? .alert
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: style)
        
        alertController.setValue(titleAttrString, forKey: "attributedTitle")
        alertController.setValue(messageAttrString, forKey: "attributedMessage")
        alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.white
        
        for actionTitle in alertButtonTypes! {
            
            if actionTitle == .Cancel {
                alertController.addAction(UIAlertAction(title: actionTitle.rawValue, style: .cancel, handler: { (alert: UIAlertAction!) in
                    completion?(AlertButtonType(rawValue: alert.title!)!)
                }))
            } else {
                alertController.addAction(UIAlertAction(title: actionTitle.rawValue, style: .default, handler: { (alert: UIAlertAction!) in
                    completion?(AlertButtonType(rawValue: alert.title!)!)
                }))
            }
        }
//        alertController.view.tintColor = UIColor.black//UIColor(named: "AppRedColor(#FF2828)")
        
        DispatchQueue.main.async {
            let controller = AppManager.shared.getPresentedViewController()
            controller?.present(alertController, animated: true, completion: nil)
        }
    }
}

class AppManager: NSObject {
    
    static let shared = AppManager()
    
    /// This function will get presented ViewController
    func getPresentedViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared
            .connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              var topController = window.rootViewController else {
            return nil
        }
        
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
    }
}
