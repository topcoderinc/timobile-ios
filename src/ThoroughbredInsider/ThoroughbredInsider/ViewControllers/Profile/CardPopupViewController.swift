//
//  CardPopupViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * card popup
 *
 * - author: TCCODER
 * - version: 1.0
 */
class CardPopupViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var congratsLabel: UILabel!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var relatedLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    /// card
    var card: Card!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = card.name
        congratsLabel.text = card.content
        if card.isEarned {
            cardImage.contentMode = .scaleAspectFill
            cardImage.load(url: card.image)
            shareButton.setTitle("SHARE".localized, for: .normal)
        }
        editButton.isEnabled = card.isEarned
    }

    /// bg button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func bgTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /// collect button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func collectTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
