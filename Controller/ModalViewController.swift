//
//  ModalViewController.swift
//  MapChatApp
//
//

import UIKit

@available(iOS 15.0, *)
@available(iOS 15.0, *)
class ModalViewController: UIViewController {
    
    @IBOutlet weak var chatRoomName: UILabel!
    @IBOutlet weak var chatRoomContents: UILabel!
    
    var name = String()
    var contents = String()
    var userName = String()
    var imageString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatRoomName.text = name
        chatRoomContents.text = contents
    }
    
    @IBAction func joinChatRoom(_ sender: Any) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        chatVC.roomName = name
        chatVC.userName = userName
        chatVC.userImageString = imageString
        let transition = CATransition()
            transition.duration = 0.25
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            view.window!.layer.add(transition, forKey: kCATransition)
        present(chatVC, animated: false, completion: nil)
    }
    
    


}
