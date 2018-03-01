//
//  StoryListViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/1/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift
import RxRealm
import CoreLocation

/**
 * Story list screen
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - API integration
 */
class StoryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// the number of items to load at once
    let LIMIT = 10

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!

    /// search query
    var query = Variable<String>("")
    
    /// viewmodel
    var vm: RealmTableViewModel<Story, StoryCell>!

    /// the items to show
    internal var items = [Story]()

    /// the last used offset
    internal var offset: Any?

    /// flag: true - the loading completed (no more data), false - else
    internal var loadCompleted = false

    /// flag: is currently loading
    internal var isLoading = false

    /// the filter
    var filter: StoryFilter?
    /// the order of the results
    var sorting: StorySortingType = .nearest

    /// the location manager reference
    private let locationManager = LocationManager.shared

    /// the user's current location
    private var currentLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        noDataLabel.isHidden = true

        locationManager.locationUpdated = { [weak self] in
            self?.currentLocation = LocationManager.shared.locations?.first?.coordinate
            self?.tableView.reloadData()
        }
        query.asObservable()
            .subscribe(onNext: { [weak self] value in
                if let _ = self?.filter {
                    self?.filter?.title = value
                }
                else {
                    self?.filter = StoryFilter(title: value, racetrackIds: [], tagIds: [], location: nil)
                }
                self?.loadData()
            }).disposed(by: rx.bag)
    }

    /// Start monitoring location changes
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
        currentLocation = locationManager.locations?.first?.coordinate
    }

    /// Stop monitoring location changes
    ///
    /// - Parameter animated: the animation flag
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }

    /// Set racetracks filter
    ///
    /// - Parameters:
    ///   - racetracks: the racetracks
    ///   - reload: true - need to reload data
    func setRacetrackFilter(_ racetracks: [Racetrack]?, reload: Bool = true) {
        let ids = racetracks == nil ? [] : racetracks!.map({"\($0.id)"})
        if let _ = self.filter {
            self.filter?.racetrackIds = ids
        }
        else {
            self.filter = StoryFilter(title: self.query.value, racetrackIds: ids, tagIds: [], location: nil)
        }
        if reload {
            self.loadData()
        }
    }

    /// Update sorting
    ///
    /// - Parameter sort: the sorting
    func setSorting(_ sort: StorySortingType) {
        self.sorting = sort
        self.loadData()
    }

    /// Load data
    internal func loadData() {
        self.offset = nil
        self.loadCompleted = false
        self.items.removeAll()
        self.tableView.reloadData()

        loadNextItems(showLoadingIndicator: true)
    }

    /// Loading next items
    private func loadNextItems(showLoadingIndicator: Bool = false) {
        if !loadCompleted {
            if !showLoadingIndicator {
                let indicator = UIActivityIndicatorView()
                indicator.activityIndicatorViewStyle = .gray
                indicator.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
                indicator.startAnimating()
                tableView.tableFooterView = indicator
            }
            isLoading = true
            self.view.layoutIfNeeded()
            let loadingView = showLoadingIndicator ? showLoadingView(self.view) : nil
            let callback: ([Story], Any)->() = { list, offset in
                self.offset = offset
                self.loadCompleted = list.count < self.LIMIT
                if !list.isEmpty {
                    self.items.append(contentsOf: list)
                    self.tableView.reloadData()
                }
                self.noDataLabel.isHidden = self.items.count > 0

                self.isLoading = false
                self.tableView.tableFooterView = nil
                loadingView?.terminate()
            }
            let failure: FailureCallback = { (errorMessage) -> () in
                self.showAlert(NSLocalizedString("Error", comment: "Error"), errorMessage)
                self.isLoading = false
                self.tableView.tableFooterView = nil
                loadingView?.terminate()
            }
            if let filter = filter {
                RestServiceApi.shared.searchStories(filter: filter, sorting: self.sorting, offset: offset, limit: LIMIT, callback: callback, failure: failure)
            }
            else {
                RestServiceApi.shared.searchStories(sorting: self.sorting, offset: offset, limit: LIMIT, callback: callback, failure: failure)
            }
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
        let cell = tableView.getCell(indexPath, ofClass: StoryCell.self)
        let value = items[indexPath.row]
        cell.titleLabel.text = value.title
        cell.storyImage.load(url: value.smallImageURL) { ()->Bool in
            return cell.titleLabel.text == value.title
        }
        cell.racetrackLabel.text = value.subtitle
        cell.shortDescriptionLabel.text = value.getDescription()
        cell.shortDescriptionLabel.setLineHeight(16)
        cell.chaptersLabel.text = "\(value.chapters.count) \("chapters".localized)"
        cell.cardsLabel.text = "\(value.cards.count) \("cards".localized)"

        if let currentLocation = currentLocation {
            let distance = Int(currentLocation.distance(to: CLLocationCoordinate2D(latitude: value.lat, longitude: value.long)))
            cell.milesLabel.text = "\(distance) \("miles".localized)"
        }
        else {
            cell.milesLabel.text = "N/A \("miles".localized)"
        }
        return cell
    }

    /// Open details screen
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - indexPath: the indexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = items[indexPath.row]
        guard let vc = self.create(viewController: StoryDetailsViewController.self, storyboard: .details) else { return }
        vc.story = value
        self.navigationController?.pushViewController(vc, animated: true)
        self.tableView.deselectRow(at: indexPath, animated: true)
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

/**
 * Story list cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StoryCell: UITableViewCell {
    
    /// fields
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var racetrackLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var chaptersLabel: UILabel!
    @IBOutlet weak var cardsLabel: UILabel!
    @IBOutlet weak var milesLabel: UILabel!
}
