//
//  TinderView.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/3/21.
//

import UIKit
class TinderViewController: UIViewController{
    //MARK: outlets

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var xbutton: UIButton!
    @IBOutlet weak var heartbutton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sytlize()
    }
    func sytlize(){
        playButton.setRadiusWithShadow(playButton.layer.bounds.height/2)
        xbutton.setRadiusWithShadow(xbutton.layer.bounds.height/2)
        heartbutton.setRadiusWithShadow(heartbutton.layer.bounds.height/2)
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        //back button was pressed
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let backwardsVC = sb.instantiateViewController(identifier: "")
    }
}
