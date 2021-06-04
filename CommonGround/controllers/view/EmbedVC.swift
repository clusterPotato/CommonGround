//
//  EmbedVC.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/3/21.
//

import UIKit
class EmbedViewController: UIViewController, EmbedDelegate{
    func changeInfo(song: SpotifySong) {
        titleLabel.text = song.name
        artistLabel.text = song.artists[0].name
        let left = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        left.direction = .left
        let right = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        right.direction = .right
        view.addGestureRecognizer(left)
        view.addGestureRecognizer(right)
        getImage(song: song) { result in
            switch result{
            case .success(let image):
                DispatchQueue.main.async {
                    self.albumView.image = image
                }
            case .failure(let err):
                self.presentErrorToUser(localizedError: err)
            }
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumView: UIImageView!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBAction func noButtonPressed(_ sender: Any) {
    }
    @IBAction func yesButtonPressed(_ sender: Any) {
    }
    @objc func swipedRight(){
        print("swipe right")
    }
    @objc func swipedLeft(){
        print("swipe left")
    }
    func getImage(song: SpotifySong, completion: @escaping(Result<UIImage, SongError>)->Void){
        let imageURL = song.album.images[0].url
        URLSession.shared.dataTask(with: URLRequest(url: imageURL)) { data, response, err in
            if let error = err{
                print(error)
                return completion(.failure(.cannotCompute))
            }
            guard let data = data else { return completion(.failure(.noImageData))}
            guard let image = UIImage(data: data) else { return completion(.failure(.noImageData))}
            return completion(.success(image))
        }.resume()
    }
    
}
