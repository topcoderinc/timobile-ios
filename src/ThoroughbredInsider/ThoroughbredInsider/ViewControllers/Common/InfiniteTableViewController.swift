//
//  InfiniteTableViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/14/17.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit

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
    
    /// view did load
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loaderView = Bundle.main.loadNibNamed("FooterLoader", owner: self, options: nil)?[0] as? UIView
        
//        requestPager = RequestPager<[MotorcycleInfo]>.init(request: api.getMyMotorcycles)
//        requestPager.page
//            .showLoading(on: view, stopOnNext: true)
//            .subscribe(onNext: { [weak self] value in
//                self?.items.append(contentsOf: value.map { $0.0 })
//                self?.tableView.reloadData()
//                self?.noDataLabel.isHidden = self?.items.isEmpty == false
//                self?.loadingMore = false
//                }, onCompleted: { [weak self] in
//                    self?.loadingMore = false
//            }).disposed(by: rx.bag)
//        requestPager.next()
    }
    
    /// will display cell
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - cell: the cell
    ///   - indexPath: the indexPath
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row == items.count-1 && !loadingMore && !requestPager.isCompleted {
//            loadingMore = true
//            requestPager.next()
//        }
//    }
    
}
