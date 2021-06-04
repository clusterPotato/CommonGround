//
//  SpotifySong.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/1/21.
//

import Foundation
struct SpotifySong: Codable{
    let artists: [SpotifyArtist]
    let album: SpotifyAlbum
    let uri: String
    let name: String
    let id: String
}
struct SpotifyAlbum: Codable{
    let artists: [SpotifyArtist]
    let name: String
    let images: [SpotifyAlbumArt]
    let uri: String
    let release_date: String
}
struct SpotifyArtist: Codable{
    let uri:String
    let name: String
}
struct SpotifyAlbumArt: Codable{
    let height: Int
    let width: Int
    let url: URL
}
