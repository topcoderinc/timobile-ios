//
//  StoryViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit

/// Possible sorting types
enum StorySortingType: String {
    case nearest = "distance", alphabetical = "title"
}

/**
 * Story container screen
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - API integration
 */
class StoryViewController: RootViewController {

    /// outlets
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var listContainerView: UIView!
    @IBOutlet weak var toggleButton: UIBarButtonItem!
    @IBOutlet weak var leftFilterLabel: UILabel!
    @IBOutlet weak var leftFilterIcon: UIImageView!
    @IBOutlet weak var rightFilterLabel: UILabel!
    @IBOutlet weak var rightFilterIcon: UIImageView!

    /// racetracks
    var racetracks: [Racetrack]? {
        didSet {
            leftFilterLabel?.text = racetracks?.first?.name ?? "All Racetracks".localized
        }
    }
    
    /// sort
    private var sort: StorySortingType = .nearest

    /// the last search string
    private var query: String = ""
    
    /// children
    private var listVC: StoryListViewController!
    private var mapVC: StoryMapViewController!
    private var searchVC: StorySearchViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        listVC = create(viewController: StoryListViewController.self)
        self.listVC.setRacetrackFilter(racetracks, reload: false)
        loadChildController(listVC, inContentView: listContainerView)
        if let racetracks = racetracks { // needed to update the label
            self.racetracks = racetracks
        }
    }

    // MARK: - actions
    /// map button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func toggleTapped(_ sender: Any) {
        if mapContainerView.isHidden {
            if mapVC == nil {
                mapVC = create(viewController: StoryMapViewController.self)
                let ids = self.racetracks == nil ? [] : self.racetracks!.map({"\($0.id)"})
                mapVC.filter = StoryFilter(title: "", racetrackIds: ids, tagIds: [], location: nil)
                mapVC.sorting = self.sort
                mapVC.query.value = self.query
                loadChildController(mapVC, inContentView: mapContainerView)
            }
            
            UIView.transition(with: view, duration: 0.3, options: .transitionFlipFromRight, animations: {
                self.mapContainerView.isHidden = false
                self.listContainerView.isHidden = true
                self.view.bringSubview(toFront: self.mapContainerView)
            }) { (_) in
                self.toggleButton.image = #imageLiteral(resourceName: "navIconList")
            }
        }
        else {
            UIView.transition(with: view, duration: 0.3, options: .transitionFlipFromRight, animations: {
                self.mapContainerView.isHidden = true
                self.listContainerView.isHidden = false
                self.view.bringSubview(toFront: self.listContainerView)
            }) { (_) in
                self.toggleButton.image = #imageLiteral(resourceName: "navIconMap")
            }
        }
        
    }
    
    /// search button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func searchAction(_ sender: Any) {
        if searchVC == nil {
            searchVC = create(viewController: StorySearchViewController.self)
        }
        loadChildController(searchVC, inContentView: view)
        
        let initialLeftBarButtons = navigationItem.leftBarButtonItems ?? []
        let initialRightBarButtons = navigationItem.rightBarButtonItems ?? []
        showSearchBar(placeholder: "Search Stories".localized, onDismiss: dismissSearch, onComplete: { [weak self] value in
            self?.listVC?.query.value = value
            self?.mapVC?.query.value = value
            self?.query = value
            RecentSearch.upsert(query: value)
        })
        searchVC.onSelect = { [weak self] value in
            self?.listVC?.query.value = value.query
            self?.mapVC?.query.value = value.query
            self?.query = value.query
            RecentSearch.upsert(query: value.query)
            self?.dismissSearch()
            self?.dismissSearchBar(initialLeftBarButtons: initialLeftBarButtons, initialRightBarButtons: initialRightBarButtons)
        }
    }
    
    /// dismiss search
    private func dismissSearch() {
        searchVC.removeFromParent()
    }
    
    /// left filter button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func leftFilterTapped(_ sender: Any) {
        guard let vc = create(viewController: StoryRacetrackPopupViewController.self) else { return }
        vc.selected = racetracks ?? []
        vc.onSelect = { [unowned self] track in
            let tracks = track != nil ? [track!] : nil
            self.racetracks = tracks
            self.listVC.setRacetrackFilter(tracks)
            self.mapVC?.setRacetrackFilter(tracks)
        }
        present(vc, animated: true, completion: nil)
    }
    
    /// right filter button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func rightFilterTapped(_ sender: Any) {
        guard LoadingView.lastLoadingView == nil else {
            return
        }
        switch sort {
        case .nearest:
            sort = .alphabetical
        default:
            sort = .nearest
        }
        rightFilterLabel.text = sort == .nearest ? "Nearest".localized : "Alphabetical".localized
        self.listVC.setSorting(sort)
        self.mapVC?.setSorting(sort)
    }
    
}

// MARK: - search extension
extension UIViewController {
    
    /// dismiss search bar in navigation bar
    func dismissSearchBar(initialLeftBarButtons: [UIBarButtonItem]? = nil, initialRightBarButtons: [UIBarButtonItem]? = nil) {
        navigationItem.leftBarButtonItems = initialLeftBarButtons
        navigationItem.rightBarButtonItems = initialRightBarButtons
        navigationItem.titleView = nil
    }
    
    /// shows search bar in navigation bar
    func showSearchBar(placeholder: String = "Search".localized, onDismiss: (()->())? = nil, onValue: ((String)->())? = nil, onComplete: ((String)->())? = nil) {
        /// prepare
        let initialLeftBarButtons = navigationItem.leftBarButtonItems ?? []
        let initialRightBarButtons = navigationItem.rightBarButtonItems ?? []
        let searchbar = CustomSearchBar(frame: CGRect(x: 6, y: 6, width: view.frame.width-12, height: 30))
        searchbar.autocapitalizationType = .none
        searchbar.showsCancelButton = true
        // present
        navigationItem.titleView = searchbar
        navigationItem.rightBarButtonItems = nil
        navigationItem.leftBarButtonItem = nil
        searchbar.becomeFirstResponder()
        searchbar.placeholder = placeholder
        searchbar.tintColor = UIColor.darkText
        // bind
        searchbar.rx.cancelButtonClicked
            .subscribe(onNext: { [weak self] value in
                onComplete?("")
                self?.dismissSearchBar(initialLeftBarButtons: initialLeftBarButtons, initialRightBarButtons: initialRightBarButtons)
                onDismiss?()
            }).disposed(by: rx.bag)
        searchbar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self, unowned searchbar] in
                let value = (searchbar.text ?? "").trim()
                onComplete?(value)
                self?.dismissSearchBar(initialLeftBarButtons: initialLeftBarButtons, initialRightBarButtons: initialRightBarButtons)
                onDismiss?()
            }).disposed(by: rx.bag)
        searchbar.rx.text.orEmpty.subscribe(onNext: { value in
            onValue?(value.trim())
        }).disposed(by: rx.bag)
    }
    
}

/**
 * custom search bar
 *
 * - author: TCCODER
 * - version: 1.0
 */
class CustomSearchBar: UISearchBar {

    /// layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let tf = subviews.first?.subviews.filter { $0 is UITextField }.first as? UITextField
        tf?.rightView = UIImageView(image: #imageLiteral(resourceName: "iconMic"))
        tf?.rightViewMode = .always
        tf?.font = UIFont(name: "OpenSans-Regular", size: 13)
    }
    
}
