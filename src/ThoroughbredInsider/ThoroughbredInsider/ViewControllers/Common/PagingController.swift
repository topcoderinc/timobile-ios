//
//  PagingController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 9/1/17.
//  Modified by TCCODER on 2/23/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * Paging controller content provider protocol
 *
 * - author: TCCODER
 * - version: 1.0
 */
protocol PagingContentProvider: class {
    /// controller at index
    func pagingController(_ pagingController: PagingController, contentViewControllerAtIndex index: Int) -> UIViewController?
    
}

/**
 * Static content provider protocol
 *
 * - author: TCCODER
 * - version: 1.0
 */
protocol StaticPagingContentProvider: PagingContentProvider {
    
    /// array of controllers factory methods
    var pagedContentFactory: [() -> UIViewController] { get }
    
}

// MARK: - static content provider
extension StaticPagingContentProvider {
    
    /// controller at index
    func pagingController(_ pagingController: PagingController, contentViewControllerAtIndex index: Int) -> UIViewController? {
        guard index >= 0 && index < pagedContentFactory.count else {
            return nil
        }
        return pagedContentFactory[index]()
    }
    
}

/**
 * Paging controller delegate protocol
 *
 * - author: TCCODER
 * - version: 1.0
 */
protocol PagingControllerDelegate: class {
    /// transition to new screen completed
    ///
    /// - Parameters:
    ///   - pagingController: the pagingController
    ///   - viewController: new viewController
    ///   - index: the index
    func pagingController(_ pagingController: PagingController, didTransitionTo viewController: UIViewController, atIndex index: Int)
    
    /// transition to new screen
    ///
    /// - Parameters:
    ///   - pagingController: the pagingController
    ///   - viewController: new viewController
    ///   - index: the index
    /*optional*/ func pagingController(_ pagingController: PagingController, willTransitionTo viewController: UIViewController, atIndex index: Int)
    
    /// offset updated
    ///
    /// - Parameters:
    ///   - pagingController: the pagingController
    ///   - offset: new offset
    /*optional*/ func pagingController(_ pagingController: PagingController, didUpdateOffset offset: CGFloat)
}

// default empty handlers for optional delegate methods
extension PagingControllerDelegate {
    func pagingController(_ pagingController: PagingController, willTransitionTo viewController: UIViewController, atIndex index: Int) {}
    func pagingController(_ pagingController: PagingController, didUpdateOffset offset: CGFloat) {}
}

/**
 * Paging controller
 *
 * - author: TCCODER
 * - version: 1.0
 */
class PagingController: UIPageViewController {
    
    
    /// index
    fileprivate(set) var currentIndex = NSNotFound
    fileprivate(set) var currentViewController: UIViewController?
    
    
    /// data source
    weak var contentProvider: PagingContentProvider?
    weak var contentDelegate: PagingControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        for case let scrollView as UIScrollView in view.subviews {
            scrollView.delegate = self
        }
        
        setSelectedPageIndex(0, animated: false)
    }
    
    // MARK: - Content
    
    /// programmatic page change
    ///
    /// - Parameters:
    ///   - index: index
    ///   - animated: animated or not
    func setSelectedPageIndex(_ index: Int, animated: Bool = true) {
        guard index != currentIndex, let viewController = viewControllerAtIndex(index) else {
            return
        }
        setViewControllers([viewController],
                           direction: index > currentIndex ? .forward : .reverse,
                           animated: animated,
                           completion: { _ in
                            self.updateCurrentViewController()
        })
    }
    
    /// getter for index
    ///
    /// - Parameter index: the index
    /// - Returns: controller
    func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        if let controller = cachedViewController(atIndex: index) {
            return controller
        }
        if let controller = contentProvider?.pagingController(self, contentViewControllerAtIndex: index) {
            cacheViewController(controller, forIndex: index)
            return controller
        }
        return nil
    }
    
    /// update current
    fileprivate func updateCurrentViewController() {
        currentViewController = viewControllers?.first
        if let controller = currentViewController, let index = indexMap.object(forKey: controller)?.intValue {
            currentIndex = index
            contentDelegate?.pagingController(self, didTransitionTo: controller, atIndex: index)
        }
    }
    
    // MARK: - Cache
    
    /// cache flag
    var shouldCacheContent = true
    
    /// map
    fileprivate let indexMap = NSMapTable<UIViewController, NSNumber>.weakToStrongObjects()
    
    /// cache
    private let cache = NSCache<NSNumber, UIViewController>()
    
    
    /// cache controller
    ///
    /// - Parameters:
    ///   - viewController: viewController to cache
    ///   - index: the index
    private func cacheViewController(_ viewController: UIViewController, forIndex index: Int) {
        let number = NSNumber(value: index)
        indexMap.setObject(number, forKey: viewController)
        if shouldCacheContent {
            cache.setObject(viewController, forKey: number)
        }
    }
    
    
    /// cached controller getter
    ///
    /// - Parameter index: the index
    /// - Returns: cached controller
    private func cachedViewController(atIndex index: Int) -> UIViewController? {
        if shouldCacheContent {
            return cache.object(forKey: NSNumber(value: index))
        }
        return nil
    }
    
}


// MARK: - UIPageViewControllerDataSource
extension PagingController: UIPageViewControllerDataSource {
    /// content before current
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return viewControllerAtIndex(currentIndex - 1)
    }
    /// content after current
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return viewControllerAtIndex(currentIndex + 1)
    }
    
}

// MARK: - UIPageViewControllerDelegate
extension PagingController: UIPageViewControllerDelegate {
    /// transition to new screen completed
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {
            return
        }
        updateCurrentViewController()
    }
    
    /// transition to new screen
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let vc = pendingViewControllers.first,
            let index = indexMap.object(forKey: vc)?.intValue {
            contentDelegate?.pagingController(self, willTransitionTo: vc, atIndex: index)
        }
    }
    
}

// MARK: - UIScrollViewDelegate
extension PagingController: UIScrollViewDelegate {
    /// did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x / scrollView.frame.width + CGFloat(currentIndex) - 1
        contentDelegate?.pagingController(self, didUpdateOffset: offset)
    }
    
}
