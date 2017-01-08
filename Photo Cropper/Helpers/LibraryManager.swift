//
//  LibraryManager.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 08.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit


protocol LibraryManagerDelegate: class {
    func fileSaved()
}

class LibraryManager {
    weak var delegate: LibraryManagerDelegate?
    func save(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(LibraryManager.saved), nil)
    }
    func save(videoAt url: URL) {
        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(LibraryManager.saved), nil)
    }
    @objc func saved() {
        delegate?.fileSaved()
    }
}
