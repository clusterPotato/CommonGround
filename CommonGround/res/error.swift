//
//  error.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/2/21.
//


import UIKit
protocol ErrorDelegate: AnyObject{
    func presentErrorToUser(localizedError: LocalizedError)
    func showToast(message : String)
}

extension UIViewController: ErrorDelegate {
    func presentErrorToUser(localizedError: LocalizedError) {
        let alertController = UIAlertController(title: "ERROR", message: localizedError.errorDescription, preferredStyle: .actionSheet)
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
    func getCodeForRedirect(){
        UIApplication.shared.open(URL(string: Strings.spotifyApiAuthURL)!)
    }
    func presentErrorToUser(localizedErrorString: String) {
        let alertController = UIAlertController(title: "ERROR", message: localizedErrorString, preferredStyle: .actionSheet)
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
    func showToast(message : String) {
        let darkMode = (traitCollection.userInterfaceStyle == .dark)
        ////print(darkMode)
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/4 - 75, y: self.view.frame.size.height-100, width: self.view.frame.width*0.9, height: 35))
        toastLabel.backgroundColor = darkMode ? UIColor.white.withAlphaComponent(0.6) : UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.numberOfLines = 0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.text = ""
            toastLabel.removeFromSuperview()
        })
    }
}
enum SongError: LocalizedError{
    case cannotCompute
    case invalidInput
    case noOAuthCode
    case noToken
    case noSuchUser
    case notReadyToGoToWeb
    case noImageData
    case cannotDecode
    var errorDescription: String?{
        switch self{
        case .cannotCompute:
            return "Could not compute. Your calculations are too strong"
        case .invalidInput:
            return "You entered something bad"
        case .noOAuthCode:
            return "No oauth code"
        case .noToken:
            return "token not got"
        case .noSuchUser:
            return "no such user"
        case .cannotDecode:
            return "cannot decode"
        case .noImageData:
            return "no image data"
        case .notReadyToGoToWeb:
            return "Url is not formatted yet"
        }
    }
}

enum FireError: LocalizedError{
    case noGenres
    case noAuth
    case genericError(Error)
    case decodingError
    case couldNotSave
    case notInitializedUser
}
