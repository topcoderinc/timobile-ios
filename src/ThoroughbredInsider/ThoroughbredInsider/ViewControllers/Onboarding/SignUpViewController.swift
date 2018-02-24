//
//  SignUpViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 1/21/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/**
 * Sign up screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class SignUpViewController: UIViewController {
    
    /// outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var logoOffset: NSLayoutConstraint!
    
    /**
     view did load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        chain(textFields: [emailField, firstNameField, lastNameField, passwordField, passwordConfirmField]) { [unowned self] in
            self.signupTapped(self.signupButton)
        }
        
        if isIphone5OrLess {
            logoOffset.constant = -4
        }
    }
    
    // MARK: - actions
    
    /**
     register
     
     - parameter sender: the button
     */
    @IBAction func signupTapped(_ sender: UIButton) {
        guard validateFieldNotEmpty(field: firstNameField)
            && validateFieldNotEmpty(field: lastNameField)
            && validateFieldNotEmpty(field: emailField)
            && validateFieldNotEmpty(field: passwordField)
            && validateFieldNotEmpty(field: passwordConfirmField) else { return }

        guard passwordField.textValue == passwordConfirmField.textValue else {
            showErrorAlert(message: "Passwords don't match".localized)
            passwordField.becomeFirstResponder()
            return
        }
        guard emailField.textValue.isValidEmail else {
            showErrorAlert(message: "Invalid email format".localized)
            emailField.becomeFirstResponder()
            return
        }
        view.endEditing(true)
        
        RestDataSource.register(firstName: firstNameField.textValue, lastName: lastNameField.textValue, email: emailField.textValue, password: passwordField.textValue)
            .showLoading(on: view)
            .subscribe(onNext: { [weak self] value in
                
                self?.showAlert(title: "Sign up succeed".localized, message: "Thank you for sign up, an email has been already sent to your email box, please follow the email to verify your account.", handler: { (_) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self?.navigationController?.popViewController(animated: true)
                    }
                })
                
                }, onError: { error in
            }).disposed(by: rx.bag)
    }
    
}
