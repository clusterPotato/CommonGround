//
//  UserPickVC.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/3/21.
//

import UIKit
class UserPickVC: UIViewController{
    //MARK: outlets
    @IBOutlet weak var recentUsersCollectionView: UICollectionView!
    @IBOutlet weak var labelStak: UIStackView!
    @IBOutlet weak var user_nameLabel: UILabel!
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var addAlert: UIView!
    @IBOutlet weak var addUserLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var add_helpButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var viewGenresButton: UIButton!
    
    //MARK: junk
    var width: CGFloat = 0.0
    var observer: NSObjectProtocol?
    var numberOfGenresToDisplay = 3
    var selectedCellUserdata: UserData?
    var previouslySelectedCell: UserCell?
    let iphone11Height: CGFloat = 1792
    var height: CGFloat = 0.0
    let iphone11Width: CGFloat = 828
    
    //MARK: vdl
    override func viewDidLoad() {
        observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            print("fg")
            self.recentUsersCollectionView.reloadData()
        }
        numberOfGenresToDisplay -= 1
        UserController.shared.delegate = self
        super.viewDidLoad()
        height = view.bounds.height
        width = view.bounds.width
        recentUsersCollectionView.delegate = self
        recentUsersCollectionView.dataSource = self
        loadUp()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func presentAddUserVC(){
        UIView.animate(withDuration: 0.5) {
            self.view.addSubview(self.addAlert)
            self.constrainAddView()
        }
        
    }
    func loadUp(){
        stylizeViews()
    }
    @objc func removeAddAlert(){
        addAlert.removeFromSuperview()
    }
    @objc func helpPressed(){
        let alertVC = UIAlertController(title: "Hep", message: "To partner with somebody, you must have their Spotify ID and they must have yours. You can share it via the share button in the top right", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }
    func constrainAddView(){
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(removeAddAlert))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        add_helpButton.addTarget(self, action: #selector(helpPressed), for: .touchUpInside)
        addAlert.anchor(top: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, paddingTop: 0, paddingBottom: 0, paddingLeading: 0, paddingtrailing: 0, width: nil, height: 256)
        usernameField.delegate = self
        plusButton.addTarget(self, action: #selector(addUser), for: .touchUpInside)
        addUserLabel.anchor(top: addAlert.topAnchor, bottom: nil, leading: addAlert.leadingAnchor, trailing: addAlert.trailingAnchor, paddingTop: 8, paddingBottom: 0, paddingLeading: 8, paddingtrailing: 8, width: nil, height: nil)
        add_helpButton.anchor(top: addUserLabel.bottomAnchor, bottom: nil, leading: nil, trailing: addAlert.trailingAnchor, paddingTop: 0, paddingBottom: 0, paddingLeading: 0, paddingtrailing: 16, width: 48, height: 48)
        usernameField.anchor(top: add_helpButton.topAnchor, bottom: add_helpButton.bottomAnchor, leading: addAlert.leadingAnchor, trailing: add_helpButton.leadingAnchor, paddingTop: 0, paddingBottom: 0, paddingLeading: 16, paddingtrailing: 72, width: nil, height: nil)
        plusButton.anchor(top: nil, bottom: addAlert.bottomAnchor, leading: addAlert.leadingAnchor, trailing: addAlert.trailingAnchor, paddingTop: 0, paddingBottom: 0, paddingLeading: 72, paddingtrailing: 72, width: nil, height: nil)
        plusButton.layer.cornerRadius = 20
        plusButton.backgroundColor = UIColor(named: "ButtonColor")
    }
    @IBAction func viewGenresPressed(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = sb.instantiateViewController(identifier: "GenreInfo") as? GenreViewController else { return}
        guard let userdata = self.selectedCellUserdata else { return}
        vc.userData = userdata
        guard let currentUserdata = UserController.shared.currentUser else { return}
        vc.currentUserData = currentUserdata
        present(vc, animated: true, completion: nil)
        
    }
    @IBAction func proceedButtonPressed(_ sender: Any) {
        if viewGenresButton.isEnabled{
            //proceed
            let sb = UIStoryboard(name: "Main", bundle: nil)
            guard let currentUser = UserController.shared.currentUser,
                  let cellUser = selectedCellUserdata else { return}
            guard let vc = sb.instantiateViewController(identifier: "TinderSwipey") as? TinderViewController else { return}
            vc.modalPresentationStyle = .fullScreen
            vc.otherUserData = selectedCellUserdata
            vc.genreList = giveCommonGenres(user1: currentUser, user2: cellUser)
            present(vc, animated: true, completion: nil)
        }else{
            //do not proceed until user selects a valid user
        }
    }
    @IBAction func copyButtonPressed(_ sender: Any) {
        guard let currentUser = UserController.shared.currentUser else { return}
        let shareText = "Add me on CommonGround using my Spotify ID: \(currentUser.user.id)"
        let activitiesVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activitiesVC, animated: true, completion: nil)
    }
    @objc func addUser(){
        guard let id = usernameField.text, !id.isEmpty else { return}
        UserController.shared.addUser(id) { result in
            switch result{
            case .failure(let err):
                DispatchQueue.main.async {
                    self.presentErrorToUser(localizedError: err)
                }
            case .success( _ ):
                DispatchQueue.main.async {
                    self.addAlert.removeFromSuperview()
                }
                DispatchQueue.main.async {
                    self.recentUsersCollectionView.reloadData()
                }
            }
        }
    }
}
extension UserPickVC: UICollectionViewDelegate, UICollectionViewDataSource, UserCellDelegate, AddManCellDelegate, UICollectionViewDelegateFlowLayout{
    func deleted() {
        self.recentUsersCollectionView.reloadData()
    }
    
