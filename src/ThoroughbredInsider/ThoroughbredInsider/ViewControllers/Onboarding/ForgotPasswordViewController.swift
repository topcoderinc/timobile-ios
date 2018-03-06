//
//  ForgotPasswordViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/24/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/**
 * Forgot password screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ForgotPasswordViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tokenField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var logoOffset: NSLayoutConstraint!
    
    /// user email
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        chain(textFields: [tokenField, passwordField]) { [unowned self] in
            self.updateTapped(self.updateButton)
        }
    }

    // MARK: - actions
    
    /**
     register
     
     - parameter sender: the button
     */
    @IBAction func updateTapped(_ sender: UIButton) {
        guard validateFieldNotEmpty(field: tokenField)
            && validateFieldNotEmpty(field: passwordField) else { return }
        
        view.endEditing(true)
        
        RestDataSource.resetPassword(token: tokenField.textValue, email: email, password: passwordField.textValue)
            .showLoading(on: view)
            .subscribe(onNext: { [weak self] value in
                
                self?.showAlert(title: "Success".localized, message: "Password reset succeeded.".localized, handler: { (_) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self?.navigationController?.popViewController(animated: true)
                    }
                })
                
                }, onError: { error in
            }).disposed(by: rx.bag)
    }

}
