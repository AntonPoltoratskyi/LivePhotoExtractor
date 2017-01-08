//
//  CropperViewController.swift
//  Photo Cropper
//
//  Created by Anton Poltoratskyi on 08.01.17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

class CropperViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentSlider: CustomSlider!
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: - View
    
    func setupUI() {
        
    }
    
    
    //MARK: - Actions
    
    @IBAction func actionDidTapShareButton(_ sender: Any) {
        
    }
    
    @IBAction func actionSliderValueChanged(_ sender: CustomSlider) {
        print("current progress is \(sender.progress)")
    }
    
    
}
