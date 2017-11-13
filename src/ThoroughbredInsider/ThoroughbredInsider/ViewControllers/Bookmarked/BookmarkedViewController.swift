//
//  BookmarkedViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit
import RealmSwift
import RxCocoa
import RxSwift

/**
 * My bookmarks
 *
 * - author: TCCODER
 * - version: 1.0
 */
class BookmarkedViewController: RootViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    
    /// viewmodel
    var vm: RealmTableViewModel<Story, StoryCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupVM()
    }
    
    /// configure vm
    ///
    /// - Parameter filter: current filter
    func setupVM() {
        vm = RealmTableViewModel<Story, StoryCell>()
        vm.configureCell = { _, value, _, cell in
            cell.storyImage.load(url: value.image)
            cell.titleLabel.text = value.name
            cell.racetrackLabel.text = value.race?.name
            cell.shortDescriptionLabel.text = value.content
            cell.shortDescriptionLabel.setLineHeight(16)
            cell.chaptersLabel.text = "\(value.chapters) \("chapters".localized)"
            cell.cardsLabel.text = "\(value.cards) \("cards".localized)"
            cell.milesLabel.text = "\(value.miles) \("miles".localized)"
        }
        vm.onSelect = { [weak self] idx, value in
            guard let vc = self?.create(viewController: StoryDetailsViewController.self, storyboard: .details) else { return }
            vc.story = value
            self?.navigationController?.pushViewController(vc, animated: true)
            self?.tableView.deselectRow(at: IndexPath.init(row: idx, section: 0), animated: true)
        }
        vm.bindData(to: tableView, sortDescriptors: [SortDescriptor(keyPath: "name")], predicate: NSPredicate(format: "bookmarked = true"))
    }

}
