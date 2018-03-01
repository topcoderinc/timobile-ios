//
//  SelfieSuccessViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Selfie success view
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - API integration
 */
class SelfieSuccessViewController: UIViewController {

    /// outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var congratsLabel: UILabel!
    @IBOutlet weak var overlayView: UIView!

    /// the related task
    var additionalTask: AdditionalTask!

    /// image
    var image: UIImage!
    
    /// continue handler
    var onContinue: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        countLabel.text = "\(additionalTask.points) pts"
        congratsLabel.text = "Wow! You have earned \(additionalTask.points) pts by taking a selfie in the location. Additional points have been added automatically in your account."
        imageView.image = image
        RestServiceApi.shared.completeAdditionalTask(progressId: additionalTask.progressId, callback: {}, failure: { error in
            self.countLabel.text = "N/A pts"
            self.congratsLabel.text = "Wow! You have earned \(self.additionalTask.points) pts by taking a selfie in the location. However, an error occured."
            self.createGeneralFailureCallback()(error)
        })
    }

    /// collect button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func collectTapped(_ sender: Any) {
        onContinue?()
        dismiss(animated: true, completion: nil)
    }
}
