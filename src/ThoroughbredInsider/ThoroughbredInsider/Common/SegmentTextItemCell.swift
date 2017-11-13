//
//  SegmentTextItemCell.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 9/1/17.
//  Copyright © 2017 topcoder. All rights reserved.
//

import UIKit
import UIComponents

/**
 * Segment item cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class SegmentTextItemCell: UICollectionViewCell {

    
    /// colors
    let normalTextColor = UIColor.text
    let selectedTextColor = UIColor.darkSkyBlue
    
    /// highlighted
    override var isHighlighted: Bool {
        didSet {
            updateTextColor()
        }
    }
    
    /// selected
    override var isSelected: Bool {
        didSet {
            updateTextColor()
        }
    }
    
    /// outlets
    @IBOutlet weak var label: UILabel!
    
    
    /// update color
    private func updateTextColor() {
        label.textColor = (isHighlighted || isSelected) ? selectedTextColor : normalTextColor
    }
    
    
    /// awake from nib
    override func awakeFromNib() {
        super.awakeFromNib()
        updateTextColor()
    }
    
}
