//
//  PreStoryStateViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
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
 *
 * changes:
 * 1.1:
 * - API integration
 */
class PreStoryStateViewController: UIViewController {

    /// outlets
    @IBOutlet weak var filterField: UITextField!    
    @IBOutlet weak var tableView: UITableView!
    
    /// viewmodel
    var vm: InfiniteTableViewModel<State, SelectCell>!
    var selected = Set<State>()

    /// the filter to apply
    private var filter: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        filterField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.applyFilter(value)
            }).disposed(by: rx.bag)
        setupVM()
    }

    /// Apply filter
    ///
    /// - Parameter filter: current filter
    func applyFilter(_ filter: String = "") {
        if self.filter != filter {
            self.filter = filter
            self.vm?.loadData()
        }
    }

    /// configure vm
    func setupVM() {
        selected.removeAll()
        vm = InfiniteTableViewModel<State, SelectCell>()
        vm.configureCell = { [weak self] _, value, _, cell in
            cell.titleLabel.text = value.name
            cell.itemSelected = self?.selected.map({$0.id}).contains(value.id) == true
        }
        vm.onSelect = { [weak self] indexPath, value in
            if let object = self?.selected.filter({$0.id == value.id}).first {
                _ = self?.selected.remove(object)
            }
            else {
                self?.selected.insert(value)
            }
            self?.tableView.reloadRows(at: [indexPath], with: .fade)
        }
        vm.fetchItems = { offset, limit, callback, failure in
            RestServiceApi.shared.getStates(name: self.filter, offset: offset, limit: limit, callback: callback, failure: failure)
        }
        vm.bindData(to: tableView)
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
            let visibleItems = self.vm.items.map({$0.id})
            let choice = Array(self.selected.filter({visibleItems.contains($0.id)}))
            if choice.isEmpty {
                self.showErrorAlert(message: "Please select at least one".localized)
                return
            }
            vc.next(selectedObjects: choice)
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
