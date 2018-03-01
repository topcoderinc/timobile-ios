//
//  SignInViewController.swift
//  SocialBike
//
//  Created by TCCODER on 9/3/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIComponents
import RxCocoa
import RxSwift

/**
 * Sign In screen
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - API integration
 */
class SignInViewController: UIViewController, UITextFieldDelegate {

    /// outlets
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoOffset: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var logoBottomMargin: NSLayoutConstraint!

    /**
     view did load
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        errorLabel.text = ""
        loginButton.backgroundColor = UIColor.darkSkyBlue
        
        fixLayout()
        
        Observable.combineLatest(loginField.rx.text, passwordField.rx.text)
            .subscribe(onNext: { [weak self] value, pwd in
                self?.errorLabel.isHidden = true
            }).disposed(by: rx.bag)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: " ", style: .plain, target: nil, action: nil)
    }

    /// Fix layout
    internal func fixLayout() {
        if isIphone5OrLess {
            logoOffset.constant = -43
            logoBottomMargin?.constant = 44
        }
    }
    
    /// View will appear
    ///
    /// - Parameter animated: the animation flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    /// Setup navigation bar
    internal func setupNavigationBar() {
        makeTransparentNavigationBar()
    }
    
    /// View did appear
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        actionsAfterViewDidAppear()
    }

    /// The actions after view appear
    internal func actionsAfterViewDidAppear() {
        cleanNavigationStack()
        if AuthenticationUtil.sharedInstance.isAuthenticated() {
            Storyboards.showHome()
        }
    }

    // MARK: - actions
    
    /// login button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func loginTapped(_ sender: Any) {
        guard loginField.textValue.isValidEmail && !passwordField.textValue.isEmpty else {
            errorLabel.isHidden = false
            errorLabel.text = NSLocalizedString("Please enter correct email or password", comment: "Please enter correct email or password")
            self.loginButton.backgroundColor = UIColor.pink
            return
        }
        loginField.resignFirstResponder()
        passwordField.resignFirstResponder()

        self.loginButton.isEnabled = false
        let loadingView = showLoadingView()
        DispatchQueue.main.async {
            self.loginButton.isEnabled = true // enable button in non weak environment
        }
        RestServiceApi.shared.authenticate(username: loginField.textValue, password: passwordField.textValue, rememberPassword: true, callback: { [weak self](_) in
            loadingView?.terminate()
            Storyboards.showHome()
            delay(0.5) {
                //clear fields
                self?.loginField.text = nil
                self?.passwordField.text = nil
                self?.loginButton.isEnabled = true
            }
        }, failure: { [weak self] error in
            loadingView?.terminate()
            self?.errorLabel.text = error
            self?.errorLabel.isHidden = false
            self?.loginButton.backgroundColor = UIColor.pink
            self?.loginButton.isEnabled = true
        })
    }

    /**
     forgot password tap handler
     
     - parameter sender: the button
     */
    @IBAction func forgotTapped(_ sender: UIButton) {
        self.errorLabel.isHidden = true
        guard loginField.textValue.isValidEmail else {
            showErrorAlert(message: NSLocalizedString("You must enter a valid email address", comment: "You must enter a valid email address"))
            return
        }
        let email = loginField.textValue
        let loadingView = self.showLoadingView()
        sender.isEnabled = false
        self.view.endEditing(true)
        RestServiceApi.shared.forgotPassword(email: email, callback: {
            loadingView?.terminate()
            if let vc = self.create(viewController: ForgotPasswordViewController.self) {
                vc.email = self.loginField.textValue
                vc.callback = {
                    var message = NSLocalizedString("password update succeed", comment: "password update succeed")
                    if OPTION_CAPITALIZE_ERROR_MESSAGE {
                        message = message.capitalizeFirstWord()
                    }
                    self.showAlert("", message)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            sender.isEnabled = true
        }, failure: { [weak self] error in
            loadingView?.terminate()
            self?.errorLabel.text = error
            self?.errorLabel.isHidden = false
            sender.isEnabled = true
        })
    }
 
    /**
     facebook
     
     - parameter sender: the button
     */
    @IBAction func facebookTapped(_ sender: UIButton) {
        showStub()
    }
    
    /**
     sign up
     
     - parameter sender: the button
     */
    @IBAction func signupTapped(_ sender: UIButton) {
        if let vc = create(viewController: SignUpViewController.self) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - UITextFieldDelegate

    /// submit form of passwordField "Go" button tapped
    ///
    /// - Parameter textField: the textField
    /// - Returns: true
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginButton {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            passwordField.resignFirstResponder()
            delay(0.3) {
                self.loginTapped(self)
            }
        }
        return true
    }

    /// Show error message
    ///
    /// - Parameter error: the error message
    internal func showError(_ error: String) {
        if OPTION_SHOW_SIGN_UP_VALIDATION_ERROR_AS_POPUP {
            self.showErrorAlert(message: error)
        }
        else {
            self.errorLabel.text = error
            self.errorLabel.isHidden = false
        }
    }
}
