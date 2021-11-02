//
//  CustomLabel.swift
//  MapChatApp
//
//

import UIKit

class CustomLabel: UILabel {
    var topPadding: CGFloat = 3
    var bottomPadding: CGFloat = 3
    var leftPadding: CGFloat = 3
    var rightPadding: CGFloat = 3
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: UIEdgeInsets.init(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)))
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height += (topPadding + bottomPadding)
        size.width += (leftPadding + rightPadding)
        return size
    }
}
