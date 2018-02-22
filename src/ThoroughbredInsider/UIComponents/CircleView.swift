//
//  CircleView.swift
//  UIComponents
//
//  Created by TCCODER on 10/31/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * Circle view
 *
 * - author: TCCODER
 * - version: 1.0
 */
@IBDesignable class CircleView : UIView {
    
    /// the circle colors
    @IBInspectable var fillColor: UIColor  = UIColor.black
    
    /// the layer
    private var maskLayer: CAShapeLayer!
    
    /**
     Layout subviews
     */
    override func layoutSubviews() {
        maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        layer.mask = maskLayer
        layer.masksToBounds = true
    }
}

