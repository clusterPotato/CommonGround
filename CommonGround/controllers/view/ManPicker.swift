//
//  NewHumanVC.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/1/21.
//

import UIKit
class ManPicker: UIViewController, UITableViewDataSource, UITableViewDelegate{
    //MARK: iboutlets
    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    private var observer: NSObjectProtocol?
    @IBOutlet weak var addIDField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            EndUserController.shared.testForCodeExist()
            UserController.shared.grabCurrentUser {
                print("configured")
                guard let user = UserController.shared.currentUser else { return}
                print(user.display_name)
                DispatchQueue.main.async {
                    self.namelabel.text = "Hi \(user.display_name)!"
                }
                UserController.shared.loadUsers(){
                    DispatchQueue.main.async{
                        tableView.reloadData()
                    }
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let url = Strings.openURLString{}else{getCodeForRedirect()}
        doSetup()
    }
    
    //MARK: obligatory data source junk
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserController.shared.savedUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") else {print("gg");return UITableViewCell()}
        cell.textLabel?.text = UserController.shared.savedUsers[indexPath.row].display_name
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cellToGame"{
            guard let destination = segue.destination as? SongSwipeViewController else { return}
            guard let indexPath = tableView.indexPathForSelectedRow else { return}
            destination.playingWithUser = UserController.shared.savedUsers[indexPath.row]
        }
    }
    
    //MARK: actions
    @IBAction func addButtonTapped(_ sender: Any) {
        print("add tapped")
        guard let text = addIDField.text, !(text == UserController.shared.currentUser?.display_name) else {
            DispatchQueue.main.async {
                self.addIDField.text = ""
                self.presentErrorToUser(localizedErrorString: "Stop trying to play with yourself. That's gross")
                self.addIDField.resignFirstResponder()
            }
            return
        }
        if text.isEmpty{
            return
        }
        UserController.shared.grabUser(id: text) { result in
            switch result{
            case .success(let user):
                DispatchQueue.main.async {
                    UserController.shared.addUser(user)
                    self.addIDField.text = ""
                    self.addIDField.resignFirstResponder()
                    self.tableView.reloadData()
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    print(err)
                    self.addIDField.text = ""
                    self.presentErrorToUser(localizedErrorString: "User Does Not Exist")
                    self.addIDField.resignFirstResponder()
                }

            }
        }
        
    }
    
    //MARK: funcs
    func doSetup(){
        tableView.dataSource = self
        tableView.delegate = self
        guard let user = UserController.shared.currentUser else { return}
        
    }
    
}
