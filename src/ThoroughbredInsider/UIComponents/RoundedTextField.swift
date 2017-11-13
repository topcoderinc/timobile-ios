//
//  RoundedTextField
//  Thoroughbred
//
//  Created by TCCODER on 30/10/17.
//  Copyright © 2017 topcoder. All rights reserved.
//

import UIKit

/**
 * Rounded border textfield
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
@IBDesignable
open class RoundedTextField: ErrorShowingTextField {
    
    /// optional icon
    @IBInspectable open var leftIcon: UIImage? = nil {
        didSet {
            if let leftIcon = leftIcon {
                self.leftView = UIImageView(image: leftIcon)
                self.leftViewMode = .always
            } else
            {
                self.leftViewMode = .never
            }
        }
    }


    /// optional icon
    @IBInspectable open var rightIcon: UIImage? = nil {
        didSet {
            if let rightIcon = rightIcon {
                self.rightView = UIImageView(image: rightIcon)
                self.rightViewMode = .always
            } else
            {
                self.rightViewMode = .never
            }
        }
    }
    
    /// round top corners
    @IBInspectable open var roundTop: Bool = false {
        didSet {
            if roundTop {
                roundCorners(corners: [.topLeft, .topRight], radius: 3)
            }
        }
    }
    
    /// round bottom corners
    @IBInspectable open var roundBottom: Bool = false {
        didSet {
            if roundBottom {
                roundCorners(corners: [.bottomLeft, .bottomRight], radius: 3)
            }
        }
    }
    
    /// left text offset
    @IBInspectable open var customLeftTextOffset: CGFloat = -1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    
    /**
     awake from nib
     */
    open override func awakeFromNib() {
        super.awakeFromNib()
        borderStyle = .none
        
        if let leftIcon = leftIcon {
            leftView = UIImageView(image: leftIcon)
            leftViewMode = .always
        }
        
        if let rightIcon = rightIcon {
            rightView = UIImageView(image: rightIcon)
            rightViewMode = .always
        }
        
    }
    
    /// text rect inset by image width
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return inset(rect: super.textRect(forBounds: bounds))
    }
    
    /// text editing rect inset by image width
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return inset(rect: super.editingRect(forBounds: bounds))
    }
    
    // MARK: - helpers
    
    /// insets rect with current image & extra line offset
    private func inset(rect: CGRect) -> CGRect {
        var rect = rect
        
        if customLeftTextOffset != -1 {
            rect.size.width += rect.origin.x
            rect.origin.x = customLeftTextOffset
            rect.size.width -= customLeftTextOffset
        } else if leftIcon == nil {
            rect.origin.x = 12
            rect.size.width -= 12
        }
        
        rect.origin.y += 1
        
        return rect
    }
    
}
