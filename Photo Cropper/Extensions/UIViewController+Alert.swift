//
//  ViewController.swift
//  Photo Cropper
//
//  Created by Anton Poltoratskyi on 09.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func defaultAlertViewController(title: String = "Info", message: String) -> UIAlertController {
        
        let alert = self.alertViewController(title: title, message: message)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        return alert
    }
    
    func alertViewController(title: String = "Info", message: String) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
}
