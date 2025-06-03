//
//  Color+Extension.swift
//  NetworkAwareFeed
//
//  Created by apple on 02/06/25.
//

import UIKit

extension UIColor {

    // Convert Color Values UInt to RGB
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
