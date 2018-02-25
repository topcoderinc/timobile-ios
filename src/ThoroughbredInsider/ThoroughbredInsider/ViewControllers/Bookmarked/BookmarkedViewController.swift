//
//  BookmarkedViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 23/2/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import RealmSwift
import RxCocoa
import RxSwift

/**
 * My bookmarks
 *
 * - author: TCCODER
 * - version: 1.1
 * 1.1:
 * - updates for integration
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
            cell.storyImage.load(url: value.smallImageURL)
            cell.titleLabel.text = value.title
            cell.racetrackLabel.text = value.racetrack?.name
            cell.shortDescriptionLabel.text = "\(value.subtitle)\n\n\(value.summary)"
            cell.shortDescriptionLabel.setLineHeight(16)
            cell.chaptersLabel.text = "\(value.chapters.count) \("chapters".localized)"
            cell.cardsLabel.text = "\(value.cards.count) \("cards".localized)"
            cell.milesLabel.text = value.racetrack.distanceText
        }
        vm.onSelect = { [weak self] idx, value in
            guard let vc = self?.create(viewController: StoryDetailsViewController.self, storyboard: .details) else { return }
            vc.story = value
            self?.navigationController?.pushViewController(vc, animated: true)
            self?.tableView.deselectRow(at: IndexPath.init(row: idx, section: 0), animated: true)
        }
        vm.bindData(to: tableView, sortDescriptors: [SortDescriptor(keyPath: "title")], predicate: NSPredicate(format: "bookmarked = true"))
    }

}
