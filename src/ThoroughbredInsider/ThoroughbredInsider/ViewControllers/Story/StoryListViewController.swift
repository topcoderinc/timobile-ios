//
//  StoryListViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/1/17.
//  Copyright © 2018  topcoder. All rights reserved.
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
class StoryListViewController: InfiniteTableViewController {

    /// search query
    var query = Variable<String>("")
    
    /// viewmodel
    var vm: RealmTableViewModel<Story, StoryCell>!
    
    /// racetrack
    var racetrack: Variable<Racetrack?>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupVM()
        
        Observable.combineLatest(query.asObservable(), racetrack.asObservable())
            .subscribe(onNext: { [weak self] query, racetrack in
                guard let strongSelf = self else { return }
                strongSelf.setupVM(filter: query)
                strongSelf.setupPager(requestPager: RequestPager<Story>(request: { (offset, limit) in
                    RestDataSource.getStories(offset: offset, limit: limit, title: query.isEmpty ? nil : query, racetrackId: racetrack?.id)
                }))
            }).disposed(by: rx.bag)
        
        LocationManager.shared.startUpdatingLocation()
    }
    
    /// configure vm
    ///
    /// - Parameter filter: current filter
    func setupVM(filter: String = "") {
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
        
        var preds: [NSPredicate] = []
        if !filter.trim().isEmpty {
            preds.append(NSPredicate(format: "title CONTAINS[cd] %@", filter))
        }
        if let race = racetrack.value {
            preds.append(NSPredicate(format: "racetrack.id IN %@", [race.id]))
        }
        
        vm.bindData(to: tableView, sortDescriptors: [SortDescriptor(keyPath: "title")],
                    predicate: preds.isEmpty ? nil : NSCompoundPredicate(orPredicateWithSubpredicates: preds))
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
