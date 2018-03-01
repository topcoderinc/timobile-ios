//
//  PreStoryViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import UIComponents

/**
 * pre-stroy screen protocol
 *
 * - author: TCCODER
 * - version: 1.0
 */
protocol PreStoryScreen {
    
    /// fields
    var leftButton: String { get }
    var leftButtonAction: ((PreStoryViewController)->())? { get }
    var rightButton: String { get }
    var rightButtonAction: ((PreStoryViewController)->())? { get }
}

/**
 * pre-story container
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - bug fixed - selected state and racetracks are saved now
 */
class PreStoryViewController: RootViewController, StaticPagingContentProvider {

    /// page controller
    private var pageViewController: PagingController?
    
    /// outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: PagerControl!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    /// the selected states
    private var selectedStates: [State]?

    /// the reference to last page
    private var lastPage: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createPageViewController()
    }
    
    /// inits the page controller
    private func createPageViewController() {
        pageControl.count = 3
        
        guard let pageController = create(viewController: PagingController.self) else { return }
        pageViewController = pageController
        pageViewController?.configure = { vc in
            (vc as? PreStoryStateViewController)?.selected = self.selectedStates != nil ? Set<State>(self.selectedStates!) : Set<State>()
            (vc as? PreStoryRacetrackViewController)?.states = self.selectedStates
            if let _ = self.lastPage as? PreStoryLocationViewController, let _ = vc as? PreStoryStateViewController {
                LocationManager.shared.allowedByUser = true
                LocationManager.shared.startUpdatingLocation()
            }
            self.lastPage = vc
        }
        pageController.contentProvider = self
        pageController.contentDelegate = self
        loadChildController(pageController, inContentView: containerView)
    }
    
    /// StaticPagingContentProvider
    var pagedContentFactory: [() -> UIViewController] {
        return [
            { return self.create(viewController: PreStoryLocationViewController.self)! },
            { return self.create(viewController: PreStoryStateViewController.self)! },
            { return self.create(viewController: PreStoryRacetrackViewController.self)! }
        ]
    }
    
    /// finish or skip
    ///
    /// - Parameter selectedObjects: the selected objects on previous step
    func finish(selectedObjects: Any? = nil) {
        UserDefaults.firstStoryLaunch = true
        guard let vc = create(viewController: StoryViewController.self) else { return }
        if let racetrack = (selectedObjects as? [Racetrack])?.first {
            vc.racetracks = [racetrack]
        }
        slideMenuController?.setContentViewController(vc)
    }
    
    /// go next
    func back() {
        if let index = pageViewController?.currentIndex, index > 0 {
            pageViewController?.setSelectedPageIndex(index-1)
        }
    }

    /// go next
    ///
    /// - Parameter selectedObjects: the selected objects on previous step
    func next(selectedObjects: Any? = nil) {
        self.selectedStates = selectedObjects as? [State]
        if let index = pageViewController?.currentIndex, index < pageControl.count-1 {
            pageViewController?.setSelectedPageIndex(index+1)
        }
    }
    
    /// left button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func leftTapped(_ sender: Any) {
        guard let vc = pageViewController?.currentViewController as? PreStoryScreen else { return }
        vc.leftButtonAction?(self)
    }
    
    /// right button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func rightTapped(_ sender: Any) {
        guard let vc = pageViewController?.currentViewController as? PreStoryScreen else { return }
        vc.rightButtonAction?(self)
    }
    
}

// MARK: - PagingControllerDelegate
extension PreStoryViewController: PagingControllerDelegate {
    
    func pagingController(_ pagingController: PagingController, didTransitionTo viewController: UIViewController, atIndex index: Int) {
        pageControl?.selected = index
        guard let vc = viewController as? PreStoryScreen else { return }
        leftButton.setTitle(vc.leftButton, for: .normal)
        rightButton.setTitle(vc.rightButton, for: .normal)
    }
}
