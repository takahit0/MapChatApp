//
//  FriendMessageCell.swift
//  MapChatApp
//
//

import UIKit

class FriendMessageCell: UITableViewCell {
    
    @IBOutlet weak var friendUserName: UILabel!
    @IBOutlet weak var friendsMessageLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var friendTime: UILabel!
    
    var friendMessageText: String? {
        didSet {
            guard let text = friendMessageText else { return }
            friendsMessageLabel.text = text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        friendsMessageLabel.layer.cornerRadius = 10.0
        friendsMessageLabel.clipsToBounds = true
        friendImageView.layer.cornerRadius = 25.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    }
}

