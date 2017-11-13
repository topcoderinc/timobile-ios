//
//  RootViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Root controller for menu section
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        revertTransparentNavigationBar()
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "navIconMenu"), style: .plain, target: self, action: #selector(menuTapped))
    }

    /// menu button tap handler
    @objc func menuTapped() {
        slideMenuController?.toggleSideMenu()
    }
    
}
