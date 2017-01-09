//
//  UIImage+Watermark.swift
//  Photo Cropper
//
//  Created by Anton Poltoratskyi on 09.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

extension UIImage {
    
    func addingWatermark(text: String, font: UIFont, color: UIColor) -> UIImage {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        
        let attributes = [NSFontAttributeName: font,
                          NSForegroundColorAttributeName: color,
                          NSParagraphStyleAttributeName: paragraphStyle]
        
        // Calculate needed text bounds
        
        let horizontalOffset: CGFloat = 16.0
        let verticalOffset: CGFloat = 16.0
        
        let maxSize = CGSize(width: self.size.width - horizontalOffset * 2, height: self.size.height)
        let contentBounds = (text as NSString).boundingRect(with: maxSize,
                                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                            attributes: attributes,
                                                            context: nil)
        
        //Drawing
        
        let watermarkRect = CGRect(x: horizontalOffset,
                                   y: self.size.height - contentBounds.size.height - verticalOffset,
                                   width: self.size.width - horizontalOffset * 2,
                                   height: self.size.height - verticalOffset * 2)
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        (text as NSString).draw(with: watermarkRect,
                                options: [.usesLineFragmentOrigin, .usesFontLeading],
                                attributes: attributes, context: nil)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage ?? self
    }
}
