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
    func captureImageSynchronously() -> UIImage? 
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
        let generator = AVAssetImageGenerator(asset: asset)
        
        generator.appliesPreferredTrackTransform = true
        
        generator.requestedTimeToleranceBefore = kCMTimeZero
        generator.requestedTimeToleranceAfter = kCMTimeZero
        
        return generator
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
        let time = CMTime(seconds: seconds, preferredTimescale: 60000)
        player.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let generator = imageGenerator else {
            completion(nil, LivePhotoPlayerError.emptyImageGenerator)
            return
        }
        let currentTime = player.currentTime()
        
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: currentTime)]) { [weak self] (firstTime, image, secondTime, result, error) in
            
            guard let image = image else {
                completion(nil, error)
                return
            }
            var shouldRotate = false
            if let videoSize = self?.player.currentItem?.presentationSize {
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
    func captureImageSynchronously() -> UIImage? {
        guard let generator = imageGenerator else {
            return nil
        }
        let currentTime = player.currentTime()
        do {
            let image = try generator.copyCGImage(at: currentTime, actualTime: nil)
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
            return anImage
        } catch {
            debugPrint(error)
            return nil
        }
    }
}

