//
//  SplashContainerViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 9/1/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import UIComponents

/**
 * Splash screen container
 *
 * - author: TCCODER
 * - version: 1.0
 */
class SplashContainerViewController: UIViewController, StaticPagingContentProvider {
    
    
    /// page controller
    private var pageViewController: UIPageViewController?
    
    /// screens data
    private var screens:[SplashScreen]!
    
    /// outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: PagerControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screens = SplashScreen.getPredefinedData()
        createPageViewController()
    }
    
    /// View will appear
    ///
    /// - Parameter animated: the animation flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        makeTransparentNavigationBar()
    }
    
    /// inits the page controller
    private func createPageViewController() {
        pageControl.count = screens.count
        
        guard let pageController = create(viewController: PagingController.self) else { return }
        pageViewController = pageController
        pageController.contentProvider = self
        pageController.contentDelegate = self
        loadChildController(pageController, inContentView: containerView)
    }
    
    /// StaticPagingContentProvider
    var pagedContentFactory: [() -> UIViewController] {
        return screens.enumerated().map { itemIndex, screen in
            let pageItemController = create(viewController: SplashContentViewController.self)!
            pageItemController.itemIndex = itemIndex
            pageItemController.imageName = screen.imageName
            pageItemController.titleString = screen.title
            pageItemController.contentText = screen.contentText
            return { pageItemController }
        }
    }
    
}

// MARK: - PagingControllerDelegate
extension SplashContainerViewController: PagingControllerDelegate {
    
    func pagingController(_ pagingController: PagingController, didTransitionTo viewController: UIViewController, atIndex index: Int) {
        pageControl?.selected = index
    }
    
    func pagingController(_ pagingController: PagingController, didUpdateOffset offset: CGFloat) {
    }
}
