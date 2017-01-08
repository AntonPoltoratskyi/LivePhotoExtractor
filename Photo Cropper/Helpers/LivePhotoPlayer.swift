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
    var duration: CMTime? {get}
    init(_ url: URL)
    func layer() -> AVPlayerLayer
    func move(to seconds: Double) throws
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) throws
}

class LivePhotoPlayer: PlayerBehaviour {
    var videoUrl: URL
    
    lazy var player: AVPlayer = {
        return AVPlayer(url: self.videoUrl)
    }()
    
    var duration: CMTime? {
        return player.currentItem?.asset.duration
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
        guard let duration = duration, duration.seconds >= seconds else {
            throw LivePhotoPlayerError.wrongTime
        }
        let time = CMTime(seconds: seconds, preferredTimescale: 10)
        player.seek(to: time)
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) throws {
        guard let generator = imageGenerator else {
            throw LivePhotoPlayerError.emptyImageGenerator
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
            completion(UIImage(cgImage: image), error)
        }
    }
}
