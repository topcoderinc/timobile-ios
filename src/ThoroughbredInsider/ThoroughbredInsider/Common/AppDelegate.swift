//
//  AppDelegate.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/29/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

/**
 * App delegate responder
 *
 * - author: TCCODER
 * - version: 1.0
 */
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// window
    var window: UIWindow?

    /// customization after application launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.sharedManager().enable = true
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if !UserDefaults.firstLaunch {
            UserDefaults.firstLaunch = true
            let vc = Storyboards.landing.instantiate.instantiateInitialViewController()
            window?.rootViewController = vc
        }
        else {
            let vc = Storyboards.login.instantiate.instantiateInitialViewController()?.wrappedInNavigationController
            window?.rootViewController = vc
        }
        window?.makeKeyAndVisible()
        
        // common appearance
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont(name: "OpenSans-Semibold", size: 17)!
        ]
        UINavigationBar.appearance().tintColor = .white
        let navButtonTitleAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont(name: "OpenSans-Regular", size: 14)!
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes(navButtonTitleAttributes, for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(navButtonTitleAttributes, for: .highlighted)
        
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().barTintColor = UIColor.purple
        return true
    }

}

