//
//  StoryProgressViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit
import RealmSwift
import RxCocoa
import RxSwift
import UIComponents

/**
 * track progress screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StoryProgressViewController: UIViewController {

    /// outlets
    @IBOutlet weak var trackView: UIView!
    @IBOutlet weak var valueWidth: NSLayoutConstraint!
    @IBOutlet weak var valueDescription: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rewardsButton: RoundedButton!
    
    /// the story
    var story: StoryDetails!
    
    /// viewmodel
    var vm = TableViewModel<Chapter, ChapterCell>()
    
    /// rewards tap handler
    var onRewardsTap: (()->())?
    
    /// selection handler
    var onSelect: ((Int)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupVM()
        MockDataSource.getStoryProgress(id: story.id)
            .showLoading(on: view)
            .subscribe(onNext: { value in
                
            }).disposed(by: rx.bag)
        
        vm.entries.asObservable()
            .map { value -> CGFloat in
                let current = value.map { CGFloat($0.current) }.reduce(0, +)
                let total = value.map { CGFloat($0.total) }.reduce(0, +)
                return total > 0 ? current / total : 0
            }
            .subscribe(onNext: { [weak self] value in
                self?.valueWidth.constant = value * (self?.trackView.bounds.width ?? 0)
                self?.rewardsButton.isEnabled = abs(1-value) < 1e-5
            }).disposed(by: rx.bag)
    }
    
    /// configure vm
    ///
    /// - Parameter filter: current filter
    private func setupVM() {
        guard let realm = try? Realm() else { return }
        let objects = Observable.array(from: realm.objects(Chapter.self).filter("storyId = %d", story.id).sorted(by: [SortDescriptor(keyPath: "id")])).share(replay: 1)
        objects.bind(to: vm.entries)
            .disposed(by: rx.bag)
        vm.configureCell = { _, value, _, cell in
            cell.titleLabel.text = value.title
            cell.currentLabel.text = "\(value.current)"
            cell.totalLabel.text = "/\(value.total)"
            cell.progress.innerValue = CGFloat(value.current) / CGFloat(value.total)
            
            if value.current > 0 {
                cell.contentView.backgroundColor = UIColor.white
                cell.numberLabel.backgroundColor = UIColor.cerulean
                cell.currentLabel.textColor = UIColor.tealGreen
                cell.currentLabel.font = UIFont(name: "OpenSans-Semibold", size: 11.6)
            }
            else {
                cell.contentView.backgroundColor = UIColor.from(hexString: "e5eef3")
                cell.numberLabel.backgroundColor = UIColor.from(hexString: "b8b9b9")
                cell.currentLabel.textColor = UIColor.from(hexString: "b1b1b1")
                cell.currentLabel.font = UIFont(name: "OpenSans-Regular", size: 11.6)
            }
        }
        vm.onSelect = { [weak self] idx, _ in
            self?.onSelect?(idx)
        }
        vm.bindData(to: tableView)
    }

    /// background button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func bgTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /// collect button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func rewardTapped(_ sender: Any) {
        onRewardsTap?()
    }
    
}

/**
 * Chapter cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ChapterCell: UITableViewCell {
    
    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var progress: RadialProgressChart!
    
}
