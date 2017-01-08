//
//  LivePhotoPlayer.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 08.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation

enum LivePhotoPlayerError: Error {
    case wrongTime
    case emptyImageGenerator
}

protocol PlayerBehaviour {
    var videoUrl: URL {get set}
    var player: AVPlayer {get set}
    var duration: Double? {get}
    init(_ url: URL)
    func layer() -> AVPlayerLayer
    func move(to seconds: Double) throws
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void)
}

class LivePhotoPlayer: PlayerBehaviour {
    var videoUrl: URL
    
    lazy var player: AVPlayer = {
        return AVPlayer(url: self.videoUrl)
    }()
    
    var duration: Double? {
        return player.currentItem?.asset.duration.seconds
    }
    
    fileprivate var imageGenerator: AVAssetImageGenerator? {
        guard let asset = player.currentItem?.asset else {
            return nil
        }
        return AVAssetImageGenerator(asset: asset)
    }
    
    required init(_ url: URL) {
        self.videoUrl = url
    }
    
    func layer() -> AVPlayerLayer {
        return AVPlayerLayer(player: player)
    }
    
    func move(to seconds: Double) throws {
        guard let duration = duration, duration >= seconds else {
            throw LivePhotoPlayerError.wrongTime
        }
        let time = CMTime(seconds: seconds, preferredTimescale: 1000)
        player.seek(to: time)
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let generator = imageGenerator else {
            completion(nil, LivePhotoPlayerError.emptyImageGenerator)
            return
        }
        let currentTime = player.currentTime()
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: currentTime)]) { (firstTime, image, secondTime, result, error) in
            print(firstTime)
            print(secondTime)
            print(result)
            print(error)
            guard let image = image else {
                completion(nil, error)
                return
            }
            var shouldRotate = false
            if let videoSize = self.player.currentItem?.presentationSize {
                if (videoSize.width > videoSize.height && image.width > image.height) ||
                    (videoSize.width < videoSize.height && image.width < image.height) {
                    shouldRotate = false
                } else {
                    shouldRotate = true
                }
            }
            
            var anImage = UIImage(cgImage: image)
            if shouldRotate {
                anImage = anImage.imageRotatedByDegrees(degrees: 90, flip: false)
            }
            completion(anImage, error)
        }
    }
}
extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
        let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        bitmap?.rotate(by: degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        bitmap?.scaleBy(x: yFlip, y: -1.0)
        bitmap?.draw(cgImage!,
                     in: CGRect(x: -size.width / 2,
                                y:  -size.height / 2,
                                width: size.width,
                                height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
