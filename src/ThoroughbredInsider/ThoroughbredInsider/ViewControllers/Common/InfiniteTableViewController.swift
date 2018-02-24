//
//  InfiniteTableViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/14/17.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift

/**
 * Base class for infinite table view controllers
 *
 * - author: TCCODER
 * - version: 1.0
 */
class InfiniteTableViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    
    /// loader
    private var loaderView: UIView!
    
    /// loading more indicator
    var loadingMore: Bool = false {
        didSet {
            if loadingMore {
                UIView.animate(withDuration: 0.2, animations: {
                    self.tableView.tableFooterView = self.loaderView
                })
                
            }
            else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.tableView.tableFooterView = UIView(frame: CGRect.zero)
                })
            }
        }
    }
    
    /// request pager
    var requestPager: RequestPagerProtocol!
    
    /// override this
    var itemsCount: Int {
        return 0
    }
    
    /// view did load
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loaderView = Bundle.main.loadNibNamed("FooterLoader", owner: self, options: nil)?[0] as? UIView

        tableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] value in
            guard let strongSelf = self else { return }
            if value.cell.frame.maxY+44 > strongSelf.tableView.contentSize.height && !strongSelf.loadingMore && strongSelf.requestPager != nil && !strongSelf.requestPager.isCompleted {
                self?.loadingMore = true
                strongSelf.requestPager.next()
            }
        }).disposed(by: rx.bag)
    }
 
    /// convenience to setup the pager
    ///
    /// - Parameters:
    ///   - requestPager: request pager
    ///   - realmVM: realm table viewmodel
    func setupPager<T: Object>(requestPager: RequestPager<T>) {
        self.requestPager = requestPager
        requestPager.page
            .showLoading(on: view, stopOnNext: true)
            .do(onNext: { [weak self] value in
                self?.loadingMore = false
                }, onCompleted: { [weak self] in
                    self?.loadingMore = false
            })
            .map { $0.items }
            .store()
            .disposed(by: rx.bag)
        loadingMore = true
        requestPager.next()
    }
    
}
