//
//  PreStoryRacetrackViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift

/// option: true - allows to select only one racetrack in PreStory, false - multiple selection
let OPTION_PRESTORY_SINGLE_RACETRACK_SELECTION = false

/**
 * racetracks selection
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - API integration
 * - selection bug fixed
 */
class PreStoryRacetrackViewController: UIViewController {

    /// outlets
    @IBOutlet weak var filterField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    /// viewmodel
    var vm: InfiniteTableViewModel<Racetrack, SelectCell>!
    var selected = Set<Racetrack>()
    var states: [State]?

    // true - initial loading, false - else
    private var initialLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupVM()
        
        filterField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.setupVM(filter: value)
            }).disposed(by: rx.bag)
    }

    /// Clean up table
    ///
    /// - Parameter animated: the animation flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !initialLoad {
            vm.items.removeAll()
            tableView.reloadData()
        }
    }

    /// Reload data
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !initialLoad {
            vm.bindData(to: tableView)
        }
        initialLoad = false
    }
    
    /// configure vm
    ///
    /// - Parameter filter: current filter
    func setupVM(filter: String = "") {
        vm = InfiniteTableViewModel<Racetrack, SelectCell>()
        vm.configureCell = { [weak self] _, value, _, cell in
            if value.code.isEmpty {
                cell.titleLabel.text = value.name
            }
            else {
                cell.titleLabel.text = "\(value.code) - \(value.name)"
            }
            cell.itemSelected = self?.selected.map({$0.id}).contains(value.id) == true
        }
        vm.onSelect = { [weak self] idx, value in
            if OPTION_PRESTORY_SINGLE_RACETRACK_SELECTION {
                self?.selected = Set<Racetrack>([value])
                self?.tableView.reloadData()
            }
            else {
                if let object = self?.selected.filter({$0.id == value.id}).first {
                    _ = self?.selected.remove(object)
                }
                else {
                    self?.selected.insert(value)
                }
                self?.tableView.reloadRows(at: [idx], with: .fade)
            }
        }
        vm.fetchItems = { (_ offset, _ limit, _ callback, _ failure) in
            let stateIds = self.states?.map{"\($0.id)"} ?? []
            if filter.isEmpty {
                RestServiceApi.shared.searchRacetracks(stateIds: stateIds, offset: offset, limit: limit, callback: callback, failure: failure)
            }
            else {
                RestServiceApi.shared.searchRacetracks(name: filter, stateIds: stateIds, offset: offset, limit: limit, callback: callback, failure: failure)
            }
        }
        vm.bindData(to: tableView)
    }

}

// MARK: - PreStoryScreen
extension PreStoryRacetrackViewController: PreStoryScreen {
    
    /// left button
    var leftButton: String {
        return "Back".localized
    }
    
    /// left button
    var leftButtonAction: ((PreStoryViewController) -> ())? {
        return { vc in
            vc.back()
        }
    }
    
    /// right button
    var rightButton: String {
        return "Finish".localized
    }
    
    /// right button
    var rightButtonAction: ((PreStoryViewController) -> ())? {
        return { vc in
            let visibleItems = self.vm.items.map({$0.id})
            let choice: [Racetrack] = Array(self.selected.filter({visibleItems.contains($0.id)}))
            if choice.isEmpty {
                self.showErrorAlert(message: "Please select at least one".localized)
                return
            }
            vc.finish(selectedObjects: choice)
        }
    }
    
}
