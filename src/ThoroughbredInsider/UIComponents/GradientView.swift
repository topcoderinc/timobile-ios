//
//  GradientView.swift
//  Thoroughbred
//
//  Created by TCCODER on 6/21/17.
//  Modified by TCCODER on 2/23/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit


/**
 * top-to-bottom gradient view
 *
 * - author: TCCODER
 * - version: 1.0
 */
@IBDesignable
open class GradientView: UIView {

    /// layer class
    override open class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    /// layer
    var gradientLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }
    
    /// top color
    @IBInspectable open var topColor: UIColor? = nil {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// bottom color
    @IBInspectable open var bottomColor: UIColor? = nil {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// layout
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let colors = [topColor, bottomColor].flatMap { $0?.cgColor }
        gradientLayer.colors = colors
    }
    
    
}
