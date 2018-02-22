//
//  ContainerViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 9/1/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * Container screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ContainerViewController: UIViewController {

    /// home menu
    var slideController: SlideMenuViewController?
    var menu: MenuViewController?
    
    /**
     view did load
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        menu = create(viewController: MenuViewController.self)
        let defaultVC = create(viewController: !UserDefaults.firstStoryLaunch ? PreStoryViewController.self : StoryViewController.self)!.wrappedInNavigationController
        slideController = SlideMenuViewController(
            leftSideController: menu!,
            defaultContent: defaultVC
        )
        loadChildController(slideController!, inContentView: self.view)
    }
    
    /**
     Loads popover view controller
     
     - parameter viewController: the popover view controller
     */
    func showViewControllerAsPopover(_ viewController: UIViewController) {
        loadChildController(viewController, inContentView: self.view)
    }

}
