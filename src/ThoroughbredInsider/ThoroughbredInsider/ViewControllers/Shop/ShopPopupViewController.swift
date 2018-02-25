//
//  ShopPopupViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/23/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * Shop popup
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ShopPopupViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var congratsLabel: UILabel!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var ptsLabel: UILabel!
    
    /// card
    var card: Card!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        titleLabel.text = card.name
        congratsLabel.text = card.descr
        cardImage.contentMode = .scaleAspectFill
        cardImage.load(url: card.imageURL)
        ptsLabel.text = "\(card.pts) pts"
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
        showStub()
    }

}
