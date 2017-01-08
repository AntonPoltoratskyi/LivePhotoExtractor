//
//  SharingManager.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 08.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

class SharingManager {
    static func activityController(with data: Any) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [data], applicationActivities: nil)
    }
}
