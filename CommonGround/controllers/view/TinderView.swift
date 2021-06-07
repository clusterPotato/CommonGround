//
//  TinderView.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/3/21.
//

import UIKit
class TinderViewController: UIViewController{
    //MARK: outlets

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var xbutton: UIButton!
    @IBOutlet weak var heartbutton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    
    //MARK: properties
    var otherUserData: UserData?
    //i would make a current user data but that would just be a weak reference to one that already exists in usercontroller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sytlize()
    }
    func sytlize(){
        playButton.setRadiusWithShadow(playButton.layer.bounds.height/2)
        xbutton.setRadiusWithShadow(xbutton.layer.bounds.height/2)
        heartbutton.setRadiusWithShadow(heartbutton.layer.bounds.height/2)
        let gestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(dislikeCurrentSong))
        gestureLeft.direction = .left
        let gestureRight = UISwipeGestureRecognizer(target: self, action: #selector(likeCurrentSong))
        gestureLeft.direction = .right
        container.addGestureRecognizer(gestureLeft)
        container.addGestureRecognizer(gestureRight)
    }
    //MARK: actions
    @IBAction func backButtonPressed(_ sender: Any) {
        //back button was pressed
        dismiss(animated: true, completion: nil)
    }
    @IBAction func heartButtonPressed(_ sender: Any) {
        likeCurrentSong()
    }
    @IBAction func xButtonPressed(_ sender: Any) {
        dislikeCurrentSong()
    }
    @IBAction func playPreviewButtonPressed(_ sender: Any) {
        playSongDemo()
    }
    @objc func dislikeCurrentSong(){
        print("no")
    }
    @objc func likeCurrentSong(){
        print("yes")
    }
    @objc func playSongDemo(){
        
    }
}
