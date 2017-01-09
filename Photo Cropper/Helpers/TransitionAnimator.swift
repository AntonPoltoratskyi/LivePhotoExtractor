//
//  TransitionAnimator.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 09.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration    = 0.3
    var presenting  = true
    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let mainView = presenting ? toView : transitionContext.view(forKey: .from)!
        
        let initialFrame = presenting ? originFrame : mainView.frame
        let finalFrame = presenting ? mainView.frame : originFrame
        
        var scaleX: CGFloat = initialFrame.width / finalFrame.width
        scaleX = presenting ? scaleX : 1 / scaleX
        var scaleY: CGFloat = initialFrame.height / finalFrame.height
        scaleY = presenting ? scaleY : 1 / scaleY
        
        let scaling = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        if presenting {
            toView.transform = scaling
            toView.center = CGPoint(x: originFrame.midX, y: originFrame.midY)
            toView.clipsToBounds = true
        }
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: mainView)
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { 
                        mainView.transform = self.presenting ? CGAffineTransform.identity : scaling
                        mainView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}
extension FullScreenViewController: UIViewControllerTransitioningDelegate {}
extension MainViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let layer = currentLayer {
            let frame = contentView.convert(layer.frame, to: nil)
            let viewFrame = view.frame
            
            let widthMultiplier = frame.width / viewFrame.width
            let heightMultiplier = frame.height / viewFrame.height
            
            let maxMultiplier = max(widthMultiplier, heightMultiplier)
            let finalSize = CGSize(width: viewFrame.width * maxMultiplier,
                                   height: viewFrame.height * maxMultiplier)
            let origin = CGPoint(x: frame.origin.x - (finalSize.width - frame.width) / 2,
                                 y: frame.origin.y - (finalSize.height - frame.height) / 2)
            
            animator.originFrame = CGRect(origin: origin, size: finalSize)
        }
        animator.presenting = true
        return animator
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = false
        return animator
    }
}
