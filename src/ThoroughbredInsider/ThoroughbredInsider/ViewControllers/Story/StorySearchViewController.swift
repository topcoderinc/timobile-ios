//
//  StorySearchViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/1/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit
import RealmSwift
import RxRealm

/**
 * Recent searches
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StorySearchViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    
    /// viewmodel
    var vm = RealmTableViewModel<RecentSearch, SelectCell>()
    
    /// selection handler
    var onSelect: ((RecentSearch)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupVM()
    }
    
    /// configure vm
    ///
    /// - Parameter filter: current filter
    private func setupVM() {
        vm.configureCell = { _, value, _, cell in
            cell.titleLabel.text = value.query
        }
        vm.onSelect = { [weak self] idx, value in
            self?.onSelect?(value)
            self?.dismiss(animated: true, completion: nil)
        }
        vm.bindData(to: tableView, sortDescriptors: [SortDescriptor(keyPath: "date", ascending: false)])
    }
}
