//
//  StoryProgressViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2018  topcoder. All rights reserved.
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
    var progress = Variable<StoryProgress?>(nil)
    
    /// rewards tap handler
    var onRewardsTap: (()->())?
    
    /// selection handler
    var onSelect: ((Int)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupVM()
        RestDataSource.getStoryProgress(id: story.id)
            .showLoading(on: view)
            .subscribe(onNext: { value in
                
            }).disposed(by: rx.bag)
        
        Observable.combineLatest(vm.entries.asObservable(), progress.asObservable())
            .map { chapters, progress -> CGFloat in
                guard let progress = progress else { return 0 }
                let current = progress.chaptersUserProgress.map { CGFloat($0.wordsRead) }.reduce(0, +)
                let total = chapters.map { CGFloat($0.wordsCount) }.reduce(0, +)
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
        let objects = Observable.array(from: realm.objects(Chapter.self).filter("trackStoryId = %d", story.id).sorted(by: [SortDescriptor(keyPath: "id")])).share(replay: 1)
        realm.fetch(type: StoryProgress.self, predicate: NSPredicate(format: "trackStoryId = %d", story.id))
            .map { $0.last }        
            .bind(to: progress)
            .disposed(by: rx.bag)
        objects.bind(to: vm.entries)
            .disposed(by: rx.bag)
        vm.configureCell = { [weak self] _, value, _, cell in
            let current = self?.progress.value?.chaptersUserProgress.filter { $0.chapterId == value.id }.first
            let read = current?.wordsRead ?? 0
            cell.titleLabel.text = value.title
            cell.currentLabel.text = "\(read)"
            cell.totalLabel.text = "/\(value.wordsCount)"
            cell.progress.innerValue = CGFloat(read) / CGFloat(value.wordsCount)
            
            if read > 0 {
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
