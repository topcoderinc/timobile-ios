//
//  RoundedButton.swift
//  UIComponents
//
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * Rounded button
 *
 * - author: TCCODER
 * - version: 1.0
 */
@IBDesignable
open class RoundedButton: UIButton {

    /// normal state
    @IBInspectable open var borderActiveColor: UIColor = UIColor.darkSkyBlue {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// normal state
    @IBInspectable open var bgColor: UIColor = UIColor.darkSkyBlue {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// normal state
    @IBInspectable open var titleColor: UIColor = UIColor.white {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// make the view rounded
    @IBInspectable open var makeRound: Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// disabled state
    @IBInspectable open var disabledColor: UIColor = UIColor.white {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// disabled state
    @IBInspectable open var disabledBgColor: UIColor = UIColor.greyish {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    
    /// highligted state
    @IBInspectable open var highlightedColor: UIColor = UIColor.lightGray {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// highligted state
    @IBInspectable open var titleHighlightedColor: UIColor = UIColor.darkGray {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// awake from nib
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1
        
    }
    
    
    /// layout subviews
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderWidth = 1
        if makeRound {
            self.layer.cornerRadius = self.bounds.height / 2
        }
        self.layer.borderColor = isEnabled ? isHighlighted || isSelected ? highlightedColor.cgColor : borderActiveColor.cgColor : disabledColor.cgColor
        self.backgroundColor = isEnabled ? isHighlighted || isSelected ? highlightedColor : bgColor : disabledBgColor
        self.setTitleColor(titleColor, for: .normal)
        self.setTitleColor(disabledColor, for: .disabled)
    }
    
    /// highlighted state
    open override var isHighlighted: Bool {
        didSet {
            if !isSelected {
                self.backgroundColor = isHighlighted ? highlightedColor : bgColor
            }
            self.layer.borderColor = isHighlighted ? highlightedColor.cgColor : borderActiveColor.cgColor
        }
    }
    
    
    /// selected state
    open override var isSelected: Bool {
        didSet {
            self.tintColor = isSelected ? titleHighlightedColor : titleColor
            self.backgroundColor = isSelected ? highlightedColor : bgColor
            self.layer.borderColor = isSelected ? highlightedColor.cgColor : borderActiveColor.cgColor
        }
    }
    
}
