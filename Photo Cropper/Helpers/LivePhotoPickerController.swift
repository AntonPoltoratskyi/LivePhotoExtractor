//
//  LivePhotoPickerController.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 08.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit
import PhotosUI
import MobileCoreServices

protocol LivePhotoPickerControllerDelegate: class {
    func pickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    func pickerDidCancel(_ picker: UIImagePickerController)
}

class LivePhotoPickerController: NSObject {
    weak var delegate: LivePhotoPickerControllerDelegate?
    
    lazy var picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        let mediaTypes = [kUTTypeImage, kUTTypeLivePhoto]
        picker.mediaTypes = mediaTypes as [String]
        picker.delegate = self
        return picker
    }()
}
extension LivePhotoPickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        delegate?.pickerController(picker, didFinishPickingMediaWithInfo: info)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.pickerDidCancel(picker)
    }
}
