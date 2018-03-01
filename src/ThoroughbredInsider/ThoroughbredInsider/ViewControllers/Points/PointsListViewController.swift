//
//  PointsListViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import RealmSwift
import RxRealm

/**
 * points list
 *
 * - author: TCCODER
 * - version: 1.0
 */
class PointsListViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    
    /// the tab
    var tab: TIPointsViewController.Tabs = .achievements
    
    /// viewmodel
    var vm = RealmTableViewModel<Achievement, AchievementCell>()
    
    /// go shop handler
    var onGoShop: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        vm.configureCell = { _, value, _, cell in
            cell.titleLabel.text = value.name
            cell.descriptionLabel.text = value.content
            cell.iconButton.setImage(value.completed ? #imageLiteral(resourceName: "iconPoints") : #imageLiteral(resourceName: "iconPointsDisabled"), for: .normal)
            cell.redeemButton.isEnabled = value.completed
            cell.ptsLabel.text = "\(value.pts) pts"
        }
        vm.bindData(to: tableView, sortDescriptors: [SortDescriptor(keyPath: "completed", ascending: false)], predicate: NSPredicate(format: "isDaily = \(tab == .tasks ? "true" : "false")"))
        loadData(from: MockDataSource.getAchievements(tab: tab))
    }

    /// go shop button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func goShopTapped(_ sender: Any) {
        onGoShop?()
    }
}

/**
 * Achievement cell
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - minor change
 */
class AchievementCell: UITableViewCell {
    
    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var redeemButton: UIButton!
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var ptsLabel: UILabel!
    
    /// redeem button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func redeemTapped(_ sender: Any) {
        showStub()
    }
}
