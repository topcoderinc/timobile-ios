//
//  StoryCompleteViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/**
 * story completed screen
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - model object changes support
 * - API integration related changes
 */
class StoryCompleteViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var cardsDescription: UILabel!
    
    /// story details
    var story: Story!
    /// the cards to show
    var cards = [Card]()
    
    /// viewmodels
    var rewardsVM = CollectionViewModel<Card, RewardCell>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize.width = (SCREEN_SIZE.width - 100) / 3
        let title = String(format: NSLocalizedString("Congratulations!\nYou got %d trading %@!", comment: "Congratulations!\nYou got %d trading %@!"),
                           story.cards.count, (story.cards.count == 1 ? NSLocalizedString("card", comment: "card") : NSLocalizedString("cards", comment: "cards")))
        titleLabel.text = title
        rewardsVM.configureCell = { _, value, _, cell in
            cell.titleLabel.text = value.name
            cell.rewardImage.load(url: value.imageURL)
        }
        let rewards = self.cards
        let font = cardsDescription.font!
        let bold = UIFont(name: "OpenSans-Bold", size: 14.0)!
        let attributedString = NSMutableAttributedString(string: "Wow! You have unlocked ", attributes: [.font: font])
        let texts = rewards.map { NSAttributedString(string: $0.name, attributes: [.font: bold]) }
        for t in texts.enumerated() {
            attributedString.append(t.element)
            if t.offset < texts.count-1 {
                attributedString.append(NSAttributedString(string:", ", attributes: [.font: font]))
            }
        }
        attributedString.append(NSAttributedString(string:".\nCheck your trading card gallery for details!", attributes: [.font: font]))
        cardsDescription.attributedText = attributedString
        
        rewardsVM.bindData(to: collection)
        rewardsVM.entries.value = rewards
        
        Observable.just([]).delaySubscription(1.25, scheduler: MainScheduler.instance)
            .showLoading(on: view)
            .subscribe(onNext: { value in
                
            }).disposed(by: rx.bag)
    }
    
    /// back button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /// main menu button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func backToMenuTapped(_ sender: Any) {
        _ = (presentingViewController as? ContainerViewController)?.slideController?.containerNavigationController.popViewController(animated: false)
        dismiss(animated: true, completion: nil)
    }
    
}
