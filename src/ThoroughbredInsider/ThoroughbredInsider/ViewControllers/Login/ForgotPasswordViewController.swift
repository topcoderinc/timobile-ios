//
//  ForgotPasswordViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/24/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/// option: true - will use exact messages in popups as in Android, false - will use more correct messages
let OPTION_USE_ANDROID_LIKE_MESSAGES = false

/**
 * Sign Up
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ForgotPasswordViewController: SignInViewController {

    /// the related email
    var email: String!

    /// the success callback
    var callback: (()->())?

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        addBackButton()
    }

    /// add navigation bar
    override internal func setupNavigationBar() {
        revertTransparentNavigationBar()
    }

    /// Fix layout
    internal override func fixLayout() {
        if isIphone5OrLess {
            logoBottomMargin?.constant = 10
        }
    }

    /// Show popup message
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let message = OPTION_USE_ANDROID_LIKE_MESSAGES ? NSLocalizedString("An email with token already send to your email box, please check it", comment: "An email with token already send to your email box, please check it") : NSLocalizedString("An email with token is sent to your email box, please check it", comment: "An email with token is sent to your email box, please check it")
        self.showAlert(NSLocalizedString("Email successfully sent", comment: "Email successfully sent"), message)
    }

    /// Skip clean up
    override func actionsAfterViewDidAppear() {
        // nothing to do
    }

    // MARK: - Button actions

    /// - Parameter sender: the button
    /// "Set Password Action" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func setPasswordAction(_ sender: Any) {
        self.errorLabel.text = ""
        var errors = [String]()
        if loginField.textValue.isEmpty {
            errors.append(NSLocalizedString("Forgot password token cannot be empty", comment: "Forgot password token cannot be empty"))
        }
        if passwordField.textValue.isEmpty {
            errors.append((passwordField.placeholder ?? NSLocalizedString("New Password", comment: "New Password")) + " " + NSLocalizedString("cannot be empty", comment: "cannot be empty"))
        }
        self.view.endEditing(true)
        guard errors.isEmpty else {
            let errorMessage = errors.joined(separator: "\n")
            showError(errorMessage)
            return
        }
        self.loginButton.isEnabled = false
        let loadingView = showLoadingView()

        let token = loginField.textValue
        RestServiceApi.shared.resetPassword(email: email, newPassword: passwordField.textValue, token: token, callback: { [weak self] in
            loadingView?.terminate()
            self?.navigationController?.popViewController(animated: true)
            let callback = self?.callback
            delay(0.3) { callback?() }
        }, failure: { [weak self] error in
            loadingView?.terminate()
            self?.showError(error)
            self?.loginButton.isEnabled = true
        })
    }
}
