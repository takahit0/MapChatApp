//
//  RegisterViewController.swift
//  MapChatApp
//
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import SwiftUI

class RegisterViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let db = Firestore.firestore()
    var imageString = String()
    var userID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let checkModel = CheckModel()
        checkModel.checkPermissions()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func tapProfileImage(_ sender: Any) {
        showAlert()
    }
    
    @available(iOS 15.0, *)
    @IBAction func determined(_ sender: Any) {
        if userNameTextField.text != "", mailAddressTextField.text != "", passwordTextField.text != "", profileImage.image != UIImage(named: "person") {
            //全ての項目にデータが入っていたらAuthにユーザー登録する
            Auth.auth().createUser(withEmail: mailAddressTextField.text!, password: passwordTextField.text!) { result, error in
                if error != nil {
                    print(error.debugDescription)
                }
            }
            let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
            chatVC.userName = userNameTextField.text!
            
            let data = profileImage.image?.jpegData(compressionQuality: 1.0)
            sendImage(data: data!)
            
            UserDefaults.standard.setValue("新規", forKey: "新規or登録済")
            InfoManager.shared.userName = userNameTextField.text!
            
            let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "mapVC") as! MapViewController
            mapVC.userName = userNameTextField.text!
            self.navigationController?.pushViewController(mapVC, animated: true)
        } else {
            let message = "全ての項目に入力してください。"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @available(iOS 15.0, *)
    func sendImage(data: Data) {
        let image = UIImage(data: data)
        let profileImageData = image?.jpegData(compressionQuality: 0.1)
        let imageRef = Storage.storage().reference().child("profileImage").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpg")
        
        imageRef.putData(profileImageData!, metadata: nil) { metadata, error in
            if error != nil {
                print(error.debugDescription)
                return
            }
            imageRef.downloadURL { url, error in
                if error != nil {
                    print(error.debugDescription)
                    return
                }
                let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "mapVC") as! MapViewController
                mapVC.imageString = url!.absoluteString
                InfoManager.shared.imageString = url!.absoluteString
                UserDefaults.standard.setValue(url!.absoluteString, forKey: self.userNameTextField.text!)
            }
        }
    }
    
    func doCamera() {
        let sourceType:UIImagePickerController.SourceType = .camera
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    func doAlbum() {
        let sourceType:UIImagePickerController.SourceType = .photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] as? UIImage != nil{
            let selectedImage = info[.originalImage] as! UIImage
            profileImage.image = selectedImage
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか？", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "カメラ", style: .default) { alert in
            self.doCamera()
        }
        let action2 = UIAlertAction(title: "アルバム", style: .default) { alert in
            self.doAlbum()
        }
        let action3 = UIAlertAction(title: "キャンセル", style: .cancel)
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        self.present(alertController, animated: true, completion: nil)
    }
}
