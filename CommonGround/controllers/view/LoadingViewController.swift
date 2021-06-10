//
//  LoadingViewController.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/10/21.
//

import UIKit
class LoadingViewController: UIViewController{
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.transform = CGAffineTransform(scaleX: 5, y: 5)
    }
}
