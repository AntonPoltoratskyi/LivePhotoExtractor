//
//  FullScreenViewController.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 09.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

class FullScreenViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = detailsImage
        }
    }
    var detailsImage: UIImage?
    
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
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
        
        view.gradiented([UIColor(red: 64 / 255, green: 57 / 255, blue: 130 / 255, alpha: 1.0),
                         .white], shouldBreak: true)
        
        [closeButton, shareButton].forEach {
            $0.image(colored: .white)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.updateMinZoomScale(for: self.scrollView.bounds.size)
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
        self.updateMinZoomScale(for: self.scrollView.bounds.size, animated: true)
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
    
    
    //MARK: - Image Zooming
    
    func updateMinZoomScale(for size: CGSize, animated: Bool = false) {
        
        let widthScale: CGFloat = size.width / self.imageView!.bounds.size.width
        let heightScale: CGFloat = size.height / self.imageView!.bounds.size.height
        
        let minScale: CGFloat = min(widthScale, heightScale)
        
        self.scrollView.minimumZoomScale = minScale
        self.scrollView.setZoomScale(minScale, animated: animated)
    }
    
    func updateConstraints(for size: CGSize) {
        
        let yOffset: CGFloat = max(0, (size.height - self.imageView!.frame.size.height) / 2)
        self.imageViewTopConstraint.constant = yOffset
        self.imageViewBottomConstraint.constant = yOffset
        
        let xOffset: CGFloat = max(0, (size.width - self.imageView!.frame.size.width) / 2)
        self.imageViewLeadingConstraint.constant = xOffset
        self.imageViewTrailingConstraint.constant = xOffset
        
        self.scrollView.layoutIfNeeded()
    }
    
}


//MARK: - UIScrollViewDelegate
extension FullScreenViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.updateConstraints(for: scrollView.bounds.size)
    }
}
