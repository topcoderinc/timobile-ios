//
//  PreStoryStateViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//  Modified by TCCODER on 23/2/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import UIComponents
import RxCocoa
import RxSwift
import RealmSwift

/**
 * state selection
 *
 * - author: TCCODER
 * - version: 1.1
 * 1.1:
 * - updates for integration
 */
class PreStoryStateViewController: InfiniteTableViewController {

    /// outlets
    @IBOutlet weak var filterField: UITextField!
    
    /// viewmodel
    var vm: RealmTableViewModel<State, SelectCell>!
    var selected = Set<State>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupVM()
        
        filterField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.setupVM(filter: value)
            }).disposed(by: rx.bag)
        
        loadData(from: RestDataSource.getStates())
        setupPager(requestPager: RequestPager<State>(request: { (offset, limit) in
            RestDataSource.getStates(offset: offset, limit: limit)
        }))
    }
    
    /// configure vm
    ///
    /// - Parameter filter: current filter
    func setupVM(filter: String = "") {
        vm = RealmTableViewModel<State, SelectCell>()
        vm.configureCell = { [weak self] _, value, _, cell in
            cell.titleLabel.text = value.value
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
        vm.bindData(to: tableView, sortDescriptors: [SortDescriptor(keyPath: "value")], predicate: filter.trim().isEmpty ? nil : NSPredicate(format: "value CONTAINS[cd] %@", filter))
    }

}

// MARK: - PreStoryScreen
extension PreStoryStateViewController: PreStoryScreen {
    
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
        return "Next".localized
    }
    
    /// right button
    var rightButtonAction: ((PreStoryViewController) -> ())? {
        return { vc in
            if self.selected.isEmpty {
                self.showErrorAlert(message: "Please select at least one".localized)
                return
            }
            vc.statesIds.value = self.selected.map { $0.id } 
            vc.next()
        }
    }
    
}

/**
 * Simple selection cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class SelectCell: UITableViewCell {
    
    /// outlets
    @IBOutlet weak var checkmark: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    /// selection
    var itemSelected = false {
        didSet {
            checkmark.isHidden = !itemSelected
            titleLabel.textColor = itemSelected ? .darkSkyBlue : .textBlack
        }
    }
    
}
