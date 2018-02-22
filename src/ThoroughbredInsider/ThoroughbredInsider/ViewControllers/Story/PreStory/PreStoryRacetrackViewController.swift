//
//  PreStoryRacetrackViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//  Copyright © 2017 Topcoder. All rights reserved.
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupVM()
        
        filterField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.setupVM(filter: value)
            }).disposed(by: rx.bag)
        
        loadData(from: RestDataSource.getRacetracks())
    }
    
    /// configure vm
    ///
    /// - Parameter filter: current filter
    func setupVM(filter: String = "") {
        selected.removeAll()
        vm = RealmTableViewModel<Racetrack, SelectCell>()
        vm.configureCell = { [weak self] _, value, _, cell in
            cell.titleLabel.text = "\(value.code) - \(value.name)"
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
        vm.bindData(to: tableView, sortDescriptors: [SortDescriptor(keyPath: "code"), SortDescriptor(keyPath: "name")], predicate: filter.trim().isEmpty ? nil : NSPredicate(format: "name CONTAINS[cd] %@", filter))
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
