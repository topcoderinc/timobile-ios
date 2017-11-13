//
//  CheckboxButton.swift
//  Thoroughbred
//
//  Created by TCCODER on 30/10/17.
//  Copyright © 2017 topcoder. All rights reserved.
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
