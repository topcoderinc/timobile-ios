//
//  BadgePopupViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * Badge popup
 *
 * - author: TCCODER
 * - version: 1.0
 */
class BadgePopupViewController: UIViewController {

    /// outlets
    @IBOutlet weak var badgeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var congratsLabel: UILabel!
    
    /// the badge
    var badge: Badge!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = badge.name
        congratsLabel.text = badge.descr
        if !badge.isEarned {
            badgeImage.image = #imageLiteral(resourceName: "iconBadgeEmpty")
        }
    }

    /// collect button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func collectTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /// bg button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func bgTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
