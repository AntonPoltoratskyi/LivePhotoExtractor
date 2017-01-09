//
//  FullScreenViewController.swift
//  Photo Cropper
//
//  Created by Gleb Radchenko on 09.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

class FullScreenViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = detailsImage
        }
    }
    
    var detailsImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setup(_ image: UIImage) {
        self.detailsImage = image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
