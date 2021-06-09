//
//  TinderView.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/3/21.
//

import UIKit
import AVKit
class TinderViewController: UIViewController{
    //MARK: outlets
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var xbutton: UIButton!
    @IBOutlet weak var heartbutton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    var player: AVAudioPlayer?
    var genreList: [String]?
    var topSongs: [SpotifySong] = []
    var topArtists:[SpotifyArtist] = []
    var currentlyDisplayedSong: SpotifySong?
    var queue:[SpotifySong] = []
    
    //MARK: properties
    var otherUserData: UserData?
    var url: URL?
    var seedArtists: [String]=[]//the plan is to get top recent artist from u1, u2 for seeds, stored in form of id
    var seedSongs:[String]=[]//the plan is to add a random track out of user 1 top 50 and a random track out of user 2 top 50, use id
    //i would make a current user data but that would just be a weak reference to one that already exists in usercontroller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillSeeds(){
            //print("seeds are \(self.seedArtists) : \(self.seedSongs)")
            self.url = self.constructURL()
            DispatchQueue.main.async {
                self.sytlize()
            }
            self.get2SongsReady__BEGINNING__()
        }
    }
    
    func get2SongsReady__BEGINNING__(){
        getSongReady { result in
            switch result{
            case .success(let song):
                self.queue.append(song)
                print("\(song.name) - \(song.artists)")
                self.fillSeeds {
                    self.getSongReady { result in
                        switch result{
                        case .success(let song):
                            self.queue.append(song)
                            print("\(song.name) - \(song.artists)")
                        case .failure(let err):
                            DispatchQueue.main.async {
                                self.presentErrorToUser(localizedError: err)
                            }
                        }
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    self.presentErrorToUser(localizedError: err)
                }
            }
        }
    }
    func getASeedGenre()->String{
        guard let genres = genreList else { return ""}
        guard let genre = genres.randomElement() else { return ""}
        return genre
    }
    func constructURL()->URL{
        var base = Strings.recommendationsURL
        base += "?seed_genres=\(getASeedGenre())&seed_artists=\(seedArtists[0]),\(seedArtists[1])&seed_tracks=\(seedSongs[0]),\(seedSongs[1])&limit=1"
        base = base.replacingOccurrences(of: " ", with: "%20")
        return URL(string: base)!
    }
    func getNewSeeds(){
        guard let song1 = topSongs.randomElement(),
              let song2 = topSongs.randomElement(),
              let artist1 = topArtists.randomElement(),
              let artist2 = topArtists.randomElement() else { return}
        seedSongs = [song1.id,song2.id]
        seedArtists = [artist1.id,artist2.id]
        self.url = constructURL()
    }
    func fillSeeds(completion: @escaping()->Void){
        guard let otherUserData = otherUserData else { return}
        UserController.shared.getArtistsFromDB(id: UserController.shared.currentUser!.user.id) { artists in
            guard let thingy = artists.randomElement() else { return}
            self.topArtists = artists
            self.seedArtists.append(thingy.id)
            UserController.shared.getArtistsFromDB(id: otherUserData.user.id) { artists in
                self.topArtists.append(contentsOf: artists)
                guard let thingy = artists.randomElement() else { return}
                self.seedArtists.append(thingy.id)
                UserController.shared.getSongsFromDB(id: UserController.shared.currentUser!.user.id) { songs in
                    self.topSongs = songs
                    guard let song = songs.randomElement() else { return}
                    self.seedSongs.append(song.id)
                    UserController.shared.getSongsFromDB(id: otherUserData.user.id) { songs in
                        self.topSongs.append(contentsOf: songs)
                        guard let song = songs.randomElement() else { return}
                        self.seedSongs.append(song.id)
                        completion()
                    }
                }
            }
        }
    }
    func getSongReady(completion: @escaping(Result<SpotifySong, SongError>)->Void){
        guard let url = url else {
            return completion(.failure(.notReadyToGoToWeb))}
        guard let token = Strings.token else {
            return completion(.failure(.noToken))}
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err{
                return completion(.failure(.notReadyToGoToWeb))
            }
            guard let data = data else {
                return completion(.failure(.notReadyToGoToWeb))}
            do{
                let song = try JSONDecoder().decode(TrackData.self, from: data)
                return completion(.success(song.tracks[0]))
            }catch{
                return completion(.failure(.cannotDecode))
            }
        }.resume()
    }
    func downloadFileFromURL(url:URL){

        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { [weak self](URL, response, error) -> Void in
            self?.play(url: URL!)
        })
            
        downloadTask.resume()
        
    }
    func play(url:URL) {
        print("playing \(url)")
        
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            guard let player = self.player else { return}
            NotificationCenter.default.addObserver(self, selector: #selector(playerFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
            DispatchQueue.main.async{
                var image = UIImage(systemName: "pause")!
                image = image.withRenderingMode(.alwaysOriginal)
                self.playButton.setImage(image, for: .normal)
            }
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
        
    }
    func sytlize(){
        playButton.setRadiusWithShadow(playButton.layer.bounds.height/2)
        xbutton.setRadiusWithShadow(xbutton.layer.bounds.height/2)
        heartbutton.setRadiusWithShadow(heartbutton.layer.bounds.height/2)
        let gestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(dislikeCurrentSong))
        gestureLeft.direction = .left
        let gestureRight = UISwipeGestureRecognizer(target: self, action: #selector(likeCurrentSong))
        gestureRight.direction = .right
        container.addGestureRecognizer(gestureLeft)
        container.addGestureRecognizer(gestureRight)
    }
    func setDisplay(_ song: SpotifySong){
        //all the data is there except album art
        //so we bring that boi in
        let url = song.album.images[0].url
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error{
                print(error)
                return
            }
            guard let data = data else { return}
            let albumImage = UIImage(data: data) ?? UIImage(named: "music placeholder")
            DispatchQueue.main.async {
                self.pictureView.image = albumImage
                self.titleLabel.text = song.name
                self.artistLabel.text = song.artists[0].name
                self.currentlyDisplayedSong = song
            }
        }.resume()
    }
    //MARK: actions
    @IBAction func backButtonPressed(_ sender: Any) {
        //back button was pressed
        dismiss(animated: true, completion: nil)
    }
    @IBAction func heartButtonPressed(_ sender: Any) {
        likeCurrentSong()
    }
    @IBAction func xButtonPressed(_ sender: Any) {
        dislikeCurrentSong()
        
    }
    @IBAction func playPreviewButtonPressed(_ sender: Any) {
        playSongDemo()
    }
    @objc func dislikeCurrentSong(){
        DispatchQueue.main.async {
            self.showToast(message: "disliked")
        }
        loadMoreSong()
        playerFinished()
    }
    @objc func likeCurrentSong(){
        DispatchQueue.main.async {
            self.showToast(message: "liked")
        }
        loadMoreSong()
        playerFinished()
    }
    @objc func playerFinished(){
        player?.stop()
        DispatchQueue.main.async{
            var image = UIImage(systemName: "play")!
            image = image.withRenderingMode(.alwaysOriginal)
            self.playButton.setImage(image, for: .normal)
        }
    }
    @objc func playSongDemo(){
        guard let url = currentlyDisplayedSong?.preview_url else { return}
        if let player = player{
            if player.isPlaying{
                player.stop()
                DispatchQueue.main.async{
                    var image = UIImage(systemName: "play")!
                    image = image.withRenderingMode(.alwaysOriginal)
                    self.playButton.setImage(image, for: .normal)
                }
            }else{
                downloadFileFromURL(url: url)
            }
        }else{
            downloadFileFromURL(url: url)
        }
    }
    func loadMoreSong(){
        if queue.count > 1{
            getNewSeeds()
            queue.remove(at: 0)
            setDisplay(queue[0])
            getSongReady { result in
                switch result{
                case .failure(let err):
                    DispatchQueue.main.async{
                        self.presentErrorToUser(localizedError: err)
                    }
                case .success(let song):
                    self.queue.append(song)
                
                }
            }
        }else{
            getNewSeeds()
            getSongReady { result in
                switch result{
                case .failure(let err):
                    DispatchQueue.main.async{
                        self.presentErrorToUser(localizedError: err)
                    }
                case .success(let song):
                    self.queue.append(song)
                
                }
            }
        }
    }
}
