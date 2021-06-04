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
    var currentUser: User?
    var savedUsers: [User] = []
    let database = Database.database()
    
    //MARK: firebase persistence
    func savePeople(){
        let dbRef = database.reference().child(currentUser?.display_name ?? "nil")
        //convert sot into a dictionary
        var dict : [String: [String: Any]] = [:]
        for i in Range(0...savedUsers.count-1){
            let person = savedUsers[i]
            print(savedUsers[i].toDictionnary)
            dict["\(person.display_name)"] = savedUsers[i].toDictionnary
        }
        dbRef.setValue(dict){
            error, _ in
            if let error = error{
                print(error)
                return
            }else{
                print("success saved")
            }
            
        }
    }
    func loadUsers(completion: @escaping()->Void){
        let dbRef = database.reference().child(currentUser?.display_name ?? "nil")
        dbRef.getData { err, snapshot in
            if let err = err{
                print("error",err)
                return
            }
            else if(snapshot.exists()){
                guard let thing = snapshot.value as? [String: Any] else { return}
                for element in thing{
                    guard let userData = element.value as? [String: String] else { return}
//                    let user = User(userData)
//                    self.savedUsers.append(user)
                    
                }
                completion()
            }
        }
    }
    
    
    //MARK: create/delete
    func addUser(_ p: User){
        savedUsers.append(p)
        savePeople()
    }
    func deleteUser(_ p: User){
        guard let index = savedUsers.firstIndex(of: p)else { return}
        savedUsers.remove(at: index)
        savePeople()
    }
    //MARK: encompassing function
    func grabUser(id: String, completion: @escaping(Result<User, SongError>)->Void){
        let url = URL(string: "https://api.spotify.com/v1/users/\(id)".replacingOccurrences(of: " ", with: ""))!
        var request = URLRequest(url: url)
        guard let token = Strings.token else { return}
        request.setValue("Bearer "+token, forHTTPHeaderField: "Authorization")
        print(request.allHTTPHeaderFields)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error{
                print(error)
                return completion(.failure(.cannotCompute))
            }
            print("response code \(response)")
            if let data = data{
                print(String(data: data, encoding: .utf8))
                do{
                    let newUser = try JSONDecoder().decode(User.self, from: data)
                    return completion(.success(newUser))
                }catch{
                    print("oops")
                    return completion(.failure(.cannotDecode))
                }
            }
        }.resume()
    }
    func grabCurrentUser(completion: @escaping()->Void){
        EndUserController.shared.getTokenFromCode { result in
            self.finishGrabbing {
                print("grabbing")
                completion()
            }
        }
    }
    func finishGrabbing(completion: @escaping()->Void){
        let url = URL(string: "https://api.spotify.com/v1/me")!
        var request = URLRequest(url: url)
        guard let token = Strings.token else { return}
        request.setValue("Bearer "+token, forHTTPHeaderField: "Authorization")
        print(request.allHTTPHeaderFields)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error{
                print(error)
                return
            }
            print("response code \(response)")
            if let data = data{
                print(String(data: data, encoding: .utf8))
                do{
                    try self.currentUser = JSONDecoder().decode(User.self, from: data)
                    return completion()
                }catch{
                    print("oops")
                }
            }
        }.resume()
    }
}
