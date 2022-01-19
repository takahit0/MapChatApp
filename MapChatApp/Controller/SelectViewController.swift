//
//  SelectViewController.swift
//  MapChatApp
//
//hatti@gmail.com,jyuusan@gmail.com

import UIKit

@available(iOS 15.0, *)
@available(iOS 15.0, *)
class SelectViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func register(_ sender: Any) {
        let registerVC = self.storyboard?.instantiateViewController(withIdentifier: "registerVC") as! RegisterViewController
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func login(_ sender: Any) {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
}

