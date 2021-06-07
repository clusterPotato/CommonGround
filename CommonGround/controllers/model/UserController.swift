//
//  UserGrab.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/1/21.
//

import Foundation
import Firebase

class UserController{
    let oauth = "BQB_L-lMYkFBGHIIUZYaYOLA0SuKlUc1OgRcOZaukZLkupGjJ6aOlb51QDc4wMhTCf9QAbLT9fnSAKjosnx-hOC6uHtuOSM_e5CJKAcVTvGPb9eIDs5gzWZKnZ-KerpcMJfhHrUX6PZhrhFlDOUMLrboE7WmLntIPXgNG7q7Hh9AiJ_rRdSnrTuiNAgg3k4p3Pis1U4T4opfehbntMxaUcsVIQ6GOIp-33cTt1U"
    //MARK: proprtys
    static let shared = UserController()
    var currentUser: UserData?
    var currentBlankUser: User?
    var currentUserGenreList:[String]?
    var savedUsers: [UserData] = []{didSet{
        delegate?.dataChanged()
        //print("data changed")
    }}
    weak var delegate: UserListChangedHandler?
    let database = Database.database()
    
    //MARK: user specific functions
    func savePeople(){
        let db = database.reference().child(currentUser?.user.display_name ?? "nil")
        let dbRef = db.child("previousUsers")
        //convert sot into a dictionary
        var dict : [String: [String: Any]] = [:]
        for i in Range(0...savedUsers.count-1){
            let person = savedUsers[i].user
            dict["\(person.display_name)"] = person.toDictionnary
        }
        dbRef.setValue(dict){
            error, _ in
            if let error = error{
                //print(error)
                return
            }else{
                //print("success saved")
            }
            
        }
    }
    func loadUsers(completion: @escaping()->Void){
        let db = database.reference().child(currentUser?.user.display_name ?? "nil")
        let dbRef = db.child("previousUsers")
        dbRef.getData { err, snapshot in
            if let err = err{
                //print("error",err)
                return
            }
            else if(snapshot.exists()){
                guard let value = snapshot.value as? [String: Any] else { return}
                for element in value{
                    guard let userFakeData = element.value as? [String: Any] else { return}
                    let user = User(userFakeData)
                    self.grabGenresForExternalUser(id: user.id){result in
                        switch result{
                        case .success(let genres):
                            let userdata = UserData(user: user, genres: genres)
                            self.savedUsers.append(userdata)
                        case .failure(_):
                            let userdata = UserData(user: user, genres: [])
                            self.savedUsers.append(userdata)
                        }
                    }
                }
                completion()
            }
        }
    }
    func addUser(_ id: String, completion: @escaping(Result<User, SongError>)->Void){
        grabUser(id: id) { result in
            switch result{
            case .success(let user):
                //self.savedUsers.append(user)
                self.grabGenresForExternalUser(id: user.id) { result in
                    switch result{
                    case .success(let genres):
                        let userdata = UserData(user: user, genres: genres)
                        self.savedUsers.append(userdata)
                    case .failure(_):
                        let userdata = UserData(user: user, genres: [])
                        self.savedUsers.append(userdata)
                    }
                }
                self.savePeople()
                return completion(.success(user))
            case .failure(let err):
                return completion(.failure(err))
            }
        }
    }
    func deleteUser(_ p: UserData){
        guard let index = savedUsers.firstIndex(of: p)else { return}
        savedUsers.remove(at: index)
        savePeople()
    }
    func grabUser(id: String, completion: @escaping(Result<User, SongError>)->Void){
        let url = URL(string: "https://api.spotify.com/v1/users/\(id)".replacingOccurrences(of: " ", with: ""))!
        var request = URLRequest(url: url)
        guard let token = Strings.token else { return}
        request.setValue("Bearer "+token, forHTTPHeaderField: "Authorization")
        //print(request.allHTTPHeaderFields)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error{
                return completion(.failure(.cannotCompute))
            }
            if let data = data{
                do{
                    let newUser = try JSONDecoder().decode(User.self, from: data)
                    return completion(.success(newUser))
                }catch{
                    return completion(.failure(.cannotDecode))
                }
            }
        }.resume()
    }
    func grabCurrentUser(completion: @escaping()->Void){
        EndUserController.shared.getTokenFromCode { result in
            self.finishGrabbing {
                self.grabGenresForSelf { result in
                    switch result{
                    case .success(_):
                        completion()
                    case .failure(let err):
                        print(err)
                    }
                }
            }
        }
    }
    func finishGrabbing(completion: @escaping()->Void){
        let url = URL(string: "https://api.spotify.com/v1/me")!
        var request = URLRequest(url: url)
        guard let token = Strings.token else { return}
        request.setValue("Bearer "+token, forHTTPHeaderField: "Authorization")
        //print(request.allHTTPHeaderFields)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error{
                print(error)
                return
            }
            if let respomse = response as? HTTPURLResponse{
                print(respomse.statusCode)
            }
            print("response code")
            if let data = data{
                print(String(data: data, encoding: .utf8))
                do{
                    self.currentBlankUser = try JSONDecoder().decode(User.self, from: data)
                    return completion()
                }catch{
                    print("oops")
                }
            }
        }.resume()
    }
    
    //MARK: genre function
    func grabMyGenresFromFireStore(completion: @escaping(Result<[String],FireError>)->Void){
        let db = database.reference().child(currentBlankUser?.display_name ?? "nil")
        let dbRef = db.child("genres")
        dbRef.getData { err, snapshot in
            if let err = err{
                return completion(.failure(.genericError(err)))
            }
            else if snapshot.exists(){
                guard let val = snapshot.value as? [String: [String]] else { return completion(.failure(.noGenres))}
                return completion(.success(val["genres"]!))
            }else{
                return completion(.failure(.noGenres))
            }
        }
    }
    func grabMyGenresFromAPI(completion: @escaping(Result<[String], FireError>)->Void){
        guard let token = Strings.token else { return completion(.failure(.noAuth))}
        let url = URL(string: Strings.genreSeedsURL)!
        var request = URLRequest(url: url)
        request.setValue("Bearer "+token, forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error{
                //print(error)
                return completion(.failure(.genericError(error)))
            }
            guard let data = data else { return completion(.failure(.noGenres))}
            do{
                let genreObject = try JSONDecoder().decode(ModelData.self, from: data)
                completion(.success(genreObject.genres))
            }catch{
                return completion(.failure(.decodingError))
            }
        }.resume()
    }
    func grabGenresForExternalUser(id: String, completion: @escaping(Result<[String], FireError>) ->Void){
        let db = database.reference().child(id)
        let dbRef = db.child("genres")
        dbRef.getData { error, snapshot in
            if let _ = error{
                return completion(.failure(.noGenres))
            }else if snapshot.exists(){
                guard let val = snapshot.value as? [String: [String]] else { return completion(.failure(.noGenres))}
                return completion(.success(val["genres"]!))
            }
            else{
                return completion(.failure(.noGenres))
            }
        }
    }
    func grabGenresForSelf(completion: @escaping(Result<[String], FireError>) ->Void){
        self.grabMyGenresFromAPI { result in
            switch result{
            case .success(let genres):
                if let user = self.currentBlankUser{
                    self.currentUser = UserData(user: user, genres: genres)
                }
                self.saveMyGenresToFireStore {result in
                    switch result{
                    case .failure(let err):
                        print(err)
                    case .success(_):
                        print("success")
                    }
                }
                self.currentUserGenreList = genres
                return completion(.success(genres))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }
    func saveMyGenresToFireStore(completion: @escaping(Result<[String], FireError>)->Void){
        guard let userData = currentUser else { return completion(.failure(.notInitializedUser))}
        let db = database.reference().child(currentUser?.user.display_name ?? "nil")
        let dbRef = db.child("genres")
        let dict: [String:[String]] = ["genres": userData.genres]
        dbRef.setValue(dict){
            error, _ in
            if let error = error{
                return completion(.failure(.genericError(error)))
            }
            else {return completion(.success(userData.genres))}
        }
    }
}
