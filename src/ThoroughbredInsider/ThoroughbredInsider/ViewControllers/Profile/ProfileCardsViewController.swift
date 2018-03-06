//
//  ProfileCardsViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/23/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/**
 * cards screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ProfileCardsViewController: UIViewController {

    /// user
    var user: Variable<User>!
    
    /// outlets
    @IBOutlet weak var collection: UICollectionView!
    
    /// viewmodels
    var rewardsVM = CollectionViewModel<Card, RewardCell>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize.width = (SCREEN_SIZE.width - 100) / 3
        rewardsVM.configureCell = { _, value, _, cell in
            cell.titleLabel.text = value.name
            if value.isEarned {
                cell.rewardImage.contentMode = .scaleAspectFill
                cell.rewardImage.load(url: value.imageURL)
            }
            else {
                cell.rewardImage.contentMode = .scaleAspectFit
                cell.rewardImage.image = #imageLiteral(resourceName: "logoWhite")
            }
        }
        rewardsVM.onSelect = { [weak self] _, card in
            guard let vc = self?.create(viewController: CardPopupViewController.self) else { return }
            vc.card = card
            self?.present(vc, animated: true, completion: nil)
        }
        
        user.asObservable()
            .subscribe(onNext: { [weak self] value in
                self?.rewardsVM.entries.value = value.tradingCards.toArray()
            }).disposed(by: rx.bag)
        
        rewardsVM.bindData(to: collection)
    }

}
