//
//  PreStoryLocationViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//  Modified by TCCODER on 23/2/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * location services
 *
 * - author: TCCODER
 * - version: 1.1
 * 1.1:
 * - updates for integration
 */
class PreStoryLocationViewController: UIViewController {

}

// MARK: - PreStoryScreen
extension PreStoryLocationViewController: PreStoryScreen {
    
    /// left button
    var leftButton: String {
        return "Decline".localized
    }
    
    /// left button
    var leftButtonAction: ((PreStoryViewController) -> ())? {
        return { vc in
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
            LocationManager.shared.startUpdatingLocation()
            vc.next()
        }
    }
    
}
