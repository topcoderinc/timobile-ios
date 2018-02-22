//
//  StoryChapterViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import UIComponents
import AVFoundation
import RxCocoa
import RxSwift
import RealmSwift

/**
 * story chapters screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StoryChapterViewController: UIViewController {

    /// page controller
    private var pageViewController: PagingController?
    
    /// story
    var story: StoryDetails!
    
    /// initial chapter to open
    var initial = 0
    
    /// outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: PagerControl!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    /// viewmodel
    var vm = Variable<[Chapter]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Chapters".localized
        addBackButton()
        guard let realm = try? Realm() else { return }
        let objects = Observable.array(from: realm.objects(Chapter.self).filter("trackStoryId = %d", story.id).sorted(by: [SortDescriptor(keyPath: "id")])).share(replay: 1)
        objects.bind(to: vm)
            .disposed(by: rx.bag)
        createPageViewController()
        pageViewController?.setSelectedPageIndex(initial)
        pageControl.selected = initial
        
        vm.asObservable().subscribe(onNext: { [weak self] value in
            let idx = self?.pageViewController?.currentIndex ?? 0
            let vc = self?.pageViewController?.currentViewController as? ChapterViewController
            if value.count > idx {
                vc?.chapter = value[idx]
            }
        }).disposed(by: rx.bag)
    }
    
    /// inits the page controller
    private func createPageViewController() {
        pageControl.count = story.chapters.count
        
        guard let pageController = create(viewController: PagingController.self) else { return }
        pageViewController = pageController
        pageController.contentProvider = self
        pageController.contentDelegate = self
        loadChildController(pageController, inContentView: containerView)
        
    }

    /// left button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func leftTapped(_ sender: Any) {
        if let index = pageViewController?.currentIndex, index > 0 {
            pageViewController?.setSelectedPageIndex(index-1)
        }
    }
    
    /// right button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func rightTapped(_ sender: Any) {
        if let index = pageViewController?.currentIndex, index < pageControl.count-1 {
            pageViewController?.setSelectedPageIndex(index+1)
        }
    }
    
    /// prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? StoryCommentsViewController {
            vc.story = story
        }
    }
    
}

// MARK: - PagingContentProvider
extension StoryChapterViewController: PagingContentProvider {
    
    /// content view controller
    ///
    /// - Parameters:
    ///   - pagingController: the pagingController
    ///   - index: the index
    /// - Returns: content view controller
    func pagingController(_ pagingController: PagingController, contentViewControllerAtIndex index: Int) -> UIViewController? {
        guard pageControl.count > index && index > -1 else { return nil }
        guard let vc = create(viewController: ChapterViewController.self) else { return nil }
        vc.story = story
        vc.chapter = index < vm.value.count ? vm.value[index] : nil
        return vc
    }
    
}

// MARK: - PagingControllerDelegate
extension StoryChapterViewController: PagingControllerDelegate {
    
    func pagingController(_ pagingController: PagingController, didTransitionTo viewController: UIViewController, atIndex index: Int) {
        pageControl?.selected = index
        leftButton.isEnabled = index > 0
        rightButton.isEnabled = index < story.chapters.count
        if index < vm.value.count {
            navigationItem.title = vm.value[index].title
            let vc = viewController as? ChapterViewController
            vc?.chapter = vm.value[index]
        }
    }
}
