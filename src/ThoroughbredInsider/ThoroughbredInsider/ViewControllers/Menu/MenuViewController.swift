//
//  MenuViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
Menu items
*/
enum MenuItem {
    case dashboard
    case bookmark
    case points
    case shop
    case profile
    case help
    case logout
}

/**
menu structure
*/
class Menu {
    /// item
    let item: MenuItem
    /// item name
    let name: String
    /// item icon
    let icon: UIImage?
    /// controller name
    var controllerName: String
    /// storyboard
    var storyboard: Storyboards?
    
    init(item: MenuItem, name: String, icon: UIImage? = nil, controllerName: String, storyboard: Storyboards? = nil) {
        self.item = item
        self.name = name
        self.icon = icon
        self.controllerName = controllerName
        self.storyboard = storyboard
    }
}

/**
menu section
*/
struct MenuSection  {
    /// name
    var name: String
    /// items
    let items: [MenuItem]
}


/**
 * menu view controller
 *
 * - author: TCCODER
 * - version: 1.0
 */
class MenuViewController: UIViewController {

    /// outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    /// connection status
    var offline = false {
        didSet {
            tableView?.reloadData()
        }
    }

    /// selected item
    var selected: IndexPath?
    
    /// the menus
    let menus: [MenuItem: Menu] = [
        .dashboard				: Menu(item: .dashboard, name: "Story Selection".localized, controllerName: !UserDefaults.firstStoryLaunch ? PreStoryViewController.className : StoryViewController.className),
        .bookmark          : Menu(item: .bookmark, name: "My Bookmark".localized, controllerName: BookmarkedViewController.className),
        .points              : Menu(item: .points, name: "TI Points".localized, controllerName: TIPointsViewController.className, storyboard: .points),
        .shop              : Menu(item: .shop, name: "Rewards Shop".localized, controllerName: ShopViewController.className, storyboard: .shop),
        .profile              : Menu(item: .profile, name: "Profile Summary".localized, controllerName: ProfileViewController.className, storyboard: .profile),
        .help              : Menu(item: .help, name: "Help".localized, controllerName: HelpViewController.className, storyboard: .help),
        .logout             : Menu(item: .logout, name: "Log Out".localized, controllerName: "")
    ]

    /// the sections
    var sections: [MenuSection] = []

    /**
    View did load
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .clear
        view.backgroundColor = .clear
        
        sections = [
            MenuSection(name: "", items: [.dashboard, .bookmark, .points, .shop, .profile, .help, .logout]),
        ]
        selected = IndexPath.init(row: 0, section: 0)
        
        RestDataSource.getUser()
            .showLoading(on: userImage)
            .store()
            .disposed(by: rx.bag)
        
        User.get(with: UserDefaults.loggedUserId)
            .subscribe(onNext: { [weak self] (value: User) in
                self?.usernameLabel.text = value.name
                self?.emailLabel.text = value.email
                self?.userImage.load(url: value.image)
        }).disposed(by: rx.bag)
    }

    /**
     Create content controller at index.
     
     - parameter index: The index
     
     - returns: the controller.
     */
    func createContentControllerAtIndex(_ index: IndexPath) -> UIViewController? {
        return createContentControllerForItem(sections[index.section].items[index.row])
    }
    
    /**
     Create controller for item.
     
     - parameter item: The item
     
     - returns: the controller.
     */
    func createContentControllerForItem(_ item: MenuItem) -> UIViewController? {
        if let menu = self.menus[item] {
            if let storyboard = menu.storyboard {
                let controller = storyboard.instantiate.instantiateViewController(withIdentifier: menu.controllerName)
                return controller
            } else {
                if menu.controllerName == PreStoryViewController.className {
                    menu.controllerName = !UserDefaults.firstStoryLaunch ? PreStoryViewController.className : StoryViewController.className
                }
                let controller = storyboard?.instantiateViewController(withIdentifier: menu.controllerName)
                if let controller = controller {
                    return controller
                }
            }
        }
        return nil
    }
    
    /// close button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func closeTapped(_ sender: Any) {
        slideMenuController?.animate(false)
    }
    
    /// selects menu
    ///
    /// - Parameter menu: the menu item
    func select(menu: MenuItem) {
        guard let idx = self.sections[0].items.enumerated().filter({ $0.element == menu }).first else { return }
        selected = IndexPath.init(row: idx.offset, section: 0)
        if let controller = createContentControllerForItem(menu) {
            self.slideMenuController?.setContentViewController(controller)
        }
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MenuViewController : UITableViewDataSource, UITableViewDelegate {
    
    /// number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    /// number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    /// configure cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getCell(indexPath, ofClass: MenuTableViewCell.self)
        let menu = self.menus[self.sections[indexPath.section].items[indexPath.row]]
        cell.menu = menu
        cell.contentView.backgroundColor = tableView.backgroundColor
        cell.backgroundColor = tableView.backgroundColor
        cell.selectionView.isHidden = selected?.row != indexPath.row
        return cell
    }

    /// section header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    /// cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.5
    }
    
    /// cell selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menu = self.menus[self.sections[indexPath.section].items[indexPath.row]]
        
        if menu?.item == .logout {
            DispatchQueue.main.async {
                self.slideMenuController?.confirmLogout()
            }
        } else if !menu!.controllerName.isEmpty {
            if let controller = createContentControllerAtIndex(indexPath) {
                self.slideMenuController?.setContentViewController(controller)
            }
            selected = indexPath
        }
		tableView.reloadData()
    }
}
