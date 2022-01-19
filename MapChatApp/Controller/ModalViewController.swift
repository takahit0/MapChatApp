//
//  ModalViewController.swift
//  MapChatApp
//
//

import UIKit

protocol ModalViewControllerDelegate: class {
    func joinChatRoomButtonTapped(_ vc:UIViewController)
}

@available(iOS 15.0, *)
class ModalViewController: UIViewController {
    
    @IBOutlet weak var chatRoomName: UILabel!
    @IBOutlet weak var chatRoomContents: UILabel!
    
    weak var delegate:ModalViewControllerDelegate?
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
        dismiss(animated: true, completion: nil)
        delegate?.joinChatRoomButtonTapped(chatVC)
    }
    
    


}
