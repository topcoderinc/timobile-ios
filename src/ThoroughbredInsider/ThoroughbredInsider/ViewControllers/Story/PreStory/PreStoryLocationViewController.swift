//
//  PreStoryLocationViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * location services
 *
 * - author: TCCODER
 * - version: 1.0
 */
class PreStoryLocationViewController: UIViewController {

}

/**
 * Location Services info screen
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - changes related to fixing Location Services request
 */
extension PreStoryLocationViewController: PreStoryScreen {


    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.shared.allowedByUser = true // allow by default
    }

    /// left button
    var leftButton: String {
        return "Decline".localized
    }
    
    /// left button
    var leftButtonAction: ((PreStoryViewController) -> ())? {
        return { vc in
            LocationManager.shared.allowedByUser = false
            vc.finish()
        }
    }
    
    /// right button
    var rightButton: String {
        return "Allow".localized
    }
    
    /// right button
    var rightButtonAction: ((PreStoryViewController) -> ())? {
        return { vc in
            LocationManager.shared.allowedByUser = true
            LocationManager.shared.startUpdatingLocation()
            vc.next()
        }
    }
    
}
