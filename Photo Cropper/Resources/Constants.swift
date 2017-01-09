//
//  Constants.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 09.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

class AppBundle {
    static var bundle: Bundle = {
        return Bundle(for: AppBundle.self)
    }()
}

struct Constants {
    static let watermarkText = "#Snaplive"
    static let watermarkFont: UIFont = {
        return UIFont.boldSystemFont(ofSize: 60.0)
    }()
    static let watermarkColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)
}
struct Localization {
    static let selectMediaLabel = "SelectMedia".localized()
    static let oops = "oops".localized().capitalized
    static let nonLivePhotoAlert = "SelectLivePhoto".localized()
}
extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: AppBundle.bundle, value: "", comment: "")
    }
}
