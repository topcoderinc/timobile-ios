//
//  MenuTableViewCell.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Modified by TCCODER on 2/23/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * Side menu cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class MenuTableViewCell: UITableViewCell {
    
    /// menu
    var menu : Menu? {
        didSet {
            if let menu = menu {
                configure(menu)
            }
        }
    }
    
    /// outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var selectionView: UIView!

    /**
     Configure the cell
     
     - parameter menu: menu
     */
    func configure(_ menu: Menu) {
        nameLabel.text = menu.name
        iconImage.image = menu.icon
    }

}
