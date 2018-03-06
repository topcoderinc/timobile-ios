//
//  SelfieSuccessViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/23/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * Selfie success view
 *
 * - author: TCCODER
 * - version: 1.1
 * 1.1:
 * - updates for integration
 */
class SelfieSuccessViewController: UIViewController {

    /// outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var congratsLabel: UILabel!
    @IBOutlet weak var overlayView: UIView!
    
    /// image
    var image: UIImage!
    
    /// details
    var details: StoryDetails!
    
    /// continue handler
    var onContinue: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = image
        let pts = details.additionalTask?.points ?? 0
        countLabel.text = "\(pts) pts"
        congratsLabel.text = "Wow! You have earned \(pts) pts by take a selfie\nin the location. Additional points have been\nadded automatically in your account.".localized
    }

    /// collect button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func collectTapped(_ sender: Any) {
        onContinue?()
        dismiss(animated: true, completion: nil)
    }
}
