//
//  MediaResourceManager.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 08.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import PhotosUI

enum MediaResourceManagerError: Error {
    case noLivePhoto
}
public typealias LivePhotoExtractCompletion = (URL?, Error?) -> Void

class MediaResourceManager {
    func process(_ info: [String: Any], completion: @escaping LivePhotoExtractCompletion) {
        if let livePhoto = info[UIImagePickerControllerLivePhoto] as? PHLivePhoto {
            let assetResources = PHAssetResource.assetResources(for: livePhoto)
            for resource in assetResources {
                if resource.type == .pairedVideo {
                    requestVideo(for: resource, completion: completion)
                    break
                }
            }
        } else {
            completion(nil, MediaResourceManagerError.noLivePhoto)
        }
    }
    func requestVideo(for resource: PHAssetResource, completion: @escaping LivePhotoExtractCompletion) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        var videoUrl = URL(fileURLWithPath: path)
        videoUrl = videoUrl.appendingPathComponent(resource.originalFilename)
        if FileManager.default.fileExists(atPath: videoUrl.path) {
            completion(videoUrl, nil)
            return
        }
        PHAssetResourceManager.default().writeData(for: resource, toFile: videoUrl, options: nil) { (error) in
            completion(videoUrl, error)
        }
    }
}
