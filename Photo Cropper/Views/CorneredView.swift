//
//  CorneredView.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 09.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

@IBDesignable
class CorneredView: UIView {
    
    @IBInspectable var frameColor: UIColor = .green {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var frameWidth: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var frameAspect: CGFloat = 0.1 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var showFrame: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        if !showFrame {
            return
        }
        if frameAspect < 0 || frameAspect > 1 {
            frameAspect = 0.1
        }
        let drawingRect = rect.insetBy(dx: frameWidth / 2,
                                       dy: frameWidth / 2)
        let cornerHeightLength = rect.height * frameAspect
        let cornerWidthLength = rect.width * frameAspect
        
        let framePath = UIBezierPath()
        //left top corner
        framePath.move(to: CGPoint(x: drawingRect.origin.x,
                                   y: drawingRect.origin.y + cornerHeightLength))
        framePath.addLine(to: CGPoint(x: drawingRect.origin.x,
                                      y: drawingRect.origin.y))
        framePath.addLine(to: CGPoint(x: drawingRect.origin.x + cornerWidthLength,
                                      y: drawingRect.origin.y))
        //right top corner
        framePath.move(to: CGPoint(x: drawingRect.origin.x + drawingRect.width - cornerWidthLength,
                                   y: drawingRect.origin.y))
        framePath.addLine(to: CGPoint(x: drawingRect.origin.x + drawingRect.width,
                                      y: drawingRect.origin.y))
        framePath.addLine(to: CGPoint(x: drawingRect.origin.x + drawingRect.width,
                                      y: drawingRect.origin.y + cornerHeightLength))
        //right bottom corner
        framePath.move(to: CGPoint(x: drawingRect.origin.x + drawingRect.width,
                                   y: drawingRect.origin.y + drawingRect.height - cornerHeightLength))
        framePath.addLine(to: CGPoint(x: drawingRect.origin.x + drawingRect.width,
                                      y: drawingRect.origin.y + drawingRect.height))
        framePath.addLine(to: CGPoint(x: drawingRect.origin.x + drawingRect.width - cornerWidthLength,
                                      y: drawingRect.origin.y + drawingRect.height))
        //left bottom corner
        framePath.move(to: CGPoint(x: drawingRect.origin.x + cornerWidthLength,
                                   y: drawingRect.origin.y + drawingRect.height))
        framePath.addLine(to: CGPoint(x: drawingRect.origin.x,
                                      y: drawingRect.origin.y + drawingRect.height))
        framePath.addLine(to: CGPoint(x: drawingRect.origin.x,
                                      y: drawingRect.origin.y + drawingRect.height - cornerHeightLength))
        
        //drawing
        framePath.lineWidth = frameWidth
        //stroke
        frameColor.setStroke()
        framePath.stroke()
        
        
    }
}
