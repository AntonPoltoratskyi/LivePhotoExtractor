//
//  Constants.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 09.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

class AppBundle {
    static var bundle: Bundle = {
        return Bundle(for: AppBundle.self)
    }()
}

struct Constants {
    
}
struct Localization {
    static let selectMediaLabel = "SelectMedia".localized()
}
extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: AppBundle.bundle, value: "", comment: "")
    }
}
