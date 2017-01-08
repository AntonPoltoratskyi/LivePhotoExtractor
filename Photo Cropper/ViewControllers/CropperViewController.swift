//
//  CropperViewController.swift
//  Photo Cropper
//
//  Created by Anton Poltoratskyi on 08.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit
import Photos

class CropperViewController: UIViewController, LivePhotoPickerControllerDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentSlider: CustomSlider!
    
    let pickerController = LivePhotoPickerController()
    
    var galleryAccessGranted = false
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerController.delegate = self
        
        setupUI()
        requestGalleryPermission()
    }
    
    
    //MARK: - View
    
    func setupUI() {
        
    }
    
    
    //MARK: - Permissions
    
    func requestGalleryPermission() {
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            self.galleryAccessGranted = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                self.galleryAccessGranted = newStatus == .authorized
            }
        default:
            break
        }
    }
    
    
    //MARK: - Actions
    
    @IBAction func actionDidTapSelectLivePhoto(_ sender: Any) {
        selectLivePhoto()
    }
    
    @IBAction func actionDidTapShareButton(_ sender: Any) {
        
    }
    
    @IBAction func actionSliderValueChanged(_ sender: CustomSlider) {
        
    }
    
    func selectLivePhoto() {
        if galleryAccessGranted {
            self.present(pickerController.picker, animated: true, completion: nil)
        } else {
            self.showNotGrantedGalleryAccessAlert()
        }
    }
}

//MARK: - LivePhotoPickerControllerDelegate
extension CropperViewController {
    func pickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
    }
}

//MARK: - Validation
extension CropperViewController {
    
    func showNotGrantedGalleryAccessAlert() {
        let alert = self.alertViewController(title: "Warning", message: "Gallery access not granted")
        self.present(alert, animated: true, completion: nil)
    }
}


//MARK: - Alert
extension UIViewController {
    
    func alertViewController(title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        return alert
    }
}
