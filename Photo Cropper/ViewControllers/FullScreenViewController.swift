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
    
    var isTopBarVisible: Bool {
        return blurViewTopConstraint.constant == 0
    }
    
    func setup(_ image: UIImage) {
        self.detailsImage = image
    }
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.gradiented([.white, UIColor(red: 115 / 255, green: 111 / 255, blue: 148 / 255, alpha: 1.0), .white])
        [closeButton, shareButton].forEach {
            $0.image(colored: .white)
        }
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
}
