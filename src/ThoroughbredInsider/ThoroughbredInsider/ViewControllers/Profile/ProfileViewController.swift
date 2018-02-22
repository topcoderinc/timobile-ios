//
//  ProfileViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/**
 * Profile screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ProfileViewController: BasePagedViewController {

    /// achievements bar
    let kShrinkedAchievementsHeight: CGFloat = 50
    let kExpandedAchievementsHeight: CGFloat = 87
    
    /// outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var achivementsToggle: UIButton!
    @IBOutlet weak var achievementsView: UIView!
    @IBOutlet weak var achievementsOffset: NSLayoutConstraint!
    @IBOutlet weak var achievemetnsHeight: NSLayoutConstraint!
    @IBOutlet weak var badgesCount: UILabel!
    @IBOutlet weak var reviewsCount: UILabel!
    @IBOutlet weak var cardsCount: UILabel!
    @IBOutlet weak var storiesCount: UILabel!
    
    /// user
    private var user = Variable<User>(User())
    
    /// achivements toggle
    private var achievementsHidden = true {
        didSet {
            guard achievementsHidden != oldValue else { return }
            
            UIView.animate(withDuration: 0.2) {
                self.achievementsOffset.constant = self.achievementsHidden ? -self.kShrinkedAchievementsHeight : 0
                self.achievementsView.alpha = self.achievementsHidden ? 0 : 1
                self.achievemetnsHeight.constant = self.achievementsHidden ? self.kShrinkedAchievementsHeight : self.kExpandedAchievementsHeight
                self.achivementsToggle.setImage(self.achievementsHidden ? #imageLiteral(resourceName: "arrowDownLarge") : #imageLiteral(resourceName: "arrowUpLarge"), for: .normal)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    /// tabs
    enum Tabs: Int {
        case badges, cards
        
        /// title
        var title: String {
            switch self {
            case .badges:
                return "Badges".localized
            case .cards:
                return "Trading Cards".localized
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData(from: RestDataSource.getUser())
        User.get(with: UserDefaults.loggedUserId)
            .subscribe(onNext: { [weak self] (value: User) in
                self?.usernameLabel.text = value.name
                self?.emailLabel.text = value.email
                self?.userImage.load(url: value.image)
                self?.badgesCount.text = "\(value.badges)"
                self?.reviewsCount.text = "\(value.reviews)"
                self?.storiesCount.text = "\(value.stories)"
                self?.cardsCount.text = "\(value.cards)"
                self?.user.value = value
            }).disposed(by: rx.bag)
        
        makeTransparentNavigationBar()
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "navIconMenu"), style: .plain, target: self, action: #selector(menuTapped))
    }
    
    /// menu button tap handler
    @objc func menuTapped() {
        slideMenuController?.toggleSideMenu()
    }
    

    /// pages
    ///
    /// - Parameters:
    ///   - pagingController: the pagingController
    ///   - index: controller index
    /// - Returns: corresponding controller
    override func pagingController(_ pagingController: PagingController, contentViewControllerAtIndex index: Int) -> UIViewController? {
        guard let tab = Tabs(rawValue: index) else { return nil }
        switch tab {
        case .badges:
            let info = create(viewController: ProfileBagdesViewController.self)
            info?.user = user
            return info
        case .cards:
            let parts = create(viewController: ProfileCardsViewController.self)
            parts?.user = user
            return parts
        }
    }
    
    /// achievements button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func toggleAchievementsTapped(_ sender: Any) {
        achievementsHidden = !achievementsHidden
    }
    
    /// segue handler
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ProfileSettingsViewController {
            controller.user = user
        }
        else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

/**
 * Segment controller
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ProfileSegmentController: SegmentController {
    
    /// setup view
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabs: [ProfileViewController.Tabs] = [.badges, .cards]
        let titles = tabs.map { $0.title }
        segments = titles.map { .text($0) }
        constraintItemsToBounds = true
    }
    
    /// clear background
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        cell.backgroundColor = .clear
        return cell
    }
    
}
