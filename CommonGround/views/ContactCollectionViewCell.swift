//
//  ContactCollectionViewCell.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/3/21.
//

import UIKit
protocol CellDelegate: AnyObject{
    func buttonwasPressed(image: UIImage, name: String, indexPath: IndexPath, sender: UserCell)
}
class UserCell: UICollectionViewCell{
    //MARK: outlets
    weak var delegate: CellDelegate?
    var user: User?
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
        guard let user = user else { return}
        loadImage { image in
            DispatchQueue.main.async{
                self.pictureView.image = image
                self.nameLabel.text = user.display_name
            }
        }
    }
    func mockData(){
        pictureView.layer.cornerRadius = 5
        shadeView.layer.cornerRadius = 5
        nameLabel.text = "Josh A"
        pictureView.image = UIImage(named: "josh a")
        contentView.layer.cornerRadius = 20
        contentView.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowRadius=20
    }
    func lilReviveMockData(){
        pictureView.layer.cornerRadius = 5
        shadeView.layer.cornerRadius = 5
        nameLabel.text = "Lil Revive"
        pictureView.image = UIImage(named: "lil_revive")
        contentView.layer.cornerRadius = 20
        contentView.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowRadius=20
    }
    func loadImage(completion: @escaping(UIImage)->Void){
        guard let user = user else { return}
        guard let imageURL = URL(string: user.images[0].url) else { return}
        URLSession.shared.dataTask(with: URLRequest(url:imageURL)) { data, resp, err in
            if let err = err{
                print(err)
            }else{
                guard let data = data else { return}
                guard let image = UIImage(data: data) else { return}
                return completion(image)
            }
        }.resume()
    }
    override func prepareForReuse() {
        self.load()
        
    }
    
    @IBAction func buttonPress(_ sender: Any) {
        guard let indexpath = indexPath else { return}
        guard let image = pictureView.image else { print("nil");return}
        delegate?.buttonwasPressed(image: image , name: nameLabel.text ?? "", indexPath: indexpath, sender: self)
    }
}
