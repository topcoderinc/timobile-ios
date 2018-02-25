//
//  SplashContentViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 9/1/17.
//  Modified by TCCODER on 23/2/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * Splash content screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class SplashContentViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    
    /// model
    var itemIndex: Int = 0
    var imageName: String = ""
    var titleString: String = ""
    var contentText: String = ""
    
    // configure view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = titleString
        bgImageView.image = UIImage(named: imageName)
        textLabel.text = contentText
        textLabel.setLineHeight(20)
    }

}
