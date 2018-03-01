//
//  ProfileChangePasswordTableViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/24/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Change password screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ProfileChangePasswordTableViewController: UITableViewController, UITextFieldDelegate {

    /// outlets
    @IBOutlet weak var oldPasswordField: UnderlineTextField!
    @IBOutlet weak var newPasswordField: UnderlineTextField!
    @IBOutlet weak var confirmPasswordField: UnderlineTextField!
    @IBOutlet weak var updateButton: UIButton!

    /// the callback to invoke when password changed
    var callback: ((String)->())?

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        addBackButton()
    }

    /// View will appear
    ///
    /// - Parameter animated: the animation flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        revertTransparentNavigationBar()
        updateButton.backgroundColor = UIColor.purple
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        oldPasswordField.becomeFirstResponder()
    }

    /// customize header
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.from(hexString: "ececec")
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.textDark
        header.textLabel?.font = UIFont(name: "OpenSans-Semibold", size: 12)
    }

    /// "Update Password" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func updateAction(_ sender: Any) {
        var errors = [String]()
        if oldPasswordField.textValue.isEmpty {
            errors.append(NSLocalizedString("Old password cannot be empty", comment: "Old password cannot be empty"))
        }
        else if newPasswordField.textValue.isEmpty {
            errors.append(NSLocalizedString("New password cannot be empty", comment: "New password cannot be empty"))
        }
        else if confirmPasswordField.textValue.isEmpty {
            errors.append(NSLocalizedString("Confirm password cannot be empty", comment: "Confirm password cannot be empty"))
        }
        self.view.endEditing(true)
        guard errors.isEmpty else {
            let errorMessage = errors.joined(separator: "\n")
            showError(errorMessage: errorMessage)
            return
        }

        self.updateButton.isEnabled = false
        let loadingView = showLoadingView()
        let password = newPasswordField.textValue
        RestServiceApi.shared.updatePassword(oldPassword: oldPasswordField.textValue, newPassword: newPasswordField.textValue, confirmPassword: confirmPasswordField.textValue, callback: { [weak self] in
            loadingView?.terminate()
            self?.navigationController?.popViewController(animated: true)
            let callback = self?.callback
            delay(0.3) {
                callback?(password)
            }
        }, failure: { [weak self] error in
            loadingView?.terminate()
            showError(errorMessage: error)
            self?.updateButton.isEnabled = true
        })
    }

    // MARK: - UITextFieldDelegate

    /// Move to next field or submit form
    ///
    /// - Parameter textField: the textField
    /// - Returns: true
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == oldPasswordField {
            newPasswordField.becomeFirstResponder()
        }
        else if textField == newPasswordField {
            confirmPasswordField.becomeFirstResponder()
        }
        else if textField == confirmPasswordField {
            confirmPasswordField.resignFirstResponder()
            delay(0.3) {
                self.updateAction(self)
            }
        }
        return true
    }
}
