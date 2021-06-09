//
//  Strings.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/1/21.
//

import Foundation
struct Strings{
    static let herokuBase = "https://thingyjig.herokuapp.com/api/token"
    static let client_id = "8b66f7b016cb422b81a75cdff83f975e"
    static let client_secret = "dc70fca8e7744301b8a14f2954dc068b"
    static let base64Secret = "OGI2NmY3YjAxNmNiNDIyYjgxYTc1Y2RmZjgzZjk3NWU6ZGM3MGZjYThlNzc0NDMwMWI4YTE0ZjI5NTRkYzA2OGI="
    static let encryptionSalt = "QwabGYrkJWkvt389xqDKkQIPIcKUg8Ns"
    static let spotifyApiBase = "https://spotty-common-ground.herokuapp.com/api/token"
    static let spotifyRedirectURI = "commonGround://open"
    static let spotifyApiAuthURL = "https://accounts.spotify.com/authorize?client_id=\(client_id)&response_type=code&redirect_uri=\(spotifyRedirectURI)&scope=playlist-modify-public%20user-top-read"
    static let spotifyApiOauthURL = "https://accounts.spotify.com/api/token"
    static var openURLString: String?
    static var oauthCode: String?
    static var token: String?
    static let genreSeedsURL = "https://api.spotify.com/v1/recommendations/available-genre-seeds"
    static let topArtistSeedsURL = "https://api.spotify.com/v1/me/top/artists?limit=50&time_range=long_term"
    static let recommendationsURL = "https://api.spotify.com/v1/recommendations"
    static let topSongSeedsURL = "https://api.spotify.com/v1/me/top/tracks?limit=50&time_range=long_term"
}
