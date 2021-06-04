//
//  UserPickVC.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/3/21.
//

import UIKit
class UserPickVC: UIViewController{
    //MARK: outlets
    @IBOutlet weak var recentUsersCollectionView: UICollectionView!
    @IBOutlet weak var labelStak: UIStackView!
    @IBOutlet weak var user_nameLabel: UILabel!
    @IBOutlet weak var user_genresLabel: UILabel!
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    
    //MARK: junk
    var width: CGFloat = 0.0
    var previouslySelectedCell: UserCell?
    let iphone11Height: CGFloat = 1792
    var height: CGFloat = 0.0
    let iphone11Width: CGFloat = 828
    
    //MARK: vdl
    override func viewDidLoad() {
        super.viewDidLoad()
        height = view.bounds.height
        width = view.bounds.width
        recentUsersCollectionView.delegate = self
        recentUsersCollectionView.dataSource = self
        loadUp()
    }
    func loadUp(){
        stylizeViews()
    }
}
extension UserPickVC: UICollectionViewDelegate, UICollectionViewDataSource, CellDelegate{
    func buttonwasPressed(image: UIImage, name: String, indexPath: IndexPath, sender: UserCell) {
        pickedImageView.image = image
        user_nameLabel.text = name
        user_genresLabel.text = name
        user_nameLabel.textColor = UIColor(named:"TextColor")
        user_genresLabel.textColor = UIColor(named:"TextColor")
        print("set image?")
        UIView.animate(withDuration: 2) {
            sender.layer.borderWidth = 2
        }
        if let cell = self.previouslySelectedCell{
            cell.layer.borderWidth=0
            print(sender.indexPath)
        }
       
        self.previouslySelectedCell=sender
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 10
        }else {return 1}
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section==0{
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "manCell", for: indexPath) as? UserCell{
                cell.delegate = self
                cell.layer.cornerRadius = 20
                cell.layer.borderColor = UIColor(named: "TextColor")?.cgColor
                if indexPath.row==1{
                    cell.user = User(id: "1", display_name: "smithimitron", images: [UserImage(url: "https://i.stack.imgur.com/wjSRd.gif")])
                    cell.load()
                }else if indexPath.row==2{
                    cell.user = User(id: "2", display_name: "chicken", images: [UserImage(url: "https://www.maangchi.com/wp-content/uploads/2018/02/roasted-chicken-1.jpg")])
                    cell.load()
                }
                else{
                    cell.load()
                }
                cell.indexPath = indexPath
                return cell
            }else{
                return UICollectionViewCell()
            }
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdditionalCell", for: indexPath)
            cell.layer.cornerRadius = 20
            return cell
        }
    }
    func stylizeViews(){
        startButton.layer.cornerRadius = 20
        pickedImageView.layer.cornerRadius = 20
        startButton.backgroundColor = UIColor(named: "ButtonColor")
    }
}
