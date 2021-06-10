//
//  SpotifySong.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/1/21.
//

import Foundation
struct SpotifySong: Codable{
    let artists: [GenrelessSpotifyArtist]
    let album: SpotifyAlbum
    let uri: String
    let name: String
    let preview_url: URL?
    let id: String
}
struct SpotifyAlbum: Codable{
    let artists: [GenrelessSpotifyArtist]
    let name: String
    let images: [SpotifyAlbumArt]
    let uri: String
    let release_date: String
}
struct SpotifyArtist: Codable{
    let uri:String
    let name: String
    let id: String
    let genres: [String]
}
struct GenrelessSpotifyArtist: Codable{
    let uri:String
    let name: String
    let id: String
}
struct SpotifyAlbumArt: Codable{
    let url: URL
}
struct ArtistObject: Codable{
    let items:[SpotifyArtist]
}
struct TrackObject: Codable{
    let items: [SpotifySong]
}
struct TrackData: Codable{
    let tracks: [SpotifySong]
}
struct SpotifyPlaylistListItem: Codable{
    let name: String
    let id: String
}
struct SpotifyPlaylistList: Codable{
    let items: [SpotifyPlaylistListItem]
}
struct SpotifyPlaylistTrackList: Codable{
    let items: [SpotifyPlaylistTrackListItem]
}
struct SpotifyPlaylistTrackListItem: Codable{
    let track: SpotifySong
}