    func addButtonPressed() {
        presentAddUserVC()
    }
    func cellButtonPressed(sender: UserCell) {
        guard let userdata = sender.userdata else { return}
        pickedImageView.image = sender.pictureView.image
        user_nameLabel.text = userdata.user.display_name
        
        user_nameLabel.textColor = UIColor(named:"TextColor")
        if !(userdata.genres.isEmpty){
            viewGenresButton.isEnabled = true
            viewGenresButton.backgroundColor = UIColor(named: "ButtonColor")
        }else{
            viewGenresButton.isEnabled = false
            viewGenresButton.backgroundColor = UIColor(named: "grayedOut")
        }
        viewGenresButton.setTitleColor(.black, for: .normal)
        selectedCellUserdata = userdata
        viewGenresButton.layer.cornerRadius = viewGenresButton.layer.bounds.height/2
        UIView.animate(withDuration: 2) {
            sender.layer.borderWidth = 2
        }
        if let cell = self.previouslySelectedCell{
            cell.layer.borderWidth=0
        }
       
        self.previouslySelectedCell=sender
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return UserController.shared.savedUsers.count
        }else {return 1}
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section==0{
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "manCell", for: indexPath) as? UserCell{
                cell.delegate = self
                cell.button.addTarget(cell.self, action: #selector(cell.setInDeleteMode), for: .touchDownRepeat)
                cell.layer.cornerRadius = 20
                cell.layer.borderColor = UIColor(named: "TextColor")?.cgColor
                cell.userdata = UserController.shared.savedUsers[indexPath.row]
                cell.load()
                cell.indexPath = indexPath
                return cell
            }else{
                return UICollectionViewCell()
            }
        }else if indexPath.section==1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdditionalCell", for: indexPath) as? AddManCell else { return UICollectionViewCell()}
            cell.layer.cornerRadius = 20
            cell.delegate = self
            return cell
        }else {return UICollectionViewCell()}
    }
    func stylizeViews(){
        startButton.layer.cornerRadius = 20
        pickedImageView.layer.cornerRadius = 20
        startButton.backgroundColor = UIColor(named: "ButtonColor")
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 96, height: 96)
    }
}
extension UserPickVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension UserPickVC{
    //MARK: extra functions that i dont want the clutter of
    func giveCommonGenres(user1: UserData, user2: UserData)->[String]{
        var commons: [String] = []
        for genre in user1.genres{
            if (user2.genres.contains(genre))&&(!(commons.contains(genre))){
                commons.append(genre)
            }
        }
        for genre in user2.genres{
            if (user1.genres.contains(genre))&&(!(commons.contains(genre))){
                commons.append(genre)
            }
        }
        return commons
    }
}
