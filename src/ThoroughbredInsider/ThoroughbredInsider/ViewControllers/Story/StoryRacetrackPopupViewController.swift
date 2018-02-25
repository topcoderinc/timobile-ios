//
//  StoryRacetrackPopupViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/1/17.
//  Modified by TCCODER on 2/23/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift
import RxRealm
import CoreLocation

/**
 * racetrack dropdown
 *
 * - author: TCCODER
 * - version: 1.1
 * 1.1:
 * - updates for integration
 */
class StoryRacetrackPopupViewController: InfiniteTableViewController {
    
    /// viewmodel
    var vm = TableViewModel<Racetrack?, SelectCell>()
    var selected: Racetrack?
    
    /// selection handler
    var onSelect: ((Racetrack?)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupVM()
        tableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowRadius = 5
        tableView.layer.shadowOpacity = 0.36
        
        let maxDistance: Float = 1000*1000
        setupPager(requestPager: RequestPager<Racetrack>(request: { (offset, limit) in
            let location = LocationManager.shared.currentLocation?.coordinate
            return RestDataSource.getRacetracks(offset: offset, limit: limit,
                                                distanceToLocationMiles: maxDistance, locationLat: location?.latitude ?? 0, locationLng: location?.longitude ?? 0,
                                                sortColumn: "name", sortOrder: "asc")
        }))
    }
    
    /// configure vm
    ///
    /// - Parameter filter: current filter
    private func setupVM() {
        guard let realm = try? Realm() else { return }
        let objects = Observable.array(from: realm.objects(Racetrack.self).sorted(by: [SortDescriptor(keyPath: "stateId"), SortDescriptor(keyPath: "name")])).share(replay: 1)
        objects.map { array in
                var full = array as [Racetrack?]
                full.insert(nil, at: 0)
                return full
            }
            .bind(to: vm.entries)
            .disposed(by: rx.bag)
        vm.configureCell = { [weak self] _, value, _, cell in
            if let value = value {
                cell.titleLabel.text = "\(value.state.shortcut) - \(value.name)"
            }
            else {
                cell.titleLabel.text = "All Racetracks".localized
            }
            cell.itemSelected = self?.selected === value
        }
        vm.onSelect = { [weak self] idx, value in
            self?.selected = value
            self?.tableView.reloadData()
            self?.onSelect?(value)
            self?.dismiss(animated: true, completion: nil)
        }
        vm.bindData(to: tableView)
    }

    /// background button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func bgTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
