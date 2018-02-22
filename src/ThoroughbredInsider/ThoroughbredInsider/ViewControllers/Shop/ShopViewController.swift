//
//  ShopViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/**
 * shop screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ShopViewController: RootViewController {

    /// outlets
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var ptsLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    
    /// viewmodels
    var rewardsVM = CollectionViewModel<Card, ShopCell>()
    
    /// search query
    var query = Variable<String>("")
    
    /// order
    private var orderByPoints = true {
        didSet {
            orderButton.setTitle(orderByPoints ? "Points" : "Name", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize.width = SCREEN_SIZE.width / 2
        
        loadData(from: RestDataSource.getShopItems())
        
        query.asObservable()
            .subscribe(onNext: { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.setupVM(filter: value)
            }).disposed(by: rx.bag)
    }
    
    /// configure vm
    ///
    /// - Parameter filter: current filter
    func setupVM(filter: String = "") {
        rewardsVM = CollectionViewModel<Card, ShopCell>()
        rewardsVM.configureCell = { _, value, _, cell in
            cell.titleLabel.text = value.name
            cell.rewardImage.contentMode = .scaleAspectFill
            cell.rewardImage.load(url: value.image)
            cell.ptsLabel.text = "\(value.pts) pts"
        }
        rewardsVM.onSelect = { [weak self] _, card in
            guard let vc = self?.create(viewController: ShopPopupViewController.self) else { return }
            vc.card = card
            self?.present(vc, animated: true, completion: nil)
        }
        
        var predicates = [NSPredicate(format: "pts > 0")]
        if !filter.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", filter))
        }
        
        Card.fetch(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
            .subscribe(onNext: { [weak self] (value: [Card]) in
                self?.rewardsVM.entries.value = value
            }).disposed(by: rx.bag)
        
        rewardsVM.bindData(to: collection)
    }

    /// order button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func orderTapped(_ sender: Any) {
        orderByPoints = !orderByPoints
    }
    
    /// search button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func searchTapped(_ sender: Any) {
        showSearchBar(placeholder: "Search Shop".localized, onValue: { [weak self] value in
            self?.query.value = value
        })
    }
}

/**
 * Shop item cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ShopCell: RewardCell {
    
    /// outlets
    @IBOutlet weak var ptsLabel: UILabel!
    
}
