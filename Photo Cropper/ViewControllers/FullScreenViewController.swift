//
//  FullScreenViewController.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 09.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

class FullScreenViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = detailsImage
        }
    }
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    var detailsImage: UIImage?
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var blurViewTopConstraint: NSLayoutConstraint!
    
    //MARK: - Gestures
    @IBOutlet var pinch: UIPinchGestureRecognizer!
    @IBOutlet var pan: UIPanGestureRecognizer!
    
    
    var isTopBarVisible: Bool {
        return blurViewTopConstraint.constant == 0
    }
    
    func setup(_ image: UIImage) {
        self.detailsImage = image
    }
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.gradiented([UIColor(red: 115 / 255, green: 111 / 255, blue: 148 / 255, alpha: 0.7),
                         .white,
                         UIColor(red: 115 / 255, green: 111 / 255, blue: 148 / 255, alpha: 0.7)],
                        shouldBreak: false)
        [closeButton, shareButton].forEach {
            $0.image(colored: .white)
        }
        pinch.delegate = self
    }
    
    
    //MARK: - View
    
    func hideTopView() {
        self.blurViewTopConstraint.constant = -self.blurView.frame.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showTopView() {
        self.blurViewTopConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    //MARK: - Actions
    
    @IBAction func actionDidTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionDidTapShareButton(_ sender: Any) {
        guard let image = detailsImage else {
            return
        }
        let activityController = SharingManager.activityController(with: image)
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func actionDidTapImageView(_ sender: Any) {
        isTopBarVisible ? hideTopView() : showTopView()
    }
    //MARK: - Gesture controlling
    var desiredLocation: CGPoint?
    var rememberedTransformation: CGAffineTransform?
    var rememberedScale: CGFloat = 1.0
    
    @IBAction func pinchAction(_ sender: UIPinchGestureRecognizer) {
        switch pinch.state {
        case .began:
            hideTopView()
            rememberedTransformation = imageView.transform
            desiredLocation = pinch.location(in: imageView)
            break
        case .changed:
            guard let transform = rememberedTransformation else {
                return
            }
            rememberedScale = pinch.scale
            imageView.transform = transform.concatenating(summaryTransormation())
            break
        case .cancelled, .failed, .ended:
            desiredLocation = nil
            if shouldReturnToIdentity() {
                rememberedScale = 1.0
                UIView.animate(withDuration: 0.3) {
                    self.imageView.transform = .identity
                }
            } else {
                if shouldReturnToCenter() {
                    UIView.animate(withDuration: 0.3) {
                        self.imageView.transform = self.autoTransformation()
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    @IBAction func panAction(_ sender: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            hideTopView()
            rememberedTransformation = imageView.transform
            break
        case .changed:
            guard let transform = rememberedTransformation else {
                return
            }
            imageView.transform = transform.concatenating(summaryTransormation())
            break
        case .cancelled, .failed, .ended:
            if shouldReturnToIdentity() {
                UIView.animate(withDuration: 0.3) {
                    self.imageView.transform = .identity
                }
            } else {
                if shouldReturnToCenter() {
                    UIView.animate(withDuration: 0.3) {
                        self.imageView.transform = self.autoTransformation()
                    }
                }
            }
            break
        default:
            break
        }
    }
    func shouldReturnToIdentity() -> Bool {
        if pinch.scale < 1.0 {
            return true
        }
        return false
    }
    func shouldReturnToCenter() -> Bool {
        let translation = pan.translation(in: imageView)
        if abs(translation.x) > imageView.frame.width / 3 || abs(translation.y) > imageView.frame.height / 3 {
            return true
        }
        return false
    }
    
    func autoTransformation() -> CGAffineTransform {
        let transformation: CGAffineTransform = .identity
        var scaleFactor: CGFloat = 1.0
        if pinch.scale > 3.5 {
            scaleFactor = 3.5
        }
        if pinch.scale < 1 {
            scaleFactor = 1
        }
        let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        
        return transformation.concatenating(scale)
    }
    
    func summaryTransormation() -> CGAffineTransform {
        let recognizers: [UIGestureRecognizer] = [pinch, pan]
        var basicTransformation = CGAffineTransform.identity
        recognizers.map { (recognizer) -> CGAffineTransform in
            return transformation(for: recognizer)
            }.forEach { (transform) in
                basicTransformation = basicTransformation.concatenating(transform)
        }
        return basicTransformation
    }
    func transformation(for recognizer: UIGestureRecognizer) -> CGAffineTransform {
        if let pinch = recognizer as? UIPinchGestureRecognizer {
            return CGAffineTransform(scaleX: pinch.scale, y: pinch.scale)
        }
        if let rotate = recognizer as? UIRotationGestureRecognizer {
            return CGAffineTransform(rotationAngle: rotate.rotation)
        }
        if let pan = recognizer as? UIPanGestureRecognizer {
            let translation = pan.translation(in: imageView)
            return CGAffineTransform(translationX: translation.x * rememberedScale,
                                     y: translation.y * rememberedScale)
        }
        return CGAffineTransform.identity
    }
}

extension FullScreenViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
