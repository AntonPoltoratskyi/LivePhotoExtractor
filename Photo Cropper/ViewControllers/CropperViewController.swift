//
//  CropperViewController.swift
//  Photo Cropper
//
//  Created by Anton Poltoratskyi on 08.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit
import Photos
import AVKit
import AVFoundation

class CropperViewController: UIViewController {
    
    lazy var livePhotoPickerController: LivePhotoPickerController = {
        let picker = LivePhotoPickerController()
        picker.delegate = self
        return picker
    }()
    lazy var mediaManager: MediaResourceManager = {
        return MediaResourceManager()
    }()
    var livePhotoPlayer: PlayerBehaviour?
    var currentLayer: AVPlayerLayer?
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentSlider: CustomSlider!
    
    var galleryAccessGranted = false
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestGalleryPermission()
    }
    
    
    //MARK: - View
    
    func setupUI() {
        
    }
    func showVideo(_ url: URL) {
        if currentLayer != nil {
            currentLayer?.removeFromSuperlayer()
        }
        livePhotoPlayer = LivePhotoPlayer(url)
        guard let livePhotoPlayer = livePhotoPlayer else {
            return
        }
        let layer = livePhotoPlayer.layer()
        layer.frame = contentView.bounds
        contentView.layer.addSublayer(layer)
        currentLayer = layer
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
    
    @IBAction func didTapSelectButton(_ sender: Any) {
        
        if galleryAccessGranted {
            //hide button
            present(livePhotoPickerController.picker, animated: true) {
                //hide button
            }
        } else {
            showNotGrantedGalleryAccessAlert()
        }
    }
    
    @IBAction func actionDidTapShareButton(_ sender: Any) {
        guard let player = livePhotoPlayer else {
            //handle somehow
            return
        }

        player.captureImage { (image, error) in
            if let image = image {
                let activityController = SharingManager.activityController(with: image)
                self.present(activityController, animated: true, completion: nil)
            } else {
                print(error)
            }
        }
    }
    
    @IBAction func actionSliderValueChanged(_ sender: CustomSlider) {
        guard let livePhotoPlayer = livePhotoPlayer, let duration = livePhotoPlayer.duration else {
            return
        }
        let neededTime = Double(sender.progress) * duration
        do {
            try livePhotoPlayer.move(to: neededTime)
        } catch {
            print(error)
        }
    }
}


//MARK: - LivePhotoPickerControllerDelegate
extension CropperViewController: LivePhotoPickerControllerDelegate {
    
    func pickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        mediaManager.process(info) { [weak self] (url, error) in
            if let url = url {
                self?.showVideo(url)
            } else {
                //process error
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func pickerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        //show button
    }
}


//MARK: - Validation Output
extension CropperViewController {
    
    func showNotGrantedGalleryAccessAlert() {
        let alert = alertViewController(message: "Please, provide permissions to the app for processing live photo. Do you want to open Settings application?")
        
        let noAction = UIAlertAction(title: "NO", style: .default, handler: nil)
        let yesAction = UIAlertAction(title: "YES", style: .default) { action -> Void in
            
            let settingsURL = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.openURL(settingsURL)
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        present(alert, animated: true, completion: nil)
    }
}
