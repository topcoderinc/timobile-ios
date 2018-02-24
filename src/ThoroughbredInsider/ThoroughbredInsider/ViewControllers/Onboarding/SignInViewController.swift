//
//  SignInViewController.swift
//  SocialBike
//
//  Created by TCCODER on 9/3/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SignInViewController: UIViewController {

    /// outlets
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoOffset: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    
    /**
     view did load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        passwordField.returnKeyType = .go
        
        if isIphone5OrLess {
            logoOffset.constant = -43
        }
        
        Observable.combineLatest(loginField.rx.text, passwordField.rx.text)
            .subscribe(onNext: { [weak self] value, pwd in
                self?.errorLabel.isHidden = true
            }).disposed(by: rx.bag)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: " ", style: .plain, target: nil, action: nil)
    }
    
    /// View will appear
    ///
    /// - Parameter animated: the animation flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        makeTransparentNavigationBar()
    }
    
    /// View did appear
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cleanNavigationStack()
        if let _ = TokenUtil.accessToken {
            RestDataSource.restoreSession()
                .showLoading(on: view)
                .subscribe(onNext: { value in
                    Storyboards.showHome()
                }).disposed(by: rx.bag)
        }
    }

    // MARK: - actions
    
    /// login button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func loginTapped(_ sender: Any) {
        guard loginField.textValue.isValidEmail && !passwordField.textValue.isEmpty else {
            errorLabel.isHidden = false
            return
        }
        loginField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        RestDataSource.login(username: loginField.textValue, password: passwordField.textValue)
            .showLoading(on: view, showAlertOnError: false)
            .subscribe(onNext: { [weak self] value in
                Storyboards.showHome()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    //clear fields
                    self?.loginField.text = nil
                    self?.passwordField.text = nil
                }
                }, onError: { [weak self] error in
                    self?.errorLabel.isHidden = false
            }).disposed(by: rx.bag)
    }
    
    /**
     forgot password tap handler
     
     - parameter sender: the button
     */
    @IBAction func forgotTapped(_ sender: UIButton) {
        showStub()
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
        showStub()
    }
    
    
}
