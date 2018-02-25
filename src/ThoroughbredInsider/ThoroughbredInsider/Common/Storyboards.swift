//
//  Storyboards.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Modified by TCCODER on 23/2/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * Describes available for instantiation storyboards
 *
 * - author: TCCODER
 * - version: 1.0
 */
enum Storyboards: String {

    /// storyboards
    case landing = "Splash"
    case login = "Login"
    case home = "Story"
    case details = "Details"
    case profile = "Profile"
    case shop = "Shop"
    case points = "Points"
    case help = "Help"
    
    /// instantiates the storyboard
    var instantiate: UIStoryboard {
        return UIStoryboard(name: rawValue, bundle: nil)
    }
    
    /// transition to home screen
    static func showHome() {
        guard let vc = Storyboards.home.instantiate.instantiateInitialViewController() else { return }
        vc.modalTransitionStyle = .flipHorizontal
        UIViewController.current?.present(vc, animated: true, completion: nil)
    }
    
}
