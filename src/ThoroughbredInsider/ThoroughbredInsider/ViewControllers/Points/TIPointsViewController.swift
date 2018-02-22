//
//  TIPointsViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/**
 * Points screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class TIPointsViewController: BasePagedViewController {

    /// outlets
    @IBOutlet weak var ptsLabel: UILabel!
    
    /// points
    var points = Variable<Int>(1000)
    
    /// tabs
    enum Tabs: Int {
        case achievements, tasks
        
        /// title
        var title: String {
            switch self {
            case .achievements:
                return "Achievements".localized
            case .tasks:
                return "Daily Tasks".localized
            }
        }
    }
    
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
    
    /// info button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func infoTapped(_ sender: Any) {
        slideMenuController?.leftViewController.select(menu: .help)
    }
    
    /// go shop
    private func goShop() {
        slideMenuController?.leftViewController.select(menu: .shop)
    }
    
    /// pages
    ///
    /// - Parameters:
    ///   - pagingController: the pagingController
    ///   - index: controller index
    /// - Returns: corresponding controller
    override func pagingController(_ pagingController: PagingController, contentViewControllerAtIndex index: Int) -> UIViewController? {
        guard let tab = Tabs(rawValue: index) else { return nil }
        switch tab {
        case .achievements:
            let info = create(viewController: PointsListViewController.self)
            info?.tab = .achievements
            info?.onGoShop = goShop
            return info
        case .tasks:
            let info = create(viewController: PointsListViewController.self)
            info?.tab = .tasks
            info?.onGoShop = goShop
            return info
        }
    }

}

/**
 * Segment controller
 *
 * - author: TCCODER
 * - version: 1.0
 */
class TIPointsSegmentController: SegmentController {
    
    /// setup view
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabs: [TIPointsViewController.Tabs] = [.achievements, .tasks]
        let titles = tabs.map { $0.title }
        segments = titles.map { .text($0) }
        constraintItemsToBounds = true
    }
    
    /// clear background
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        cell.backgroundColor = .clear
        return cell
    }
    
}
