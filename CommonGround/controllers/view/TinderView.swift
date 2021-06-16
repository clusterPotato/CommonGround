//
//  TinderView.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/3/21.
//

import UIKit
import AVKit
protocol MatchDisplayDelegate: AnyObject{
    func matchWasMade()
    func likedButDidNotMatch()
}
class TinderViewController: UIViewController, MatchDisplayDelegate{
    func likedButDidNotMatch() {
        makeLikesHitstring {
            
        }
    }
    
    func matchWasMade() {
        makeMatchHitstring {
            
        }
    }
    
    //MARK: outlets
    
    
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var dislikedLabel: UILabel!
    @IBOutlet weak var likedLabel: UILabel!
    @IBOutlet weak var ImageButton: UIButton!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    var player: AVAudioPlayer?
    var genreList: [String]?
    var topSongs: [SpotifySong] = []
    var matching = false
    var topArtists:[SpotifyArtist] = []
    var currentlyDisplayedSong: SpotifySong?
    var containerTitle: String?
    var loading: LoadingViewController?
    
    //MARK: properties
    var otherUserData: UserData?
    var url: URL?
    var seedArtists: [String]=[]//the plan is to get top recent artist from u1, u2 for seeds, stored in form of id
    var seedSongs:[String]=[]//the plan is to add a random track out of user 1 top 50 and a random track out of user 2 top 50, use id
    //i would make a current user data but that would just be a weak reference to one that already exists in usercontroller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SongsController.shared.matchDelegate = self
        guard let currentUser = UserController.shared.currentUser,
              let matchedUser = otherUserData else { return}
        containerTitle = "\(currentUser.user.id) && \(matchedUser.user.id)"
        pictureView.layer.cornerRadius = 10
        self.sytlize()
        fillSeeds(){
            //print("seeds are \(self.seedArtists) : \(self.seedSongs)")
            self.url = self.constructURL()
            
            guard let title = self.containerTitle else { return}
            SongsController.shared.getQueuePosition(containerTitle: title, userID: currentUser.user.id) { pos in
                SongsController.shared.setQueuePosition(containerTitle: title, userID: currentUser.user.id, position: pos)
                SongsController.shared.getSongFromQueue(position: pos, userId: currentUser.user.id, containerTitle: title) { result in
                    switch result{
                    case .success(let song):
                        self.setDisplay(song)
                        SongsController.shared.setQueuePosition(containerTitle: title, userID: currentUser.user.id, position: pos+1)
                        self.addOneToQueue(){}
                    case .failure(_):
                        self.addOneToQueue(){
                            self.addOneToQueue(){SongsController.shared.getSongFromQueue(position: pos, userId: currentUser.user.id, containerTitle: title) { result in
                                switch result{
                                case .success(let song):
                                    self.setDisplay(song)
                                    SongsController.shared.setQueuePosition(containerTitle: title, userID: currentUser.user.id, position: pos + 1)
                                    self.addOneToQueue(){}
                                case .failure(let err):
                                    self.presentErrorToUser(localizedError: err)
                                }
                            }}
                        }
                    }
                }
            }
        }
    }
    func loadNextSong(completion: @escaping(SpotifySong)->Void){
        guard let title = containerTitle,
              let user = UserController.shared.currentUser else { return}
        SongsController.shared.getQueuePosition(containerTitle: title, userID: user.user.id) { pos in
            SongsController.shared.getSongFromQueue(position: pos, userId: user.user.id, containerTitle: title) { result in
                switch result{
                case .success(let song):
                    completion(song)
                case .failure(let err):
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
            if let _ = err{
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
            
            if let _ = error{
                self?.showToast(message: "No preview available for this song")
                return
            }
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
            }
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
        
    }
    func sytlize(){
        ImageButton.addTarget(self, action: #selector(playPreviewButtonPressed(_:)), for: .touchDownRepeat)
        let gestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(dislikeCurrentSong))
        gestureLeft.direction = .left
        let gestureRight = UISwipeGestureRecognizer(target: self, action: #selector(likeCurrentSong))
        gestureRight.direction = .right
        let gestureUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedImageUp))
        gestureUp.direction = .up
        container.addGestureRecognizer(gestureLeft)
        container.addGestureRecognizer(gestureUp)
        container.addGestureRecognizer(gestureRight)
        let artistHit = UITapGestureRecognizer(target: self, action: #selector(tappedArtist))
        artistLabel.addGestureRecognizer(artistHit)
        let songHit = UITapGestureRecognizer(target: self, action: #selector(swipedImageUp))
        titleLabel.addGestureRecognizer(songHit)
    }
    func setDisplay(_ song: SpotifySong){
        //all the data is there except album art
        //so we bring that boi in
        let urll = song.album.images[0].url
        URLSession.shared.dataTask(with: URLRequest(url: urll)) { data, response, error in
            if let error = error{
                print(error)
                return
            }
            guard let data = data else {
                return}
            let albumImage = UIImage(data: data) ?? UIImage(named: "music placeholder")
            DispatchQueue.main.async {
                self.pictureView.image = albumImage
                self.titleLabel.text = song.name
                self.artistLabel.text = song.artists[0].name
                self.currentlyDisplayedSong = song
            }
            self.currentlyDisplayedSong = song
        }.resume()
    }
    //MARK: actions
    @objc func swipedImageUp(){
        guard let currentSong = currentlyDisplayedSong else { return}
        UIApplication.shared.open(URL(string: "https://open.spotify.com/track/\(currentSong.id)")!)
    }
    @objc func tappedArtist(){
        guard let currentSong = currentlyDisplayedSong else { return}
        UIApplication.shared.open(URL(string: "https://open.spotify.com/artist/\(currentSong.artists[0].id)")!)
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        //back button was pressed
        dismiss(animated: true, completion: nil)
    }
    @IBAction func openButtonPressed(_ sender: Any) {
        guard let containerTitle = containerTitle else { return}
        SongsController.shared.userNum(containerTitle: containerTitle) { num in
            if num==1{
                SongsController.shared.getMatchPlaylist(containerTitle: containerTitle) { id in
                    DispatchQueue.main.async{
                        UIApplication.shared.open(URL(string: "https:open.spotify.com/playlist/\(id)")!)
                    }
                }
            }else if num==2{
                let elements = containerTitle.replacingOccurrences(of: " && ", with: "`").split(separator: "`")
                let reversedString: String = elements[1]+" && "+elements[0]
                SongsController.shared.getMatchPlaylist(containerTitle: reversedString) { id in
                    DispatchQueue.main.async{
                        UIApplication.shared.open(URL(string: "https:open.spotify.com/playlist/\(id)")!)
                    }
                }
            }
        }
    }
    @objc func heartButtonPressed(_ sender: Any) {
        likeCurrentSong()
    }
    @objc func xButtonPressed(_ sender: Any) {
        dislikeCurrentSong()
        
    }
    @objc func playPreviewButtonPressed(_ sender: Any) {
        playSongDemo()
    }
    @objc func dislikeCurrentSong(){
        guard let title = containerTitle,
              let song = currentlyDisplayedSong,
              let currentUser = UserController.shared.currentUser else {
            return}
        SongsController.shared.dislikeSong(containerTitle: title, song: song) { result in
            switch result{
            case .success(_):
                print("yee")
            case .failure(let err):
                DispatchQueue.main.async {
                    self.presentErrorToUser(localizedError: err)
                }
            }
        }
        addOneToQueue(){}
        makeDislikesHitstring{
            SongsController.shared.getQueuePosition(containerTitle: title, userID: currentUser.user.id) { pos in
                SongsController.shared.setQueuePosition(containerTitle: title, userID: currentUser.user.id, position: pos+1)
                self.loadNextSong{
                    song in
                    self.setDisplay(song)
                }
            }
            self.playerFinished()
        }
    }
    @objc func likeCurrentSong(){
        guard let title = containerTitle,
              let song = currentlyDisplayedSong,
              let currentUser = UserController.shared.currentUser else { return}
        SongsController.shared.likeSong(containerTitle: title, song: song) { result in
            switch result{
            case .success(_):
                print("yee")
            case .failure(let err):
                DispatchQueue.main.async {
                    self.presentErrorToUser(localizedError: err)
                }
            }
        }
        addOneToQueue(){}
        SongsController.shared.getQueuePosition(containerTitle: title, userID: currentUser.user.id) { pos in
            SongsController.shared.setQueuePosition(containerTitle: title, userID: currentUser.user.id, position: pos+1)
            
            self.loadNextSong{
                song in
                self.setDisplay(song)
            }
        }
        self.playerFinished()
        
        
    }
    @objc func playerFinished(){
        player?.stop()
        DispatchQueue.main.async{
            var image = UIImage(systemName: "play")!
            image = image.withRenderingMode(.alwaysOriginal)
        }
    }
    func makeLikesHitstring(completion: @escaping()->Void){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1) {
                self.likedLabel.alpha = 1
            } completion: { success in
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 1, animations: {
                        self.likedLabel.alpha = 0
                    }, completion: {
                        _ in
                        completion()
                    })
                }
            }
        }
        
    }
    func makeDislikesHitstring(completion: @escaping()->Void){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1) {
                self.dislikedLabel.alpha = 1
            } completion: { success in
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 1, animations: {
                        self.dislikedLabel.alpha = 0
                    }, completion: {
                        _ in
                        completion()
                    })
                }
            }
        }
        
    }
    func makeMatchHitstring(completion: @escaping()->Void){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1) {
                self.matchLabel.alpha = 1
            } completion: { success in
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 1, animations: {
                        self.matchLabel.alpha = 0
                    }, completion: {
                        _ in
                        completion()
                    })
                }
            }
        }
        
    }
    @objc func playSongDemo(){
        guard let url = currentlyDisplayedSong?.preview_url else {
            DispatchQueue.main.async {
                self.showToast(message: "No available preview for this song")
            }
            return}
        if let player = player{
            if player.isPlaying{
                player.stop()
                DispatchQueue.main.async{
                    var image = UIImage(systemName: "play")!
                    image = image.withRenderingMode(.alwaysOriginal)
                }
            }else{
                downloadFileFromURL(url: url)
            }
        }else{
            downloadFileFromURL(url: url)
        }
    }
    func addOneToQueue(completion: @escaping()->Void){
        getNewSeeds()
        self.url = constructURL()
        guard let title = containerTitle else { return}
        getSongReady { result in
            switch result{
            case .success(let song):
                SongsController.shared.addSongToQueue(song: song.id, title)
                completion()
            case .failure(let err):
                self.presentErrorToUser(localizedError: err)
            }
        }
    }
}
