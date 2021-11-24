//
//  ChatViewController.swift
//  MapChatApp
//
//

import UIKit
import Foundation
import Firebase
import FirebaseStorageUI

@available(iOS 15.0, *)
@available(iOS 15.0, *)
class ChatViewController: UIViewController {
    
    private lazy var inputTextView: InputTextView = {
        let view = InputTextView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 200)
        view.delegate = self
        view.sendButton.setTitle("", for: .normal)
        return view
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    var userName = String()
    var userImageString = String()
    var roomName = String()
    let db = Firestore.firestore()
    var messages: [Message] = []
    let screenSize = UIScreen.main.bounds.size
    var offset: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = roomName
        self.navigationController?.navigationBar.backgroundColor = .systemGray4
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height))
        let image = UIImage(named: "talkBackground")
        imageView.image = image
        imageView.alpha = 0.8
        self.tableView.backgroundView = imageView
        userName = InfoManager.shared.userName
        userImageString = InfoManager.shared.imageString
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.register(UINib(nibName: "FriendMessageCell", bundle: nil), forCellReuseIdentifier: "FriendCell")
        loadMessages(roomName: roomName)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: inputTextView)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: inputTextView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.object(forKey: "新規or登録済") as! String == "新規" {
            let userID = Auth.auth().currentUser?.uid
            db.collection(userID!).document().setData(["userName": userName, "imageString": userImageString])
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputTextView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification:Notification){
        let userInfo = notification.userInfo
        let keyboardSize = (userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        inputTextView.frame.origin.y = screenSize.height - keyboardSize.height - inputTextView.frame.height
        
        UIView.animate(withDuration: duration, animations: {
            self.tableView.contentInset.bottom = keyboardSize.height
        })
        scrollToRowLastCell(animated: true)
    }
    
    private func scrollToRowLastCell(animated: Bool) {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        guard numberOfRows > 0 else { return }
        let lastCellIndexPath = IndexPath(item: numberOfRows - 1, section: 0)
        tableView.scrollToRow(at: lastCellIndexPath, at: .bottom, animated: animated)
    }
    
    @objc func keyboardWillHide(_ notification:NSNotification){
        inputTextView.frame.origin.y = screenSize.height - inputTextView.frame.height
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = transform
        }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

@available(iOS 15.0, *)
extension ChatViewController: InputTextViewDelegate {
    func tappedSendButton(text: String) {
        if let senders = Auth.auth().currentUser?.email{
            db.collection(roomName).document().setData(["userName": userName,"ImageString": userImageString,"comment": text,"postDate": Date().timeIntervalSince1970,"sender": senders])
        }
        inputTextView.removeText()
        tableView.reloadData()
        inputTextView.chatTextView.resignFirstResponder()
    }
}

@available(iOS 15.0, *)
extension ChatViewController: UITableViewDelegate,UITableViewDataSource {
    func loadMessages(roomName: String) {
        db.collection(roomName).order(by: "postDate").addSnapshotListener { snapShot, error in
            self.messages = []
            if error != nil {
                print(error.debugDescription)
                return
            }
            if let snapShotDoc = snapShot?.documents {
                for doc in snapShotDoc {
                    let data = doc.data()
                    if let userName = data["userName"] as? String, let imageString = data["ImageString"] as? String, let comment = data["comment"] as? String, let postDate = data["postDate"] as? Double, let sender = data["sender"] as? String {
                        let newMessage = Message(userName: userName, imageString: imageString, comment: comment, postDate: postDate, sender: sender)
                        self.messages.append(newMessage)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let maxSize = CGSize(width: self.view.frame.width - 100, height: CGFloat.greatestFiniteMagnitude)
        if messages != [] {
            let userInfo = messages[indexPath.row]
            if userInfo.sender == Auth.auth().currentUser?.email{
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MessageCell
                cell.myUserName.text = userInfo.userName
                cell.messageText = userInfo.comment
                cell.myTime.text = loadDate(postDate: userInfo.postDate)
                cell.backgroundColor = UIColor.clear
                cell.contentView.backgroundColor = UIColor.clear
                if userInfo.imageString.isEmpty {
                    cell.myImageView.image = UIImage(named: "osaka")
                } else {
                    let ref = Storage.storage().reference(forURL: userInfo.imageString)
                    cell.myImageView.sd_setImage(with: ref)
                }
                return cell
                
            }else{
                let friendCell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendMessageCell
                friendCell.friendUserName.text = userInfo.userName
                friendCell.friendMessageText = userInfo.comment
                friendCell.friendTime.text = loadDate(postDate: userInfo.postDate)
                friendCell.backgroundColor = UIColor.clear
                friendCell.contentView.backgroundColor = UIColor.clear
                if userInfo.imageString.isEmpty {
                    friendCell.friendImageView.image = UIImage(named: "osaka")
                } else {
                    let ref = Storage.storage().reference(forURL: userInfo.imageString)
                    friendCell.friendImageView.sd_setImage(with: ref)
                }
                return friendCell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MessageCell
        return cell
    }
    
    func loadDate(postDate: Double) -> String {
        let date = Date(timeIntervalSince1970: postDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        let dateString = formatter.string(from: date)
        return dateString
    }
}
