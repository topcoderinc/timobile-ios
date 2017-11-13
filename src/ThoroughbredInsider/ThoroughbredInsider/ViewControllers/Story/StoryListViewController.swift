//
//  StoryListViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/1/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift
import RxRealm

/**
 * Story list screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StoryListViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    
    /// search query
    var query = Variable<String>("")
    
    /// viewmodel
    var vm: RealmTableViewModel<Story, StoryCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupVM()
        
        query.asObservable()
            .subscribe(onNext: { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.setupVM(filter: value)
                strongSelf.loadData(from: MockDataSource.getStories(query: value))
            }).disposed(by: rx.bag)
    }
    
    /// configure vm
    ///
    /// - Parameter filter: current filter
    func setupVM(filter: String = "") {
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
        vm.bindData(to: tableView, sortDescriptors: [SortDescriptor(keyPath: "name")],
                    predicate: filter.trim().isEmpty ? nil : NSCompoundPredicate.init(orPredicateWithSubpredicates: [
                        NSPredicate(format: "name CONTAINS[cd] %@", filter),
                        NSPredicate(format: "content CONTAINS[cd] %@", filter),
                        NSPredicate(format: "race.name CONTAINS[cd] %@", filter),
                        ]))
    }

}

/**
 * Story list cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StoryCell: UITableViewCell {
    
    /// fields
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var racetrackLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var chaptersLabel: UILabel!
    @IBOutlet weak var cardsLabel: UILabel!
    @IBOutlet weak var milesLabel: UILabel!
}
