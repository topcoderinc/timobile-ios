//
//  ProfileBagdesViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/**
 * badges screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ProfileBagdesViewController: UIViewController {

    /// user
    var user: Variable<User>!
    
    /// outlets
    @IBOutlet weak var collection: UICollectionView!
    
    /// viewmodels
    var rewardsVM = CollectionViewModel<Badge, RewardCell>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize.width = (SCREEN_SIZE.width - 100) / 3
        rewardsVM.configureCell = { _, value, _, cell in
            cell.titleLabel.text = value.name
            cell.rewardImage.image = value.isEarned ? #imageLiteral(resourceName: "iconBadge") : #imageLiteral(resourceName: "iconBadgeEmpty")
        }
        rewardsVM.onSelect = { [weak self] _, badge in
            guard let vc = self?.create(viewController: BadgePopupViewController.self) else { return }
            vc.badge = badge
            self?.present(vc, animated: true, completion: nil)
        }
        
        user.asObservable()
            .subscribe(onNext: { [weak self] value in
                self?.rewardsVM.entries.value = value.badgesList.toArray()
            }).disposed(by: rx.bag)
        
        rewardsVM.bindData(to: collection)
    }


}
