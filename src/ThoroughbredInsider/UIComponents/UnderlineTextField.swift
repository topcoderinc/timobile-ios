//
//  UnderlineTextField
//  Thoroughbred
//
//  Created by TCCODER on 30/10/17.
//  Copyright © 2017 topcoder. All rights reserved.
//

import UIKit

/**
 * Textfield with underline
 *
 * - author: TCCODER
 * - version: 1.0
 */
@IBDesignable
open class UnderlineTextField: UITextField {
    
    /// underline color
    @IBInspectable open var underlineColor: UIColor = UIColor.white.withAlphaComponent(0.3) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// active color
    @IBInspectable open var activeColor: UIColor = UIColor.white
    
    /// clear button image
    @IBInspectable open var clearImage: UIImage? = nil
    
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
    
    /// left text offset
    @IBInspectable open var customLeftTextOffset: CGFloat = -1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// awake from nib
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.placeholderColor = UIColor.gray
        self.autocorrectionType = .no
    }
    
    /// draw rect
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        if isFirstResponder {
            activeColor.setFill()
        } else
        {
            underlineColor.setFill()
        }
        ctx?.fill(CGRect(x: 0.0, y: rect.size.height - 0.5, width: rect.size.width, height: 0.5))
    }
    
    /// layout subviews
    open override func layoutSubviews() {
        super.layoutSubviews()
        // tint the clear button
        for subview: UIView in subviews {
            if let clearButton = subview as? UIButton,
                let image = clearImage {
                clearButton.setImage(image, for: .normal)
            }
        }
    }
    
    /// first responder become
    @discardableResult open override func becomeFirstResponder() -> Bool {
        self.setNeedsDisplay()
        return super.becomeFirstResponder()
    }
    
    
    /// first responder resign
    @discardableResult open override func resignFirstResponder() -> Bool {
        self.setNeedsDisplay()
        return super.resignFirstResponder()
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


