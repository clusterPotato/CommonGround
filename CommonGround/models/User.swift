//
//  User.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/1/21.
//

import Foundation
struct User: Codable, Equatable{
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    let id: String
    let display_name: String
    init(_ t: [String: Any]){
        self.id = t["id"] as? String ?? ""
        self.display_name = t["display_name"] as? String ?? ""
        let thing = t["images"]
        guard let imagess = t["images"] as? NSArray else {
            self.images = [UserImage(url: "")];return}
        let imagesString = imagess.value(forKey: "url")
        let singleoa = imagesString as! NSArray
        let stringy = singleoa[0] as! NSString
        self.images = [UserImage(url: stringy as! String)]
    }
    let images: [UserImage]
}
struct UserImage: Codable, Equatable{
    let url: String
}
//struct User: Codable {
//    
//    static func == (lhs: User, rhs: User) -> Bool {
//        return lhs.id == rhs.id
//    }
//    
//    let country: String
//    let displayName: String
//    let email: String
//    
//    let externalUrls: ExternalUrls
//    struct ExternalUrls: Codable {
//        let spotify: URL
//    }
//    
//    let followers: Followers
//    struct Followers: Codable {
//        let href: String
//        let total: Int
//    }
//    
//    let href: URL
//    let id: String
//    
//    let images: [Image]
//    struct Image: Codable {
//        let height: Int
//        let url: URL
//        let width: Int
//    }
//    
//    let product: String
//    let type: String
//    let uri: String
//    
//    private enum CodingKeys: String, CodingKey {
//        case country
//        case displayName = "display_name"
//        case email
//        case externalUrls = "external_urls"
//        case followers
//        case href
//        case id
//        case images
//        case product
//        case type
//        case uri
//    }
//}
