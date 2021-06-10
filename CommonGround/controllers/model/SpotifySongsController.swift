//
//  SpotifySongsController.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/1/21.
//

import Foundation
import Firebase
class SongsController{
    static let shared = SongsController()
    let baseURL = "https://api.spotify.com/v1/tracks/"
    let testID = "11dFghVXANMlKmJXsNCbNl"
    func getUserPlaylists(){
        
    }
    func getTestSongData(completion: @escaping(Result<SpotifySong, SongError>) ->Void){
        getSongData(id: testID) { result in
            return completion(result)
        }
    }
    func setQueuePosition(containerTitle: String, userID: String, position: Int){
        let dbRef = UserController.shared.database.reference().child(containerTitle).child("position").child(userID)
        dbRef.getData { err, snapshot in
            if snapshot.exists(){
                dbRef.setValue(position)
            }else{
                let elements = containerTitle.replacingOccurrences(of: " && ", with: "`").split(separator: "`")
                let reversedString: String = elements[1]+" && "+elements[0]
                let ref = UserController.shared.database.reference().child(reversedString).child("position").child(userID)
                ref.getData { err, snapshot in
                    if snapshot.exists(){
                        ref.setValue(position)
                    }else{
                        let reef = UserController.shared.database.reference().child(containerTitle).child("position")
                        reef.getData { err, snapshot in
                            if snapshot.exists(){
                                dbRef.setValue(position)
                            }else{
                                ref.setValue(position)
                            }
                        }
                    }
                }
            }
        }
    }
    func getQueuePosition(containerTitle: String, userID: String, completion: @escaping(Int)->Void){
        let dbRef = UserController.shared.database.reference().child(containerTitle).child("position").child(userID)
        dbRef.getData { err, snapshot in
            if snapshot.exists(){
                guard let val = snapshot.value as? Int else { return}
                return completion(val)
            }else{
                let elements = containerTitle.replacingOccurrences(of: " && ", with: "`").split(separator: "`")
                let reversedString: String = elements[1]+" && "+elements[0]
                let ref = UserController.shared.database.reference().child(reversedString).child("position").child(userID)
                ref.getData { err, snapshot in
                    if snapshot.exists(){
                        guard let val = snapshot.value as? Int else { return}
                        return completion(val)
                    }else{
                        return completion(0)
                    }
                }
            }
        }
        
    }
    func getSongFromQueue(position: Int, userId: String, containerTitle: String, completion: @escaping(Result<SpotifySong, SongError>)->Void){
        let dbRef = UserController.shared.database.reference().child(containerTitle).child("queue")
        getQueueSongs(dbRef) { result in
            switch result{
            case .success(let ids):
                let nextId = ids[position]
                self.getSongData(id: nextId) { result in
                    switch result{
                    case .success(let song):
                        return completion(.success(song))
                    case .failure(let err):
                        return completion(.failure(err))
                    }
                }
            case .failure(_):
                let elements = containerTitle.replacingOccurrences(of: " && ", with: "`").split(separator: "`")
                let reversedString: String = elements[1]+" && "+elements[0]
                let ref = UserController.shared.database.reference().child(reversedString).child("queue")
                self.getQueueSongs(ref) { result in
                    switch result{
                    case .success(let ids):
                        let nextID = ids[position]
                        self.getSongData(id: nextID) { result in
                            switch result{
                            case .success(let song):
                                return completion(.success(song))
                            case .failure(let err):
                                return completion(.failure(err))
                            }
                        }
                    case .failure(let err):
                        return completion(.failure(.genericErr(err)))
                    }
                }
            }
        }
    }
    func getQueueLength(containerTitle: String, completion: @escaping(Int)->Void){
        let dbRef = UserController.shared.database.reference().child(containerTitle).child("queue")
        getQueueSongs(dbRef){ result in
            switch result{
            case .success(let songs):
                return completion(songs.count)
            case .failure(_):
                let elements = containerTitle.replacingOccurrences(of: " && ", with: "`").split(separator: "`")
                let reversedString: String = elements[1]+" && "+elements[0]
                let ref = UserController.shared.database.reference().child(reversedString).child("queue")
                self.getQueueSongs(ref) { result in
                    switch result{
                    case .success(let songs):
                        return completion(songs.count)
                    case .failure(_):
                        return completion(0)
                    }
                }
            }
        }
        
    }
    func addSongToQueue(song: String, _ containerTitle: String){
        let dbRef = UserController.shared.database.reference().child(containerTitle).child("queue")
        getQueueSongs(dbRef) { result in
            switch result{
            case .success(let ids):
                var newIds = ids
                newIds.append(song)
                dbRef.setValue(newIds)
            case .failure(_):
                let elements = containerTitle.replacingOccurrences(of: " && ", with: "`").split(separator: "`")
                let reversedString: String = elements[1]+" && "+elements[0]
                let ref = UserController.shared.database.reference().child(reversedString).child("queue")
                self.getQueueSongs(ref) { result in
                    switch result{
                    case .success(let ids):
                        var newIds = ids
                        newIds.append(song)
                        ref.setValue(newIds)
                    case .failure(_):
                        ref.setValue([song])
                    }
                }
            }
        }
    }
    func getQueueSongs(_ container: DatabaseReference, completion: @escaping(Result<[String], SongError>)->Void){
        container.getData { err, snapshot in
            if let err = err{
                return completion(.failure(.genericErr(err)))
            }else if snapshot.exists(){
                guard let val = snapshot.value as? [String] else { return completion(.failure(.cannotDecode))}
                return completion(.success(val))
            }else{
                return completion(.failure(.noDB))
            }
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
    func fetchRelevantSongs(_ container: DatabaseReference, completion: @escaping(Result<[String: String],SongError>)->Void){
        container.getData { err, snapshot in
            if let err = err{
                return completion(.failure(.genericErr(err)))
            }else if snapshot.exists(){
                guard let val = snapshot.value as? [String: String] else { return completion(.failure(.cannotCompute))}
                return completion(.success(val))
            }else{
                return completion(.failure(.noDB))
            }
        }
    }
    func saveRelevantSongs(_ container: DatabaseReference, saveData: [String: String], completion: @escaping()->Void){
        container.setValue(saveData) { err, ref in
            if let err = err{
                return
            }
            else {return completion()}
        }
    }
    func likeSong(containerTitle: String, song: SpotifySong, completion: @escaping(Result<SpotifySong, SongError>)->Void){
        guard let current = UserController.shared.currentUser else { return completion(.failure(.noSuchUser))}
        userNum(containerTitle: containerTitle) { user in
            switch user{
            case 0:
                let dbRef = UserController.shared.database.reference().child(containerTitle).child("liked")
                var data: [String: String] = [song.id : current.user.id]
                self.saveRelevantSongs(dbRef, saveData: data) {
                    return completion(.success(song))
                }
            case 1:
                let dbRef = UserController.shared.database.reference().child(containerTitle).child("liked")
                self.fetchRelevantSongs(dbRef) { result in
                    switch result{
                    case .success(let data):
                        print("s")
                        var saveData = data
                        if data.keys.contains(song.id){
                            if saveData[song.id] != current.user.id{
                                self.matchSong(song: song, containerTitle: containerTitle)
                            }
                        }else{
                            saveData[song.id] = current.user.id
                        }
                        self.saveRelevantSongs(dbRef, saveData: saveData) {
                            return completion(.success(song))
                        }
                    case .failure(let err):
                        print(err)
                    }
                    self.updatePlaylist(containerTitle: containerTitle)
                }
            case 2:
                let elements = containerTitle.replacingOccurrences(of: " && ", with: "`").split(separator: "`")
                let reversedString: String = elements[1]+" && "+elements[0]
                let ref = UserController.shared.database.reference().child(reversedString).child("liked")
                self.fetchRelevantSongs(ref) { result in
                    switch result{
                    case .success(let data):
                        print("s")
                        var saveData = data
                        if data.keys.contains(song.id){
                            if saveData[song.id] != current.user.id{
                                self.updateMatched(id: song.id, containerTitle: containerTitle)
                            }
                        }else{
                            saveData[song.id] = current.user.id
                        }
                        self.saveRelevantSongs(ref, saveData: saveData) {
                            return completion(.success(song))
                        }
                    case .failure(let err):
                        print(err)
                        ref.setValue([song.id : current.user.id]) { err, _ in
                            if let err = err{
                                return completion(.failure(.genericErr(err)))
                            }else{
                                return completion(.success(song))
                            }
                        }
                    }
                }
                self.updatePlaylist(containerTitle: reversedString)
            default:
            print("no")
            }
        }
    }
    func updateMatched(id: String, containerTitle: String){
        userNum(containerTitle: containerTitle) { num in
            switch num{
            case 1:
                let dbRef = UserController.shared.database.reference().child(containerTitle).child("matched")
                dbRef.getData { err, snapshot in
                    if snapshot.exists(){
                        guard let val = snapshot.value as? [String] else {
                            return}
                        var newVal = val
                        newVal.append(id)
                        dbRef.setValue(newVal)
                    }else{
                        let elements = containerTitle.replacingOccurrences(of: " && ", with: "`").split(separator: "`")
                        let reversedString: String = elements[1]+" && "+elements[0]
                        let ref = UserController.shared.database.reference().child(reversedString).child("matched")
                        ref.getData { err, snapshot in
                            if snapshot.exists(){
                                guard let val = snapshot.value as? [String] else {
                                    return}
                                var newVal = val
                                newVal.append(id)
                                ref.setValue(newVal)
                            }else{
                                dbRef.setValue([id])
                            }
                        }
                    }
                }//
            case 2:
                let elements = containerTitle.replacingOccurrences(of: " && ", with: "`").split(separator: "`")
                let reversedString: String = elements[1]+" && "+elements[0]
                let dbRef = UserController.shared.database.reference().child(reversedString).child("matched")
                dbRef.getData { err, snapshot in
                    if snapshot.exists(){
                        guard let val = snapshot.value as? [String] else {
                            return}
                        var newVal = val
                        newVal.append(id)
                        dbRef.setValue(newVal)
                    }else{
                        let elements = containerTitle.replacingOccurrences(of: " && ", with: "`").split(separator: "`")
                        let reversedString: String = elements[1]+" && "+elements[0]
                        let ref = UserController.shared.database.reference().child(reversedString).child("matched")
                        ref.getData { err, snapshot in
                            if snapshot.exists(){
                                guard let val = snapshot.value as? [String] else {
                                    return}
                                var newVal = val
                                newVal.append(id)
                                ref.setValue(newVal)
                            }else{
                                dbRef.setValue([id])
                            }
                        }
                    }
                }
            case 0:
                let dbRef = UserController.shared.database.reference().child(containerTitle).child("matched")
                dbRef.getData { err, snapshot in
                    if snapshot.exists(){
                        guard let val = snapshot.value as? [String] else { return}
                        var newVal = val
                        newVal.append(id)
                        dbRef.setValue(newVal)
                    }else{
                        dbRef.setValue([id])
                    }
                }
            default:
                print("no")
            }
        }
    }
    func getMatchPlaylist(containerTitle: String, completion: @escaping(String)->Void){
        userNum(containerTitle: containerTitle) { num in
            switch num{
            case 1:
                let dbRef = UserController.shared.database.reference().child(containerTitle).child("playlist")
                dbRef.getData { err, snapshot in
                    if snapshot.exists(){
                        //return it
                        guard let val = snapshot.value as? String else { return}
                        return completion(val)
                    }else{
                        self.createPlaylist(containerTitle: containerTitle) { id in
                            dbRef.setValue(id) { err, _ in
                                if let err = err{
                                    print(err)
                                }else{
                                    return completion(id)
                                }
                            }
                        }
                        
                    }
                }
            case 2:
                let elements = containerTitle.replacingOccurrences(of: " && ", with: "`").split(separator: "`")
                let reversedString: String = elements[1]+" && "+elements[0]
                let dbRef = UserController.shared.database.reference().child(reversedString).child("playlist")
                dbRef.getData { err, snapshot in
                    if snapshot.exists(){
                        //return it
                        guard let val = snapshot.value as? String else { return}
                        return completion(val)
                    }else{
                        self.createPlaylist(containerTitle: containerTitle) { id in
                            dbRef.setValue(id)
                            return completion(id)
                        }
                        
                    }
                }
            default:
                print("no")
            }
        }
    }
    func addSongToPlaylist(song: SpotifySong, containerTitle: String){
        getMatchPlaylist(containerTitle: containerTitle) { id in
            //get the playlist's songs
            let urlString = Strings.playlistTrackGetPostURL.replacingOccurrences(of: "{playlist_id}", with: id)
            let url = URL(string: urlString)!
            var request = URLRequest(url: url)
            request.setValue("Bearer \(Strings.token!)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, response, err in
                if let err = err{
                    print(err)
                    return
                }
                guard let data = data else {
                    return}
                do{
                    let itemlist = try JSONDecoder().decode(SpotifyPlaylistTrackList.self, from: data)
                    var hit = false
                    for sonf in itemlist.items{
                        if sonf.track.id == song.id{
                            hit=true
                            break
                        }
                    }
                    if !(hit){
                        self.spottyPlaylistAdd(song: song, playlist_id: id)
                    }
                }catch{
                    return
                }
            }.resume()
        }
    }
    func addSongToPlaylist(songID: String, containerTitle: String){
        getMatchPlaylist(containerTitle: containerTitle) { id in
            //get the playlist's songs
            let urlString = Strings.playlistTrackGetPostURL.replacingOccurrences(of: "{playlist_id}", with: id)
            let url = URL(string: urlString)!
            var request = URLRequest(url: url)
            request.setValue("Bearer \(Strings.token!)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, response, err in
                if let err = err{
                    print(err)
                    return
                }
                guard let data = data else {
                    return}
                do{
                    let itemlist = try JSONDecoder().decode(SpotifyPlaylistTrackList.self, from: data)
                    var hit = false
                    for sonf in itemlist.items{
                        if sonf.track.id == songID{
                            hit=true
                            break
                        }
                    }
                    if !(hit){
                        self.spottyPlaylistAdd(songID: songID, playlist_id: id)
                    }
                }catch{
                    return
                }
            }.resume()
        }
    }
    func spottyPlaylistAdd(song: SpotifySong, playlist_id: String){
        guard let token = Strings.token else { return}
        var urlString = Strings.playlistTrackGetPostURL.replacingOccurrences(of: "{playlist_id}", with: playlist_id)
        urlString += "?uris=\(song.uri)"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { data, respo, err in
            print("ok")
            if let err = err{
                print(err)
                return
            }
        }.resume()
    }
    func spottyPlaylistAdd(songID: String, playlist_id: String){
        guard let token = Strings.token else { return}
        var urlString = Strings.playlistTrackGetPostURL.replacingOccurrences(of: "{playlist_id}", with: playlist_id)
        urlString += "?uris=spotify:track:\(songID)"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { data, respo, err in
            print("ok")
            if let err = err{
                print(err)
                return
            }
        }.resume()
    }
    func createPlaylist(containerTitle: String, completion: @escaping(String)->Void){
        let ids = containerTitle.replacingOccurrences(of: " && ", with: "`").split(separator: "`")
        UserController.shared.grabUser(id: String(ids[0])) { result in
            switch result{
            case .success(let user):
                let user1name = user.display_name
                UserController.shared.grabUser(id: String(ids[1])) { result in
                    switch result{
                    case .success(let user2):
                        let user2Name = user2.display_name
                        let playlistName = Strings.playlist_name_schema.replacingOccurrences(of: "USER1", with: user1name).replacingOccurrences(of: "USER2", with: user2Name)
                        let urlString = Strings.apiPlaylistGetPostURL.replacingOccurrences(of: "{user_id}", with: "\(user.id)")
                        let url = URL(string: urlString)!
                        var request = URLRequest(url: url)
                        request.setValue("Bearer \(Strings.token!)", forHTTPHeaderField: "Authorization")
                        request.httpMethod = "POST"
                        request.httpBody =  "{\"name\": \"\(playlistName)\",\"description\": \"Auto Generated via CommonGround\",\"public\": false,\"collaborative\":true}".data(using: .ascii)
                        URLSession.shared.dataTask(with: request) { data, resp, err in
                            if let _ = err{
                                return
                            }
                            let response = resp as? HTTPURLResponse
                            print(response!.statusCode)
                            guard let data = data else {
                                return}
                            do{
                                let playlist = try JSONDecoder().decode(SpotifyPlaylistListItem.self, from: data)
                                return completion(playlist.id)
                            }catch{
                                return
                            }
                            
                        }.resume()
                    case .failure(let err):
                        print(err)
                    }
                }
            case .failure(let err):
                print(err)
            }
        }
    }
    ///0-2. 0 is uninit you figure out the rest
    func userNum(containerTitle: String, completion: @escaping(Int)->Void){
        let dbRef = UserController.shared.database.reference().child(containerTitle)
        dbRef.getData { err, snapshot in
            if snapshot.exists(){
                return completion(1)
            }else{
                let elements = containerTitle.replacingOccurrences(of: " && ", with: "`").split(separator: "`")
                let reversedString: String = elements[1]+" && "+elements[0]
                let ref = UserController.shared.database.reference().child(reversedString)
                ref.getData { err, snapshot in
                    if snapshot.exists(){
                        return completion(2)
                    }else{
                        return completion(0)
                    }
                }
            }
        }
    }
    func dislikeSong(containerTitle: String, song: SpotifySong, completion: @escaping(Result<SpotifySong, SongError>)->Void){
        guard let current = UserController.shared.currentUser else { return completion(.failure(.noSuchUser))}
        userNum(containerTitle: containerTitle) { user in
            switch user{
            case 0:
                let dbRef = UserController.shared.database.reference().child(containerTitle).child("disliked")
                var data: [String: String] = [song.id : current.user.id]
                self.saveRelevantSongs(dbRef, saveData: data) {
                    return completion(.success(song))
                }
            case 1:
                let dbRef = UserController.shared.database.reference().child(containerTitle).child("disliked")
                self.fetchRelevantSongs(dbRef) { result in
                    switch result{
                    case .success(let data):
                        print("s")
                        var saveData = data
                        if data.keys.contains(song.id){
                            if saveData[song.id] != current.user.id{
                                //nothing i copied this from liked. dont judge me
                            }
                        }else{
                            saveData[song.id] = current.user.id
                        }
                        self.saveRelevantSongs(dbRef, saveData: saveData) {
                            return completion(.success(song))
                        }
                    case .failure(let err):
                        print(err)
                    }
                }
                self.updatePlaylist(containerTitle: containerTitle)
            case 2:
                let elements = containerTitle.replacingOccurrences(of: " && ", with: "`").split(separator: "`")
                let reversedString: String = elements[1]+" && "+elements[0]
                let ref = UserController.shared.database.reference().child(reversedString).child("disliked")
                self.fetchRelevantSongs(ref) { result in
                    switch result{
                    case .success(let data):
                        print("s")
                        var saveData = data
                        if data.keys.contains(song.id){
                            if saveData[song.id] != current.user.id{
                                self.updateMatched(id: song.id, containerTitle: containerTitle)
                            }
                        }else{
                            saveData[song.id] = current.user.id
                        }
                        self.saveRelevantSongs(ref, saveData: saveData) {
                            return completion(.success(song))
                        }
                    case .failure(let err):
                        print(err)
                        ref.setValue([song.id : current.user.id]) { err, _ in
                            if let err = err{
                                return completion(.failure(.genericErr(err)))
                            }else{
                                return completion(.success(song))
                            }
                        }
                        self.updatePlaylist(containerTitle: reversedString)
                    }
                }
            default:
            print("no")
            }
        }
    }
    func matchSong(song: SpotifySong, containerTitle: String){
        updateMatched(id: song.id, containerTitle: containerTitle)
        addSongToPlaylist(song: song, containerTitle: containerTitle)
    }
    func updatePlaylist(containerTitle: String){
        getAllMatchedSongs(containerTitle: containerTitle) { ids in
            for id in ids{
                self.addSongToPlaylist(songID: id, containerTitle: containerTitle)
            }
        }
    }
    func getAllMatchedSongs(containerTitle: String, completion: @escaping([String])->Void){
        let dbRef = UserController.shared.database.reference().child(containerTitle).child("matched")
        dbRef.getData { err, snap in
            if snap.exists(){
                guard let val = snap.value as? [String] else { return}
                return completion(val)
            }
        }
    }
}

