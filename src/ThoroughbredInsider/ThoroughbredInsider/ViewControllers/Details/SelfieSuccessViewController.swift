//
//  SelfieSuccessViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Selfie success view
 *
 * - author: TCCODER
 * - version: 1.0
 */
class SelfieSuccessViewController: UIViewController {

    /// outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var congratsLabel: UILabel!
    @IBOutlet weak var overlayView: UIView!
    
    /// image
    var image: UIImage!
    
    /// continue handler
    var onContinue: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = image
    }

    /// collect button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func collectTapped(_ sender: Any) {
        onContinue?()
        dismiss(animated: true, completion: nil)
    }
}
