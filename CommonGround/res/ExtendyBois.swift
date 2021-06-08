//
//  ExtendyBois.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/3/21.
//

import UIKit
extension Encodable {
    var toDictionnary: [String : Any]? {
        guard let data =  try? JSONEncoder().encode(self) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }
    
}
protocol UserListChangedHandler:AnyObject{
    func dataChanged()
}
protocol EmbedDelegate: AnyObject{
    func changeInfo(song: SpotifySong)
}
extension UIView{
    func anchor(top: NSLayoutYAxisAnchor?, bottom: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingBottom: CGFloat, paddingLeading: CGFloat, paddingtrailing: CGFloat, width: CGFloat? = nil, height: CGFloat? = nil){
        self.translatesAutoresizingMaskIntoConstraints = false
        if let top = top{
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let bottom = bottom{
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        if let leading = leading{
            self.leadingAnchor.constraint(equalTo: leading, constant: paddingLeading).isActive = true
        }
        if let trailing = trailing{
            self.trailingAnchor.constraint(equalTo: trailing, constant: -paddingtrailing).isActive = true
        }
        if let width = width{
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height{
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension UIView {

  // OUTPUT 1
  func dropShadow(scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width: -1, height: 1)
    layer.shadowRadius = 1

    layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }

  // OUTPUT 2
  func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowOffset = offSet
    layer.shadowRadius = radius

    layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }
    func setRadiusWithShadow(_ radius: CGFloat? = nil) {
            self.layer.cornerRadius = radius ?? self.frame.width / 2
            self.layer.shadowColor = UIColor.darkGray.cgColor
            self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
            self.layer.shadowRadius = 1.0
            self.layer.shadowOpacity = 0.7
            self.layer.masksToBounds = false
        }
}
extension UserPickVC: UserListChangedHandler{
    func dataChanged() {
        DispatchQueue.main.async {
            self.recentUsersCollectionView.reloadData()
            //print("delegate data changed")
        }
    }
    
    
}
extension SpotifyArtist{
    static func fromDBListEntry(_ t: Any)->SpotifyArtist?{
        guard let t = t as? [String: Any] else { return nil}
        let genres = t["genres"] as? [String] ?? []
        guard let id = t["id"] as? String else { return nil}
        guard let name = t["name"] as? String else { return nil}
        guard let uri = t["uri"] as? String else { return nil}
        return SpotifyArtist(uri: uri, name: name, id: id, genres: genres)
    }
}
