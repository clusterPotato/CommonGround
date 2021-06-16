//
//  LoginVC.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/3/21.
//
import UIKit
class LoginVC: UIViewController{
    //MARK: outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    var loading: LoadingViewController?
    
    private var observer: NSObjectProtocol?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            EndUserController.shared.testForCodeExist()
            if let _ = Strings.openURLString{
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewController(identifier: "loading") as! LoadingViewController
                vc.modalPresentationStyle = .fullScreen
                self.loading = vc
                present(loading!, animated: true, completion: nil)
            }
            UserController.shared.grabCurrentUser {
                //print("configured")
                guard let user = UserController.shared.currentUser else {
                    return}
                DispatchQueue.main.async{
                    loading?.dismiss(animated: true, completion: nil)
                    showToast(message: "Welcome \(user.user.display_name)!")
                    UIView.animate(withDuration: 1) {
                        loginButton.isEnabled = false
                        loginButton.isUserInteractionEnabled = false
                        nextButton.backgroundColor = UIColor(named: "ButtonColor")
                    }
                }
                UserController.shared.loadUsers(){
                    
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNextButton()
    }
    //MARK: actions
    @IBAction func loginButtopnPressed(_ sender: Any) {
        if let _ = Strings.openURLString{}else{getCodeForRedirect()}
    }
    @IBAction func nextButtonPressed(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = sb.instantiateViewController(identifier: "Picker")
        nextVC.modalPresentationStyle = .fullScreen
        present(nextVC, animated: true) {
            print("pp®")
        }
    }
    //MARK: style
    func setupNextButton(){
        nextButton.layer.cornerRadius = 20
        nextButton.backgroundColor = UIColor(named: "grayedOut")
    }
}
