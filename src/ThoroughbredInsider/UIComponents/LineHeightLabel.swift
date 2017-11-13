//
//  LineHeightLabel.swift
//  UIComponents
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Label extension
 *
 * - author: TCCODER
 * - version: 1.0
 */
@IBDesignable
open class LineHeightLabel: UILabel {

    /// line height
    @IBInspectable open var lineHeight: CGFloat = 0
    
    /// text
    open override var text: String? {
        didSet {
            guard lineHeight > 0 else { return }
            let paragrahStyle = NSMutableParagraphStyle()
            paragrahStyle.minimumLineHeight = lineHeight
            paragrahStyle.alignment = textAlignment
            paragrahStyle.hyphenationFactor = 1
            let attributedString = NSMutableAttributedString(string: text ?? "", attributes: [
                NSAttributedStringKey.paragraphStyle: paragrahStyle,
                NSAttributedStringKey.foregroundColor: textColor,
                NSAttributedStringKey.font: UIFont(name: font.fontName, size: font.pointSize)!
                ])
            attributedText = attributedString
        }        
    }

}
