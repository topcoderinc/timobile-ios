//
//  StoryRacetrackPopupViewController.swift
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

/**
 * racetrack dropdown
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - API integration
 */
class StoryRacetrackPopupViewController: UIViewController {
    
    /// outlets
    @IBOutlet weak var tableView: UITableView!
    
    /// viewmodel
    var vm = InfiniteTableViewModel<Racetrack?, SelectCell>()
    var selected = [Racetrack]()
    
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

    }
    
    /// configure vm
    ///
    /// - Parameter filter: current filter
    private func setupVM() {
        vm.configureCell = { [weak self] _, value, _, cell in
            guard let sf = self else { return }
            if let value = value {
                if value.code.isEmpty {
                    cell.titleLabel.text = value.name
                }
                else {
                    cell.titleLabel.text = "\(value.code) - \(value.name)"
                }
            }
            else {
                cell.titleLabel.text = "All Racetracks".localized
            }
            cell.itemSelected = sf.selected.map({$0.id}).contains(value?.id ?? 0)
        }
        vm.onSelect = { [weak self] idx, value in
            self?.selected = value != nil ? [value!] : []
            self?.tableView.reloadData()
            self?.onSelect?(value)
            self?.dismiss(animated: true, completion: nil)
        }
        vm.fetchItems = { (_ offset: Any?, _ limit: Int, _ callback: @escaping ([Racetrack?], Any)->(), _ failure: @escaping FailureCallback) in
            RestServiceApi.shared.searchRacetracks(offset: offset, limit: limit, callback: { items, nextOffset in
                if offset == nil || offset as? Int == 0 {
                    callback([nil] + items, nextOffset)
                }
                else {
                    callback(items, nextOffset)
                }
            }, failure: failure)
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
