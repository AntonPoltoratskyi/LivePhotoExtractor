//
//  UIViewExtensions.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 09.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func gradiented(_ colors: [UIColor], shouldBreak: Bool) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map {$0.cgColor}
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        if shouldBreak {
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.25)
        }
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
