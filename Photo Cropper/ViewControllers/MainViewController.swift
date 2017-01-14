//
//  MainViewController.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 09.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit
import Photos
import AVKit
import AVFoundation

class MainViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var contentView: CorneredView!
    
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentViewWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var selectPhotoTitle: UILabel!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderVerticalConstraint: NSLayoutConstraint!
    
    //MARK: - Helpers
    lazy var animator: TransitionAnimator = {
        return TransitionAnimator()
    }()
    
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
    var galleryAccessGranted = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
        hideNavigationButtons()
        closeButton(setHidden: true, false, completion: nil)
        slider(show: false, false, completion: nil)
        photoSelection(show: false, false, completion: nil)
        setUpNavBar()
        requestGalleryPermission()
        addGestureRecognizers()
        view.gradiented([UIColor(red: 64 / 255, green: 57 / 255, blue: 130 / 255, alpha: 1.0),
                              .white], shouldBreak: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentLayer == nil {
            changeUI(photoSelected: false, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let fullScreenVC = segue.destination as? FullScreenViewController {
            fullScreenVC.transitioningDelegate = self
            //get image and setup
            if let image = sender as? UIImage {
                fullScreenVC.setup(with: image)
            }
            self.animator.sourceViewController = fullScreenVC
        }
    }
    
    //MARK: - Methods

    func addGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        //temporary
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(imageTapped))
        contentView.addGestureRecognizer(pinchRecognizer)
        contentView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func initialUI() {
        selectPhotoTitle.text = Localization.selectMediaLabel
        applyColor()
    }
    func applyColor() {
        [photoButton, videoButton, closeButton].forEach {$0.image(colored: UIColor(red: 64 / 255, green: 57 / 255, blue: 130 / 255, alpha: 1.0))}
        
        let originImage = logoImageView.image
        let tintedImage = originImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        logoImageView.image = tintedImage
        logoImageView.tintColor = UIColor(red: 115 / 255, green: 111 / 255, blue: 148 / 255, alpha: 1.0)
    }
    
    func setUpNavBar() {
        let bar =  self.navigationController?.navigationBar
        
        bar?.setBackgroundImage(UIImage(), for: .default)
        bar?.shadowImage = UIImage()
        bar?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
    }
    func setupPlayer(_ url: URL) {
        livePhotoPlayer = LivePhotoPlayer(url)
    }
    func showVideo() {
        if currentLayer != nil {
            currentLayer?.removeFromSuperlayer()
        }
        guard let livePhotoPlayer = livePhotoPlayer else {
            return
        }
        let layer = livePhotoPlayer.layer()
        contentView.layer.addSublayer(layer)
        currentLayer = layer
    }
    
    func calculateFrameSize(_ estimatedSize: CGSize) -> CGSize {
        let aspecting = estimatedSize.width / estimatedSize.height
        let potentialWidth = view.bounds.width * 6 / 7
        let potentialHeight = potentialWidth / aspecting
        
        var finalWidth: CGFloat = potentialWidth
        var finalHeight: CGFloat = potentialHeight
        
        if potentialHeight > view.bounds.height * 4 / 7 {
            //should resize height
            finalHeight = view.bounds.height * 4 / 7
            finalWidth = potentialWidth * finalHeight / potentialHeight
        }
        
        return CGSize(width: finalWidth, height: finalHeight)
    }
    
    //MARK: - Animations
    
    func changeUI(photoSelected: Bool, completion: ((Bool) -> Void)?) {
        photoSelection(show: !photoSelected, true, completion: nil)
        closeButton(setHidden: !photoSelected, true, completion: { [weak self] (finished) in
            self?.navigationButtons(show: photoSelected, true, completion: nil)
            self?.slider(show: photoSelected, true, completion: { [weak self] (finished) in
                self?.slider.setValue(0, animated: true)
            })
            guard let wSelf = self else {
                return
            }
            var frameSize = CGSize(width: wSelf.view.bounds.width * 6 / 7,
                                   height: wSelf.view.bounds.height * 4 / 7)
            if photoSelected {
                if let emptyImage = wSelf.livePhotoPlayer?.captureImageSynchronously() {
                    frameSize = emptyImage.size
                }
            } else {
                self?.livePhotoPlayer = nil
                self?.currentLayer?.removeFromSuperlayer()
            }
            wSelf.resizeContentView(to: frameSize,
                                    true,
                                    completion: completion)
        })
    }
    
    func resizeContentView(to estimatedSize: CGSize, _ animated: Bool, completion: ((Bool) -> Void)?) {
        func updateLayouts() {
            contentView.setNeedsDisplay()
            view.layoutIfNeeded()
            currentLayer?.frame = contentView.bounds.insetBy(dx: contentView.frameWidth * 2,
                                                          dy: contentView.frameWidth * 2)
        }
        let finalSize = calculateFrameSize(estimatedSize)
        contentViewWidth.constant = finalSize.width
        contentViewHeight.constant = finalSize.height
        if animated {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseIn,
                           animations: {
                            updateLayouts()
            }, completion: completion)
        } else {
            updateLayouts()
            completion?(true)
        }
    }
    
    func navigationButtons(show: Bool, _ animated: Bool, completion: ((Bool) -> Void)?) {
        if !show {
            hideNavigationButtons()
            completion?(true)
            return
        }
        let alpha: CGFloat = 1.0
        if !animated {
            videoButton.alpha = alpha
            photoButton.alpha = alpha
            completion?(true)
            return
        }
        UIView.animateKeyframes(withDuration: 1.2,
                                delay: 0,
                                options: .beginFromCurrentState,
                                animations: { [weak self] in
                                    UIView.addKeyframe(withRelativeStartTime: 0,
                                                       relativeDuration: 0.4,
                                                       animations: { [weak self] in
                                                        self?.videoButton.alpha = alpha
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 0.4,
                                                       relativeDuration: 0.6,
                                                       animations: { [weak self] in
                                                        self?.photoButton.alpha = alpha
                                    })
        }, completion: completion)
    }
    
    func hideNavigationButtons() {
        UIView.animate(withDuration: 0.3) { 
            self.videoButton.alpha = 0.0
            self.photoButton.alpha = 0.0
        }
    }
    
    func closeButton(setHidden hidden: Bool, _ animated: Bool, completion: ((Bool) -> Void)?) {
        let constraintHeight: CGFloat = hidden ? 0 : 24
        if !animated {
            closeButton.isHidden = hidden
            closeButtonHeight.constant = constraintHeight
            completion?(true)
            return
        }
        closeButtonHeight.constant = constraintHeight
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseOut,
                       animations: {
                        self.view.layoutIfNeeded()
                        self.closeButton.isHidden = hidden
        }, completion: completion)
    }
    
    func slider(show: Bool, _ animated: Bool, completion: ((Bool) -> Void)?) {
        func slider(show: Bool) {
            let constant: CGFloat = show ? 0 : self.view.bounds.height / 2
            sliderVerticalConstraint.constant = constant
        }
        slider(show: show)
        if animated {
            UIView.animate(withDuration: 1.0,
                           delay: 0,
                           usingSpringWithDamping: 0.2,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseInOut,
                           animations: {
                            self.view.layoutIfNeeded()
            }, completion: completion)
        } else {
            completion?(true)
        }
    }
    
    func photoSelection(show: Bool, _ animated: Bool, completion: ((Bool) -> Void)?) {
        func photoSelection(show: Bool) {
            selectPhotoButton.isHidden = !show
            selectPhotoTitle.isHidden = !show
        }
        if animated {
            UIView.animate(withDuration: 0.6, animations: { 
                photoSelection(show: show)
            }, completion: completion)
        } else {
            photoSelection(show: show)
            completion?(true)
        }
    }
    
    //MARK: - Actions
    
    func imageTapped() {
        guard let player = livePhotoPlayer else { return }
        guard currentLayer != nil else {
            return
        }
        if let image = player.captureImageSynchronously() {
            let watermarkedImage = image.addingWatermark(text: Constants.watermarkText,
                                                         font: Constants.watermarkFont,
                                                         color: Constants.watermarkColor)
            self.performSegue(withIdentifier: "Details", sender: watermarkedImage)
        }
    }
    
    @IBAction func videoButtonTouched(_ sender: Any) {
        guard let player = livePhotoPlayer else {
            //handle somehow
            return
        }
        let activityController = SharingManager.activityController(with: player.videoUrl)
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func photoButtonTouched(_ sender: Any) {
        guard let player = livePhotoPlayer else {
            //handle somehow
            return
        }
        player.captureImage { [weak self] (image, error) in
            if let image = image {
                let watermarkedImage = image.addingWatermark(text: Constants.watermarkText,
                                                             font: Constants.watermarkFont,
                                                             color: Constants.watermarkColor)
                
                let activityController = SharingManager.activityController(with: watermarkedImage)
                self?.present(activityController, animated: true, completion: nil)
            } else {
                debugPrint(error ?? "Error")
            }
        }
    }
    
    @IBAction func closeButtonTouched(_ sender: Any) {
        if let urlToDelete = livePhotoPlayer?.videoUrl {
            mediaManager.deleteMedia(urlToDelete)
        }
        changeUI(photoSelected: false, completion: nil)
    }
    
    @IBAction func selectPhotoButtonTouched(_ sender: Any) {
        if galleryAccessGranted {
            present(livePhotoPickerController.picker, animated: true, completion: nil)
        } else {
            showNotGrantedGalleryAccessAlert()
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        guard let livePhotoPlayer = livePhotoPlayer, let duration = livePhotoPlayer.duration else {
            return
        }
        let multiplier = sender.value == 1.0 ? 0.999 : sender.value
        let neededTime = Double(multiplier) * duration
        do {
            try livePhotoPlayer.move(to: neededTime)
        } catch {
            debugPrint(error)
        }
    }
}
//MARK: - LivePhotoPickerControllerDelegate
extension MainViewController: LivePhotoPickerControllerDelegate {
    func pickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            //show loader
            self?.mediaManager.process(info) { [weak self] (url, error) in
                DispatchQueue.main.async {
                    if let url = url {
                        self?.setupPlayer(url)
                        self?.showVideo()
                        self?.changeUI(photoSelected: true, completion: nil)
                    } else {
                        self?.changeUI(photoSelected: false, completion: nil)
                        guard let wSelf = self else {
                            return
                        }
                        let alert = wSelf.defaultAlertViewController(title: Localization.oops,
                                                                     message: Localization.nonLivePhotoAlert)
                        wSelf.present(alert, animated: true, completion: nil)
                    }
                    //hide loader
                }
            }
        }
    }
    func pickerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            self?.changeUI(photoSelected: false, completion: nil)
        }
    }
}


//MARK: - Validation Output
extension MainViewController {
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

extension UIButton {
    func image(colored color: UIColor) {
        let originImage = image(for: .normal)
        let tintedImage = originImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        setImage(tintedImage, for: .normal)
        tintColor = color
    }
}
