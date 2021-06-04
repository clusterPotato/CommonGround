//
//  SpotifySongsController.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/1/21.
//

import Foundation
class SongsController{
    static let shared = SongsController()
    let baseURL = "https://api.spotify.com/v1/tracks/"
    let testID = "11dFghVXANMlKmJXsNCbNl"
    func getTestSongData(completion: @escaping(Result<SpotifySong, SongError>) ->Void){
        getSongData(id: testID) { result in
            return completion(result)
        }
    }
    func getSongData(id: String,completion: @escaping(Result<SpotifySong, SongError>) ->Void){
        guard let token = Strings.token else { return completion(.failure(.noToken))}
        guard let songURL = URL(string: baseURL+id) else { return}
        var request = URLRequest(url: songURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error{
                return completion(.failure(.cannotCompute))
            }
            guard let data = data else { return}
            do{
                let song = try JSONDecoder().decode(SpotifySong.self, from: data)
                completion(.success(song))
            }catch{
                return completion(.failure(.cannotDecode))
            }
        }.resume()
    }
}
