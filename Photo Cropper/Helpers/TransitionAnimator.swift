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
    let duration    = 1.0
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
        scaleX = !presenting ? scaleX : 1 / scaleX
        var scaleY: CGFloat = initialFrame.height / finalFrame.height
        scaleY = !presenting ? scaleY : 1 / scaleY
        
        let scaling = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        if presenting {
            mainView.transform = scaling
            mainView.center = CGPoint(x: originFrame.midX, y: originFrame.midY)
            mainView.clipsToBounds = true
        }
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: mainView)
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.3,
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
    func animationControllerForPresentedController(
        presented: UIViewController,
        presentingController presenting: UIViewController,
        sourceController source: UIViewController) ->
        UIViewControllerAnimatedTransitioning? {
            if let layer = currentLayer {
                animator.originFrame = layer.frame
            }
            animator.presenting = true
            return animator
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = false
        return animator
    }
}
