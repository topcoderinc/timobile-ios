//
//  BasePagedViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 9/1/17.
//  Copyright © 2017 topcoder. All rights reserved.
//

import UIKit

/**
 * Base controller with paging segments
 *
 * - author: TCCODER
 * - version: 1.0
 */
class BasePagedViewController: UIViewController {

    /// embeds
    var segmentController: SegmentController!
    var pagingController: PagingController!
    
    /// flag to handle programmatic changes
    internal var suspendAutomaticTrackingOfPagingControllerDelegate: Bool = false
    
    /// view did load
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setSelectedPage(0, animated: false)
    }

    
    /// segue handler
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let controller as SegmentController:
            segmentController = controller
            segmentController.delegate = self
        case let controller as PagingController:
            pagingController = controller
            pagingController.contentProvider = self
            pagingController.contentDelegate = self
        default:
            ()
        }
    }

}

// MARK: - PagingContentProvider
extension BasePagedViewController: PagingContentProvider {
    
    /// content view controller
    ///
    /// - Parameters:
    ///   - pagingController: the pagingController
    ///   - index: the index
    /// - Returns: content view controller
    @objc func pagingController(_ pagingController: PagingController, contentViewControllerAtIndex index: Int) -> UIViewController? {
        fatalError("Must override")
    }
    
}

// MARK: - SegmentControllerDelegate
extension BasePagedViewController: SegmentControllerDelegate {
    
    /// segments count
    var segmentsCount: Int {
        return segmentController?.segmentsCount ?? 0
    }
    
    
    /// did select handler
    ///
    /// - Parameters:
    ///   - segmentController: the segmentController
    ///   - index: the index
    func segmentController(_ segmentController: SegmentController, didSelectItemAtIndex index: Int) {
        setSelectedPage(index)
    }
    
    /// should select or not
    ///
    /// - Parameters:
    ///   - segmentController: the segmentController
    ///   - index: the index
    /// - Returns: should select or not
    func segmentController(_ segmentController: SegmentController, shouldSelectItemAtIndex index: Int) -> Bool {
        return true
    }
    
    
    /// set page programmaticaly
    ///
    /// - Parameters:
    ///   - index: the index
    ///   - animated: animated or not
    internal func setSelectedPage(_ index: Int, animated: Bool = true) {
        suspendAutomaticTrackingOfPagingControllerDelegate = true
        pagingController.setSelectedPageIndex(index, animated: animated)
        suspendAutomaticTrackingOfPagingControllerDelegate = false
    }
    
}

// MARK: - PagingControllerDelegate
extension BasePagedViewController: PagingControllerDelegate {
    
    /// transition handler
    ///
    /// - Parameters:
    ///   - pagingController: the pagingController
    ///   - viewController: destination viewController
    ///   - index: the index
    func pagingController(_ pagingController: PagingController, didTransitionTo viewController: UIViewController, atIndex index: Int) {
        if !suspendAutomaticTrackingOfPagingControllerDelegate {
            segmentController?.selectedSegmentIndex = index
        }

    }
    
    /// offset changed handler
    ///
    /// - Parameters:
    ///   - pagingController: the pagingController
    ///   - offset: the new offset
    func pagingController(_ pagingController: PagingController, didUpdateOffset offset: CGFloat) {
        if !suspendAutomaticTrackingOfPagingControllerDelegate {
            segmentController?.displayedSegmentOffset = offset
        }
    }
    
}
