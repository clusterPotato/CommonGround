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
            ////print("delegate data changed")
        }
    }
    
    
}
extension SpotifyArtist{
    static func fromDBListEntry(_ t: Any)->SpotifyArtist{
        let t = t as! [String: Any]
        let genres = t["genres"] as? [String] ?? []
        let id = t["id"] as? String ?? ""
        let name = t["name"] as? String ?? ""
        let uri = t["uri"] as? String ?? ""
        return SpotifyArtist(uri: uri, name: name, id: id, genres: genres)
    }
}
extension GenrelessSpotifyArtist{
    static func fromDBListEntry(_ t: Any)->GenrelessSpotifyArtist{
        let t = t as! [String: Any]
        let id = t["id"] as? String ?? ""
        let name = t["name"] as? String ?? ""
        let uri = t["uri"] as? String ?? ""
        return GenrelessSpotifyArtist(uri: uri, name: name, id: id)
    }
    static func arrayFromDBListEntry(_ t: Any)->[GenrelessSpotifyArtist]{
        var retVar: [GenrelessSpotifyArtist] = []
        guard let t = t as? [Any] else { return []}
        for s in t{
            guard let s = s as? [String: String] else { break}
            let id = s["id"] ?? ""
            let name = s["name"] ?? ""
            let uri = s["uri"] ?? ""
            let x = GenrelessSpotifyArtist(uri: uri, name: name, id: id)
            retVar.append(x)
        }
        return retVar
    }
}
extension SpotifySong{
    static func fromDBListEntry(_ t: Any)->SpotifySong{
        let t = t as! [String: Any]
        let artists = GenrelessSpotifyArtist.arrayFromDBListEntry(t["artists"] as Any)
        let album = SpotifyAlbum.fromDBListEntry(t["album"]as Any)
        let id = t["id"] as? String ?? ""
        let url: URL? = t["preview_url"] as? URL ?? nil
        let name = t["name"] as? String ?? ""
        let uri = t["uri"] as? String ?? ""
        return SpotifySong(artists: artists, album: album, uri: uri, name: name, preview_url: url, id: id)
    }
}
extension SpotifyAlbum{
    static func fromDBListEntry(_ t: Any)->SpotifyAlbum{
        //print(t)
        let t = t as! [String: Any]
        let artists = GenrelessSpotifyArtist.arrayFromDBListEntry(t["artists"]!)
        let images = SpotifyAlbumArt.arrayFromDBListEntry(t["images"] as Any)
        let name = t["name"] as? String ?? ""
        let uri = t["uri"] as? String ?? ""
        let release_date = t["release_date"] as? String ?? ""
        return SpotifyAlbum(artists: artists, name: name, images: images, uri: uri, release_date: release_date)
    }
}
extension SpotifyAlbumArt{
    static func fromDBListEntry(_ t: Any)->SpotifyAlbumArt{
        let t = t as! [String: Any]
        let url = t["url"] as? String ?? ""
        return SpotifyAlbumArt(url: URL(string: url)!)
    }
    static func arrayFromDBListEntry(_ t: Any)->[SpotifyAlbumArt]{
        var retvar: [SpotifyAlbumArt] = []
        let t = t as! [Any]
        for s in t{
            guard let s = s as? [String: String] else { break}
            let url = s["url"] ?? ""
            let x = SpotifyAlbumArt(url: URL(string: url)!)
            retvar.append(x)
        }
        return retvar
    }
}
