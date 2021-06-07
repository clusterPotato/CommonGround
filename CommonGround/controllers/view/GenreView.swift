//
//  GenreView.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/4/21.
//

import UIKit
class GenreViewController: UIViewController{
    //MARK: iboutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    var userData: UserData?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUserGenres()
    }
    func setUserGenres(){
        guard let userdata = userData else { return}
        var tvText = ""
        for genre in userdata.genres{
            tvText += "\(genre)\n"
        }
        textView.text = tvText
    }
}
