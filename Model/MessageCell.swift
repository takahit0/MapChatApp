//
//  MessageCell.swift
//  MapChatApp
//
//

import UIKit
import Foundation

class MessageCell: UITableViewCell {

    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myUserName: UILabel!
    @IBOutlet weak var myTime: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    var messageText: String? {
        didSet {
            guard let text = messageText else { return }
            messageLabel.text = text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.layer.cornerRadius = 10.0
        messageLabel.clipsToBounds = true
        myImageView.layer.cornerRadius = 25.0
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

