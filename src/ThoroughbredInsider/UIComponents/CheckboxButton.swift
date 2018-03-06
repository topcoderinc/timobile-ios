//
//  CheckboxButton.swift
//  Thoroughbred
//
//  Created by TCCODER on 30/10/17.
//  Modified by TCCODER on 2/23/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * checkbox
 *
 * - author: TCCODER
 * - version: 1.0
 */
class CheckboxButton: UIButton {

    /// init from nib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addTarget(self, action: #selector(CheckboxButton.tapHandler), for: .touchUpInside)
    }
    
    /**
     tap handler
     */
    @objc func tapHandler() {
        self.isSelected = !isSelected
    }
    
}
