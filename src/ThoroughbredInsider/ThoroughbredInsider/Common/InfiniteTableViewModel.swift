//
//  InfiniteTableViewModel.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/22/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/**
 * Convenience viewmodel for table view controllers
 *
 * - author: TCCODER
 * - version: 1.0
 */
class InfiniteTableViewModel<T, C: UITableViewCell>: NSObject, UITableViewDataSource, UITableViewDelegate {

    var tableView: UITableView!

    /// selection handler
    var onSelect: ((_ indexPath: IndexPath, _ value: T) -> ())?

    /// cell configuration
    var configureCell: ((_ indexPath: IndexPath, _ value: T, _ values: [T], _ cell: C) -> ())?

    /// fetch items callback
    var fetchItems: ((_ offset: Any?, _ limit: Int, _ callback: @escaping ([T], Any)->(), _ failure: @escaping FailureCallback) -> ())!

    /// the reference to "no data" label
    var noDataLabel: UILabel?

    /// the number of items to load at once
    internal var LIMIT = 10

    /// the items to show
    internal var items = [T]()

    /// the last used offset
    internal var offset: Any?

    /// flag: true - the loading completed (no more data), false - else
    internal var loadCompleted = false

    /// flag: is currently loading
    internal var isLoading = false

    /// the request ID
    private var requestId = ""

    /// binds data to table view
    ///
    /// - Parameter tableView: tableView to bind to
    /// - Parameter sequence: data sequence
    func bindData(to tableView: UITableView) {
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
    }

    /// Load data
    internal func loadData() {
        self.noDataLabel?.isHidden = true
        self.offset = nil
        self.loadCompleted = false
        self.items.removeAll()
        tableView.reloadData()

        loadNextItems(showLoadingIndicator: true)
    }

    /// Loading next items
    private func loadNextItems(showLoadingIndicator: Bool = false) {
        if !loadCompleted {
            let requestId = UUID().uuidString
            self.requestId = requestId
            if !showLoadingIndicator {
                let indicator = UIActivityIndicatorView()
                indicator.activityIndicatorViewStyle = .gray
                indicator.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
                indicator.startAnimating()
                tableView.tableFooterView = indicator
            }
            isLoading = true
            let loadingView = showLoadingIndicator ? UIViewController.getCurrentViewController()?.showLoadingView() : nil
            let callback: ([T], Any)->() = { list, offset in
                if self.requestId == requestId {
                    self.offset = offset
                    self.loadCompleted = list.count < self.LIMIT
                    if !list.isEmpty {
                        self.items.append(contentsOf: list)
                        self.tableView.reloadData()
                    }
                    self.noDataLabel?.isHidden = self.items.count > 0

                    self.isLoading = false
                    self.tableView.tableFooterView = nil
                }
                loadingView?.terminate()
            }
            let failure: FailureCallback = { (errorMessage) -> () in
                showError(errorMessage: errorMessage)
                self.isLoading = false
                self.tableView.tableFooterView = nil
                loadingView?.terminate()
            }
            self.fetchItems?(self.offset, self.LIMIT, callback, failure)
        }
    }

    // MARK: UITableViewDataSource, UITableViewDelegate

    /**
     The number of rows

     - parameter tableView: the tableView
     - parameter section:   the section index

     - returns: the number of items
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    /**
     Get cell for given indexPath

     - parameter tableView: the tableView
     - parameter indexPath: the indexPath

     - returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getCell(indexPath, ofClass: C.self)
        let value = items[indexPath.row]
        configureCell?(indexPath, value, items, cell)
        return cell
    }

    /// Open details screen
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - indexPath: the indexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = items[indexPath.row]
        self.onSelect?(indexPath, value)
    }

    /// Load more items
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - cell: the cell
    ///   - indexPath: the indexPath
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == items.count && !isLoading {
            loadNextItems()
        }
    }
}
