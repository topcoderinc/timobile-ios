//
//  SignUpViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/23/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents
import RxCocoa
import RxSwift

/// option: true - will show popup with error, false - will show error above the form
let OPTION_SHOW_SIGN_UP_VALIDATION_ERROR_AS_POPUP = true

/**
 * Sign Up
 *
 * - author: TCCODER
 * - version: 1.0
 */
class SignUpViewController: SignInViewController {

    /// outlets
    @IBOutlet weak var firstNameField: UnderlineTextField!
    @IBOutlet weak var lastNameField: UnderlineTextField!
    @IBOutlet weak var password2Field: UnderlineTextField!

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        self.errorLabel.text = ""
        Observable.combineLatest(firstNameField.rx.text, lastNameField.rx.text, password2Field.rx.text)
            .subscribe(onNext: { [weak self] v1, v2, v3 in
                self?.errorLabel.text = ""
                self?.errorLabel.isHidden = true
            }).disposed(by: rx.bag)
        addBackButton()
    }

    /// add navigation bar
    override internal func setupNavigationBar() {
        revertTransparentNavigationBar()
    }

    /// Skip clean up
    override func actionsAfterViewDidAppear() {
        // nothing to do
    }

    /// Fix layout
    internal override func fixLayout() {
        if isIphone5OrLess {
            logoBottomMargin?.constant = 10
        }
    }

    // MARK: - actions

    /// login button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction override func loginTapped(_ sender: Any) {
        self.errorLabel.text = ""
        var errors = [String]()
        if !loginField.textValue.isValidEmail {
            errors.append(loginField.textValue.trim().isEmpty ? "Email cannot be empty" : "Incorrect email")
        }
        if firstNameField.textValue.isEmpty {
            errors.append((firstNameField.placeholder ?? NSLocalizedString("First Name", comment: "First Name")) + " " + NSLocalizedString("cannot be empty", comment: "cannot be empty"))
        }
        if lastNameField.textValue.isEmpty {
            errors.append((lastNameField.placeholder ?? NSLocalizedString("Last Name", comment: "Last Name")) + " " + NSLocalizedString("cannot be empty", comment: "cannot be empty"))
        }
        if passwordField.textValue.isEmpty {
            errors.append((passwordField.placeholder ?? NSLocalizedString("New Password", comment: "New Password")) + " " + NSLocalizedString("cannot be empty", comment: "cannot be empty"))
        }
        if password2Field.textValue.isEmpty {
            errors.append((password2Field.placeholder ?? NSLocalizedString("Confirm Password", comment: "Confirm Password")) + " " + NSLocalizedString("cannot be empty", comment: "cannot be empty"))
        }
        self.view.endEditing(true)
        guard errors.isEmpty else {
            let errorMessage = errors.joined(separator: "\n")
            showError(errorMessage)
            return
        }

        let userInfo = UserInfo()
        userInfo.firstName = firstNameField.textValue
        userInfo.lastName = lastNameField.textValue
        userInfo.email = loginField.textValue
        userInfo.password = passwordField.textValue

        self.loginButton.isEnabled = false
        let loadingView = showLoadingView()
        RestServiceApi.shared.register(userInfo: userInfo, confirmPassword: password2Field.textValue, callback: { [weak self] (_) in
            loadingView?.terminate()
            let message = OPTION_USE_ANDROID_LIKE_MESSAGES ? "Thank you for sign up, an email already send to your email box, please follow the email to verify your account".localized :
                "Thank you for sign up, an email is sent to your email box, please follow the email to verify your account".localized
            self?.showAlert(NSLocalizedString("Sign up succeed", comment: "Sign up succeed"), message) {
                self?.navigationController?.popViewController(animated: true)
            }
        }, failure: { [weak self] error in
            loadingView?.terminate()
            self?.showError(error)
            self?.loginButton.isEnabled = true
        })
    }

    // MARK: - UITextFieldDelegate

    /// submit form of passwordField "Go" button tapped
    ///
    /// - Parameter textField: the textField
    /// - Returns: true
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delay(0) {
            if textField == self.loginField {
                self.firstNameField.becomeFirstResponder()
            }
            else if textField == self.firstNameField {
                self.lastNameField.becomeFirstResponder()
            }
            else if textField == self.lastNameField {
                self.password2Field.becomeFirstResponder()
            }
            else if textField == self.password2Field {
                self.passwordField.becomeFirstResponder()
            }
            else if textField == self.passwordField {
                self.passwordField.resignFirstResponder()
                delay(0.3) {
                    self.loginTapped(self)
                }
            }
        }
        return true
    }
}
