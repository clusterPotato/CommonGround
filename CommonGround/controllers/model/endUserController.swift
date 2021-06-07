//
//  endUserController.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/2/21.
//

import Foundation
class EndUserController{
    static let shared = EndUserController()
    var key: String?
    
    func getAuthCode(launchURL: String){
        let grabbedCode = launchURL.substring(from: launchURL.firstIndex(of: "?")!).replacingOccurrences(of: "?code=", with: "")
        Strings.oauthCode = grabbedCode
    }
    func getTokenFromCode(completion: @escaping (Result<String, SongError>)->Void){
        guard let code = Strings.oauthCode else { return completion(.failure(.noOAuthCode))}
        let url = URL(string: "\(Strings.herokuBase)?code=\(code)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(Strings.base64Secret)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, err in
            if let _ = err{
                //print(err)
                return completion(.failure(.cannotCompute))
            }
            if let data = data{
                do{
                    let token = try JSONDecoder().decode(Token.self, from: data)
                    return completion(.success(token.access_token))
                }catch{
                    completion(.failure(.cannotCompute))
                }
            }
        }.resume()
    }
    func testForCodeExist(){
        if let url = Strings.openURLString{
            if(url.contains("code")){
                EndUserController.shared.getAuthCode(launchURL: url)
                getTokenFromCode { result in
                    switch result{
                    case .success(let access ):
                        Strings.token = access
                        break
                    case .failure(let err):
                        print(err.localizedDescription)
                    }
                }
            }
        }
    }
}
struct Token: Decodable{
    let access_token: String
}
