//
//  AppConstant.swift
//  NetworkAwareFeed
//
//  Created by apple on 27/05/25.
//

import UIKit
import NVActivityIndicatorView

// MARK: - Activity Indicator
let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), type: NVActivityIndicatorType.ballClipRotate, color: .black, padding: SCREEN_WIDTH/2.2)

// MARK: - SCREEN-SIZES
let SCREEN = UIScreen.main.bounds
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

let entityQuantroProduct = "QuantroProduct"

let yellowColor = UIColor.init(rgb: 0xFEBE00)
