//
//  ContactCollectionViewCell.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/3/21.
//

import UIKit
protocol UserCellDelegate: AnyObject{
    func cellButtonPressed(sender: UserCell)
}
class UserCell: UICollectionViewCell{
    //MARK: outlets
    weak var delegate: UserCellDelegate?
    var userdata: UserData?
    var indexPath: IndexPath?
    @IBOutlet weak var shadeView: UIView!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: actions
    
    //MARK: funcs
    func load(){
        pictureView.layer.cornerRadius = 20
        guard let user = userdata else { return}
        DispatchQueue.main.async {
            self.nameLabel.text = user.user.display_name
        }
        loadImage { image in
            DispatchQueue.main.async{
                self.pictureView.image = image
            }
        }
    }
    func loadImage(completion: @escaping(UIImage)->Void){
        guard let user = userdata else { return}
        guard user.user.images.count > 0 else { return}
        guard let imageURL = URL(string: user.user.images[0].url) else { return}
        URLSession.shared.dataTask(with: URLRequest(url:imageURL)) { data, resp, err in
            if let err = err{
                //print(err)
            }else{
                guard let data = data else { return}
                guard let image = UIImage(data: data) else { return}
                return completion(image)
            }
        }.resume()
    }
    override func prepareForReuse() {
        pictureView.image = UIImage(named: "blank_man")
        
    }
    
    @IBAction func buttonPress(_ sender: Any) {
        guard let indexpath = indexPath else { return}
        guard let image = pictureView.image else {return}
        delegate?.cellButtonPressed(sender: self)
    }
}
