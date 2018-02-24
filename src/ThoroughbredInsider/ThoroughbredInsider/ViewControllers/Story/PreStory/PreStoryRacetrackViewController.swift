//
//  PreStoryRacetrackViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift

/**
 * racetracks selection
 *
 * - author: TCCODER
 * - version: 1.0
 */
class PreStoryRacetrackViewController: UIViewController {

    /// outlets
    @IBOutlet weak var filterField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    /// viewmodel
    var vm: RealmTableViewModel<Racetrack, SelectCell>!
    var selected = Set<Racetrack>()
    var statesIds: Variable<String>!
    var needReload = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupVM()
        
        filterField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.setupVM(filter: value)
            }).disposed(by: rx.bag)
        
        statesIds.asObservable().subscribe(onNext: { [weak self] value in
            self?.needReload = true
        }).disposed(by: rx.bag)
    }
    
    /// View will appear
    ///
    /// - Parameter animated: the animation flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needReload {
            loadData(from: RestDataSource.getRacetracks(stateIds: statesIds.value))
        }
    }
    
    /// configure vm
    ///
    /// - Parameter filter: current filter
    func setupVM(filter: String = "") {
        vm = RealmTableViewModel<Racetrack, SelectCell>()
        vm.configureCell = { [weak self] _, value, _, cell in
            cell.titleLabel.text = "\(value.state.shortcut) - \(value.name)"
            cell.itemSelected = self?.selected.contains(value) == true
        }
        vm.onSelect = { [weak self] idx, value in
            if self?.selected.contains(value) == true {
                _ = self?.selected.remove(value)
            }
            else {
                self?.selected.insert(value)
            }
            self?.tableView.reloadRows(at: [IndexPath.init(row: idx, section: 0)], with: .fade)
        }
        vm.bindData(to: tableView, sortDescriptors: [SortDescriptor(keyPath: "name")], predicate: filter.trim().isEmpty ? nil : NSPredicate(format: "name CONTAINS[cd] %@", filter))
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
            if self.selected.isEmpty {
                self.showErrorAlert(message: "Please select at least one".localized)
                return
            }
            vc.finish()
        }
    }
    
}
