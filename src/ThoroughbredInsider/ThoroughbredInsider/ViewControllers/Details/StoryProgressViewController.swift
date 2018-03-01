//
//  StoryProgressViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
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
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - API integration
 */
class StoryProgressViewController: UIViewController {

    /// outlets
    @IBOutlet weak var trackView: UIView!
    @IBOutlet weak var valueWidth: NSLayoutConstraint!
    @IBOutlet weak var valueDescription: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rewardsButton: RoundedButton!
    
    /// the story
    var story: Story!
    
    /// viewmodel
    var vm = InfiniteTableViewModel<Chapter, ChapterCell>()
    
    /// rewards tap handler
    var onRewardsTap: (()->())?
    
    /// selection handler
    var onSelect: ((Int)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        valueDescription.text = NSLocalizedString("You need to finish all chapters to unlock the rewards", comment: "You need to finish all chapters to unlock the rewards")
        setupVM()
    }

    /// Show progress
    ///
    /// - Parameter value: the list of chapters with progress
    private func showProgress(_ value: [Chapter]) {
        let current = value.map { CGFloat($0.progress?.wordsRead ?? 0) }.reduce(0, +)
        let total = value.map { CGFloat($0.wordsCount) }.reduce(0, +)
        let percent = total > 0 ? current / total : 0
        self.valueWidth.constant = percent * self.trackView.bounds.width
        self.rewardsButton.isEnabled = abs(1-percent) < 1e-5

        let completed = value.filter({($0.progress?.completed ?? false)}).count
        let nLeft = value.count - completed
        if nLeft > 0 {
            let message = String(format: NSLocalizedString("You need to finish %d %@ more to unlock the rewards", comment: "You need to finish %d %@ more to unlock the rewards"), nLeft, nLeft == 1 ? NSLocalizedString("chapter", comment: "chapter") : NSLocalizedString("chapters", comment: "chapters"))
            valueDescription.text = message
        }
        else {
            valueDescription.text = NSLocalizedString("You have finish all chapters to unlock the rewards", comment: "You have finish all chapters to unlock the rewards")
        }
    }
    
    /// configure vm
    ///
    /// - Parameter filter: current filter
    private func setupVM() {
        vm.configureCell = { _, value, _, cell in
            cell.titleLabel.text = value.title
            cell.currentLabel.text = "\(value.progress?.wordsRead ?? 0)"
            cell.totalLabel.text = "/\(value.wordsCount)"
            if let wordsRead = value.progress?.wordsRead {
                cell.progress.innerValue = CGFloat(wordsRead) / CGFloat(max(1, value.wordsCount))
            }
            else {
                cell.progress.innerValue = 0
            }
            
            if let wordsRead = value.progress?.wordsRead, wordsRead > 0 {
                cell.contentView.backgroundColor = UIColor.white
                cell.numberLabel.backgroundColor = UIColor.cerulean
                cell.currentLabel.textColor = UIColor.tealGreen
                cell.currentLabel.font = UIFont(name: "OpenSans-Semibold", size: 11.6)
                cell.checkmark.isHidden = wordsRead < value.wordsCount
            }
            else {
                cell.contentView.backgroundColor = UIColor.from(hexString: "e5eef3")
                cell.numberLabel.backgroundColor = UIColor.from(hexString: "b8b9b9")
                cell.currentLabel.textColor = UIColor.from(hexString: "b1b1b1")
                cell.currentLabel.font = UIFont(name: "OpenSans-Regular", size: 11.6)
                cell.checkmark.isHidden = true
            }
        }
        vm.onSelect = { [weak self] indexPath, _ in
            DispatchQueue.main.async {
                self?.onSelect?(indexPath.row)
            }
        }
        vm.fetchItems = { offset, _, callback, failure in
            if offset == nil {
                RestServiceApi.shared.getStoryProgress(for: self.story, callback: { (_) in
                    let chapters = self.story.chapters.toArray()
                    self.showProgress(chapters)
                    callback(chapters, chapters.count)
                }, failure: failure)
            }
            else {
                callback([], 0)
            }
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
    @IBOutlet weak var checkmark: UIImageView!

}
