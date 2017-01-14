//
//  TransitionAnimator.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 09.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

class TransitionAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    
    let animationDuration    = 0.3
    var presenting  = true
    var originFrame = CGRect.zero
    
    var enterPanGestureRecognizer: UIPanGestureRecognizer!
    var sourceViewController: UIViewController! {
        didSet {
            enterPanGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                               action: #selector(handlePanGesture(pan:)))
            sourceViewController.view.addGestureRecognizer(enterPanGestureRecognizer)
        }
    }
    fileprivate var isInteractive = false
    
    
    //MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
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
        
        mainView.alpha = presenting ? 0 : 1
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        mainView.alpha = self.presenting ? 1 : 0
                        mainView.transform = self.presenting ? CGAffineTransform.identity : scaling
                        mainView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
    
    
    //MARK: - Pan Gesture
    
    func handlePanGesture(pan: UIPanGestureRecognizer) {
        
        let translation = pan.translation(in: pan.view)
        
        let percentageComplete: CGFloat = abs(translation.y / pan.view!.bounds.height)
        
        switch pan.state {
        case .began:
            self.isInteractive = true
            self.sourceViewController.dismiss(animated: true, completion: nil)
        case .changed:
            self.sourceViewController.view.alpha = 1 - percentageComplete
            self.update(percentageComplete)
        default:
            self.isInteractive = false
            if percentageComplete > 0.5 {
                self.finish()
            } else {
                self.sourceViewController.view.alpha = 1
                self.update(0.0)
                self.cancel()
            }
        }
    }
}


//MARK: - UIViewControllerTransitioningDelegate

extension MainViewController: UIViewControllerTransitioningDelegate {
    
    //MARK: Animated transitioning
    
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
            
            self.animator.originFrame = CGRect(origin: origin, size: finalSize)
        }
        self.animator.presenting = true
        return self.animator
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator.presenting = false
        return self.animator
    }
    
    //MARK: Interactive transitioning
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.animator.isInteractive ? self.animator : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.animator.isInteractive ? self.animator : nil
    }
}
