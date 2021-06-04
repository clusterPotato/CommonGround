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
//    init(_ t: [String: String]){
//        self.id = t["id"] ?? ""
//        self.display_name = t["display_name"] ?? ""
//    }
    let images: [UserImage]
}
struct UserImage: Codable{
    let url: String
}
