//
//  HelpSectionViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * Help section
 *
 * - author: TCCODER
 * - version: 1.0
 */
class HelpSectionViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    
    /// viewmodel
    var vm = TableViewModel<HelpSection.Item, HelpCell>()
    var selected = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        vm.configureCell = { [weak self] idx, value, _, cell in
            cell.titleLabel.text = value.title
            let itemSelected = self?.selected.contains(idx) == true
            cell.contentLabel.text = itemSelected ? value.text : ""
            cell.checkmark.image = itemSelected ? #imageLiteral(resourceName: "iconArrowUp").withRenderingMode(.alwaysTemplate) : #imageLiteral(resourceName: "iconArrowDown")
        }
        vm.onSelect = { [weak self] idx, value in
            if self?.selected.contains(idx) == true {
                _ = self?.selected.remove(idx)
            }
            else {
                self?.selected.insert(idx)
            }
            self?.tableView.reloadRows(at: [IndexPath.init(row: idx, section: 0)], with: .fade)
        }
        vm.bindData(to: tableView)
    }

}

/**
 * Help cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class HelpCell: UITableViewCell {
    
    /// outlets
    @IBOutlet weak var checkmark: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
}
