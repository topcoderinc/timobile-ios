//
//  SlideMenuViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * Represents the slide menu view controller class
 *
 * - author: TCCODER
 * - version: 1.0
 */
class SlideMenuViewController: UIViewController, UIGestureRecognizerDelegate {

    /// root navigation controller
    let containerNavigationController: UINavigationController
    /// left view controller (menu)
    let leftViewController: MenuViewController
    /// side menu is collapsed or not
    var collapsed = true
    /// view which will cover containerNavigationController when open
    let coverView = UIView()
    /// shadow view which hovers above menu
    let shadowView = UIView()
    /// pan gesture recognizer
    let panGestureRecognizer = UIPanGestureRecognizer()
    /// how much of the containerNavigationController has to be visible when open
    var expandOffset: CGFloat = SCREEN_SIZE.width * 0.184
    /// when left edge of container view reach this point while opening, side menu will be shown otherwise it will be closed back
    var openOffset: CGFloat = SCREEN_SIZE.width/5
    /// when left edge of container view reach this point while closing, side menu will be closed otherwise it will be opened back
    var closeOffset: CGFloat = SCREEN_SIZE.width*2/3
    
    /**
     view did load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadChildController(leftViewController, inContentView: self.view)
        loadChildController(containerNavigationController, inContentView: self.view)
        
        // pan gesture
        panGestureRecognizer.addTarget(self, action: #selector(SlideMenuViewController.handlePan(_:)))
        containerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        
        // add invisible cover
        containerNavigationController.view.addSubview(coverView)
        coverView.translatesAutoresizingMaskIntoConstraints = false
        containerNavigationController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": coverView]))
        containerNavigationController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": coverView]))
        containerNavigationController.view.sendSubview(toBack: coverView)
        coverView.backgroundColor = UIColor.clear
        
        // add dismiss on tap when open
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SlideMenuViewController.toggleSideMenu))
        coverView.addGestureRecognizer(tapGesture)
        
        // show shadow
        shadowView.layer.shadowRadius = 7
        shadowView.layer.shadowOffset = CGSize(width: -6, height: 0)
        shadowView.layer.shadowOpacity = 0.7
        shadowView.backgroundColor = UIColor.white
        self.view.addSubview(shadowView)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": shadowView]))
        shadowView.addConstraint(NSLayoutConstraint(item: shadowView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 12))
        self.view.addConstraint(NSLayoutConstraint(item: shadowView, attribute: .leading, relatedBy: .equal, toItem: containerNavigationController.view, attribute: .leading, multiplier: 1, constant: 0))
        self.view.bringSubview(toFront: containerNavigationController.view)

    }
    
    /**
     toggles side menu
     */
    @objc func toggleSideMenu() {
        animate(collapsed)
    }
    
    /**
     animates left view controller
     
     :param: open true if it should be opened, false if closed
     */
    func animate(_ open: Bool) {
        if (open) {
            collapsed = false
            containerNavigationController.view.bringSubview(toFront: coverView)
            animatePosition(true, completion: nil)
        } else {
            animatePosition(false) { finished in
                self.collapsed = true
            }
        }
    }
    
    /**
     Method animating position of containerViewController
     
     :param: open       true to open, false to close
     :param: completion completion handler
     */
    func animatePosition(_ open : Bool, completion: ((Bool) -> ())?) {
        let targetPosition: CGFloat = open ? containerNavigationController.view.frame.width - expandOffset : 0.0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
            self.containerNavigationController.view.frame.origin.x = targetPosition
            self.shadowView.frame.origin.x = targetPosition
            }) { (finished) -> Void in
                
                if !open {
                    self.containerNavigationController.view.sendSubview(toBack: self.coverView)
                }
                if let aCompletion = completion {
                    aCompletion(finished)
                }
        }
    }
    
    /**
     when gesture occures and changes state this handler is moving views
     
     :param: gestureRecognizer gesture recognizer
     */
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch(gestureRecognizer.state) {
        case .began:
            break
        case .changed:
            if containerNavigationController.view.frame.origin.x > 0 {
                containerNavigationController.view.bringSubview(toFront: coverView)
            } else
            {
                containerNavigationController.view.sendSubview(toBack: coverView)
            }
            
            let newCenterX = gestureRecognizer.view!.center.x + gestureRecognizer.translation(in: view).x
            if newCenterX > self.view.center.x {
                gestureRecognizer.view!.center.x = gestureRecognizer.view!.center.x + gestureRecognizer.translation(in: view).x
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
                shadowView.frame.origin.x = gestureRecognizer.view!.frame.minX
            }
        case .ended:
            if collapsed  {
                animate(gestureRecognizer.view!.frame.origin.x > openOffset)
            }
            else {
                animate(gestureRecognizer.view!.frame.origin.x > closeOffset)
            }
        default:
            break
        }
    }

    /**
    Creates new instance

    - parameter leftSideController:  The left side controller
    - parameter defaultContent:      The default content

    - returns: the created instance
    */
    init(leftSideController: MenuViewController, defaultContent: UIViewController) {
        leftViewController = leftSideController
        containerNavigationController = defaultContent is UINavigationController ? defaultContent as! UINavigationController : defaultContent.wrappedInNavigationController
        
        super.init(nibName: nil, bundle: nil)
    }
    
    /**
    Fail create from nib

    - parameter aDecoder: The a decoder
    */
    required init?(coder aDecoder: NSCoder) {
        leftViewController = MenuViewController()
        containerNavigationController = UINavigationController()
        assertionFailure("initWithCoder: is not supported")

        super.init(coder: aDecoder)
    }

    /**
    Set content view controller

    - parameter newController: The new controller
    */
    func setContentViewController(_ newController: UIViewController) {
        containerNavigationController.setViewControllers([newController], animated: false)
        animate(false)
    }
    
    // MARK: - gesture recognizer delegate
    
    /**
     filters touches when collapsed
     */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer.state == .possible && collapsed {
            return touch.location(in: gestureRecognizer.view).x < (160)
        }
        return true
    }
    
    
    /// confirms logout and logouts if confirmed
    func confirmLogout() {
        confirm(action: "Logout".localized, message: "Are you sure you want to logout?".localized, confirmHandler: {
            RestDataSource.logout()
                .subscribe(onNext: { [weak self] value in
                    self?.dismiss(animated: true, completion: nil)
                }).disposed(by: self.rx.bag)
        }, cancelHandler: nil)
    }
}

/**
 * Relevant extensions for contained controllers
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension UIViewController {
    
    /// gets the slide menu controller
    var slideMenuController: SlideMenuViewController? {
        var parent: UIViewController? = self
        while (parent != nil) {
            if let parent = parent as? SlideMenuViewController {
                return parent
            }
            parent = parent?.parent
        }
        return nil
    }

    /**
    Show controller for storyboard name and identifier.
    
    - parameter storyboardName: The storyboard name parameter.
    - parameter identifier:     The identifier parameter.
    */
    func showController(_ storyboardName: String, identifier: String) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier) 
        slideMenuController?.setContentViewController(controller.wrappedInNavigationController)
    }
    
    /**
    Show left side menu button tapped.
    */
    @IBAction func showLeftSideMenuButtonTapped() {
        slideMenuController?.toggleSideMenu()
    }
 
    /**
     Add menu button
     */
    func addMenuButton() {
        let menuBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .plain, target: self, action: #selector(UIViewController.showLeftSideMenuButtonTapped))
        self.navigationItem.leftBarButtonItem = menuBtn
    }

}
