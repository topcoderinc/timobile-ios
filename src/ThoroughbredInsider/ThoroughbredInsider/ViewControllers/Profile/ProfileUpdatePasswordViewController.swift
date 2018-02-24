//
//  ProfileUpdatePasswordViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/24/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/**
 * Update password screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ProfileUpdatePasswordViewController: UITableViewController {

    /// outlets
    @IBOutlet weak var oldPasswordField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        chain(textFields: [oldPasswordField, passwordField, passwordConfirmField]) { [unowned self] in
            self.updateTapped(self.updateButton)
        }
        tableView.backgroundView = bgView
    }

    // MARK: - actions
    
    /**
     register
     
     - parameter sender: the button
     */
    @IBAction func updateTapped(_ sender: UIButton) {
        guard validateFieldNotEmpty(field: oldPasswordField)
            && validateFieldNotEmpty(field: passwordField)
            && validateFieldNotEmpty(field: passwordConfirmField) else { return }
        
        guard passwordField.textValue == passwordConfirmField.textValue else {
            showErrorAlert(message: "Passwords don't match".localized)
            passwordField.becomeFirstResponder()
            return
        }
        view.endEditing(true)
        
        RestDataSource.updatePassword(oldPassword: oldPasswordField.textValue, newPassword: passwordField.textValue)
            .showLoading(on: view)
            .subscribe(onNext: { [weak self] value in
                
                self?.showAlert(title: "Success".localized, message: "Password update succeeded.".localized, handler: { (_) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self?.navigationController?.popViewController(animated: true)
                    }
                })
                
                }, onError: { error in
            }).disposed(by: rx.bag)
    }

    /// customize header
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.from(hexString: "ececec")
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.textDark
        header.textLabel?.font = UIFont(name: "OpenSans-Semibold", size: 12)
    }
    
}
