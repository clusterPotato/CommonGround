//
//  UserData.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/4/21.
//

import Foundation
class UserData: Equatable{
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs.user.id == rhs.user.id
    }
    let user: User
    let genres: [String]
    //MARK: init
    init(user: User, genres: [String]){
        self.user = user
        self.genres = genres
    }
}
struct ModelData: Codable{
    let genres: [String]
}
