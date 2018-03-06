//
//  HelpViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/23/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/**
 * Help screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class HelpViewController: BasePagedViewController {
    
    /// points
    var points = Variable<Int>(1000)
    
    /// tabs
    var tabs: [HelpSection] = HelpSection.sections
    
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
    
    /// pages
    ///
    /// - Parameters:
    ///   - pagingController: the pagingController
    ///   - index: controller index
    /// - Returns: corresponding controller
    override func pagingController(_ pagingController: PagingController, contentViewControllerAtIndex index: Int) -> UIViewController? {
        guard index >= 0 && index < tabs.count else { return nil }
        let info = create(viewController: HelpSectionViewController.self)
        info?.vm.entries.value = tabs[index].list
        return info
    }
    
}

/**
 * Segment controller
 *
 * - author: TCCODER
 * - version: 1.0
 */
class HelpSegmentController: SegmentController {
    
    /// setup view
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let tabs = HelpSection.sections
        let titles = tabs.map { $0.title }
        segments = titles.map { .text($0) }
        itemWidth = 140
    }
    
    /// clear background
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        cell.backgroundColor = .clear
        return cell
    }
    
}
