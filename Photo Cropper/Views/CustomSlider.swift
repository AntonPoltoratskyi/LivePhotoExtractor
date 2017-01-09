//
//  CustomSlider.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 08.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

//@IBDesignable
class CustomSlider: UIControl {
    
    var indicator: SliderIndicator!
    var leftBar: UIView!
    var rightBar: UIView!
    
    @IBInspectable var leftBarColor: UIColor = .white
    @IBInspectable var rightBarColor: UIColor = UIColor(red: 13 / 255, green: 18 / 255, blue: 83 / 255, alpha: 1.0)
    @IBInspectable var indicatorColor: UIColor = .white
    
    var progress: CGFloat = 0
    
    private var indicatorWidth: CGFloat {
        return self.bounds.height * 0.62
    }
    private var indicatorHeight: CGFloat {
        return self.bounds.height * 0.71
    }
    
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    //MARK: - Setup
    
    func setup() {
        //initialize bars
        self.backgroundColor = .clear
        self.leftBar = UIView()
        self.leftBar.backgroundColor = self.leftBarColor
        self.leftBar.alpha = 1
        
        self.rightBar = UIView()
        self.rightBar.backgroundColor = self.rightBarColor
        self.rightBar.alpha = 0.4
        
        //initialize indicator
        self.indicator = SliderIndicator()
        self.indicator.color = self.indicatorColor
        self.addSubview(leftBar)
        self.addSubview(rightBar)
        self.addSubview(indicator)
    }
    
    
    //MARK: - Layout
    
    override func layoutSubviews() {
        
        if (self.indicator.frame == .zero){
            self.indicator.frame = CGRect(x: 0,
                                          y: self.bounds.height * 0.21,
                                          width: indicatorWidth,
                                          height: indicatorHeight)
        }
        
        //layout bars
        let totalBarWidth = self.bounds.width - indicatorWidth
        self.leftBar.frame = CGRect(x: indicatorWidth / 2,
                                    y: 0.14 * self.bounds.height,
                                    width: totalBarWidth * self.progress,
                                    height: 0.07 * self.bounds.height)
        self.rightBar.frame = CGRect(x: indicatorWidth / 2 + leftBar.frame.width,
                                     y: 0.14 * self.bounds.height,
                                     width: totalBarWidth * (1 - self.progress),
                                     height: 0.07 * self.bounds.height)
    }
    
    //MARK: - Interaction
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self.indicator)
        if (self.indicator.bounds.contains(point)) {
            return true
        } else {
            return false
        }
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        let delta = touch.location(in: self.indicator).x - touch.previousLocation(in: self.indicator).x
        let futureP = self.indicator.center.x + delta
        
        var doMove = true
        if (touch.location(in: self.indicator).x > touch.previousLocation(in: self.indicator).x) {
            let result = self.indicator.rotateRight()
            if result == true {
                doMove = false
            }
        } else {
            let result = self.indicator.rotateLeft()
            if result == true {
                doMove = false
            }
        }
        
        if (doMove == true) {
            if(futureP.within(value1: indicatorWidth/2, value2: self.bounds.width - indicatorWidth/2)){
                self.indicator.center.x += delta
            }
            if (futureP > self.bounds.width - indicatorWidth/2) {
                self.indicator.center.x = self.bounds.width - indicatorWidth / 2
            }
            if (futureP < indicatorWidth/2) {
                self.indicator.center.x = indicatorWidth/2
            }
            self.progress = (self.indicator.center.x - indicatorWidth/2) / (self.bounds.width - indicatorWidth)
            self.sendActions(for: .valueChanged)
            self.layoutSubviews()
        }
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.indicator.resetRotation()
    }
}


//MARK: -
class SliderIndicator: UIView {
    
    var containerView:UIView!
    let circleLayer = CAShapeLayer()
    let triangleLayer = CAShapeLayer()
    
    let maxRadian = CGFloat(M_PI / 8)
    let maxMove:CGFloat = 3
    var ovalInset:CGFloat{
        return self.bounds.width / 10
    }
    
    var currentAngle:CGFloat{
        return atan2(self.containerView.layer.transform.m12, self.containerView.layer.transform.m11)
    }
    var color: UIColor!
    
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //MARK: - Setup
    
    func setup() {
        self.isUserInteractionEnabled = false
        containerView = UIView()
        self.addSubview(containerView)
        containerView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        
        containerView.layer.addSublayer(circleLayer)
        containerView.layer.addSublayer(triangleLayer)
    }
    
    //MARK: - Rotation
    
    func rotateRight() -> Bool{
        guard self.currentAngle > -maxRadian else {
            return false
        }
        self.containerView.layer.transform = CATransform3DRotate(self.containerView.layer.transform,
                                                                 -self.maxRadian/maxMove, 0.0, 0.00001, 1)
        return true
    }
    func rotateLeft() -> Bool{
        guard self.currentAngle < maxRadian else {
            return false
        }
        self.containerView.layer.transform = CATransform3DRotate(self.containerView.layer.transform,
                                                                 self.maxRadian/maxMove, 0.0, 0.00001, 1)
        return true
    }
    
    func resetRotation(){
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        self.containerView.layer.transform = CATransform3DIdentity
        }, completion: nil)
    }
    
    
    //MARK: - Layout
    
    override func layoutSubviews(){
        self.containerView.frame = self.bounds
        self.circleLayer.frame = self.bounds
        self.triangleLayer.frame = self.bounds
        let ovalPath = CGMutablePath()
        let ovalframe = CGRect(x: 0,
                               y: (self.bounds.height - self.bounds.width),
                               width: self.bounds.width,
                               height: self.bounds.width)
        ovalPath.addPath(CGPath(ellipseIn: ovalframe, transform: nil))
        ovalPath.addPath(CGPath(ellipseIn: ovalframe.insetBy(dx: self.ovalInset, dy: self.ovalInset), transform: nil))
        self.circleLayer.fillRule = kCAFillRuleEvenOdd
        self.circleLayer.path = ovalPath
        self.circleLayer.fillColor = self.color.cgColor
        
        
        let trianglePath = CGMutablePath()
        let triangleWidth_2:CGFloat = self.bounds.width / 10
        trianglePath.move(to: CGPoint(x: self.bounds.width / 2, y: 2))
        trianglePath.addLine(to: CGPoint(x: self.bounds.width / 2 + triangleWidth_2, y: self.bounds.height - self.bounds.width + 2))
        trianglePath.addLine(to: CGPoint(x: self.bounds.width / 2 - triangleWidth_2, y: self.bounds.height - self.bounds.width + 2))
        trianglePath.closeSubpath()
        self.triangleLayer.path = trianglePath
        self.triangleLayer.fillColor = self.color.cgColor
    }
}

//MARK: -
extension CGFloat{
    func within(value1: CGFloat, value2: CGFloat) -> Bool{
        if(self <= value2 && self >= value1){
            return true
        }
        return false
    }
}
