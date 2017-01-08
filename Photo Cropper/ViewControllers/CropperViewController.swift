//
//  CropperViewController.swift
//  Photo Cropper
//
//  Created by Anton Poltoratskyi on 08.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentSlider: CustomSlider!
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: - View
    
    func setupUI() {
        
    }
    func showVideo(_ url: URL) {
        livePhotoPlayer = LivePhotoPlayer(url)
        guard let livePhotoPlayer = livePhotoPlayer else {
            return
        }
        let layer = livePhotoPlayer.layer()
        layer.frame = contentView.bounds
        contentView.layer.addSublayer(layer)
    }
    
    //MARK: - Actions
    
    @IBAction func didTapSelectButton(_ sender: Any) {
        //hide button 
        present(livePhotoPickerController.picker, animated: true) {
            //hide button
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
            print(neededTime)
        } catch {
            print(error)
        }
    }
    
}
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
