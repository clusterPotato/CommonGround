//
//  ViewController.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/1/21.
//

import UIKit
class SongSwipeViewController: UIViewController {
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    var canLoad = false
    var playingWithUser: User?{
        didSet{
            canLoad = true
        }
    }
    weak var delegate: EmbedDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        if canLoad{
            load()
        }
    }
    
    @IBAction func buttonWasPressed(_ sender: Any) {
        SongsController.shared.getTestSongData { result in
            switch result{
            case .success(let song):
                DispatchQueue.main.async {
                    self.decorateScreenWith(song)
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    self.presentErrorToUser(localizedError: err)
                }
            }
        }
    }
    func decorateScreenWith(_ song: SpotifySong){
        delegate?.changeInfo(song: song)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "relation"{
            guard let destination = segue.destination as? EmbedDelegate else { return}
            self.delegate = destination
        }
    }
    func load(){
        titleLabel.text = "Common Grounds with \(playingWithUser!.display_name)"
    }
}

