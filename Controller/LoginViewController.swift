//
//  LoginViewController.swift
//  MapChatApp
//
//

import UIKit
import Firebase
import FirebaseAuth

@available(iOS 15.0, *)
class LoginViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let db = Firestore.firestore()
    var userName = String()
    var imageString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let checkModel = CheckModel()
        checkModel.checkPermissions()
    }
    
    @IBAction func determined(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "新規or登録済")
        UserDefaults.standard.setValue("登録済", forKey: "新規or登録済")
        
        let email = mailAddressTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let user = result?.user {
                self.db.collection(user.uid).addSnapshotListener { snapShot, error in
                    if error != nil {
                        print(error.debugDescription)
                    }
                    if let snapShotDoc = snapShot?.documents {
                        let data = snapShotDoc[0].data()
                        if let userName = data["userName"] as? String, let imageString = data["imageString"] as? String {
                            DispatchQueue.main.async {
                                self.userName = userName
                                self.imageString = imageString
                                InfoManager.shared.userName = userName
                                InfoManager.shared.imageString = imageString
                            }
                        }
                    }
                }
                let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "mapVC") as! MapViewController
                self.navigationController?.pushViewController(mapVC, animated: true)
            }
            self.showError(error)
        }
    }
    
    func errorMessage(of error: Error) -> String {
        var message = "エラーが発生しました"
        guard let errcd = AuthErrorCode(rawValue: (error as NSError).code) else {
            return message
        }
        switch errcd {
        case .userNotFound: message = "ユーザーが見つかりません"
        case .wrongPassword: message = "パスワードが間違っています"
        case .invalidEmail: message = "不正なメールアドレスです"
        case .emailAlreadyInUse: message = "このメールアドレスは既に使われています"
        case .weakPassword: message = "パスワードが脆弱すぎます"
        default: break
        }
        return message
    }
    
    func showError(_ errorOrNil: Error?) {
        guard let error = errorOrNil else { return }
        let message = errorMessage(of: error)
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

