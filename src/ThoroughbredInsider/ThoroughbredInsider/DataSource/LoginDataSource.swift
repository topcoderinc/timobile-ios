//
//  LoginDataSource.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/24/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

// MARK: - login related methods
extension RestDataSource {
    
    /// performs login
    ///
    /// - Parameters:
    ///   - username: username
    ///   - password: password
    /// - Returns: call observable
    static func login(username: String, password: String) -> Observable<Void> {
        return json(.post, "login", parameters: [
            "email": username,
            "password": password
            ])
            .do(onNext: { (json) in
                TokenUtil.store(accessToken: json["accessToken"].stringValue, until: json["accessTokenValidUntil"].stringValue)
            })
            .toVoid()
            .restSend()
    }
    
    /// registers a new user
    ///
    /// - Parameters:
    ///   - firstName: first Name
    ///   - lastName: last Name
    ///   - email: email
    ///   - password: password
    /// - Returns: call observable
    static func register(firstName: String, lastName: String, email: String, password: String) -> Observable<Void> {
        return json(.post, "signup", parameters: [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "password": password,
            ])
            .toVoid()
            .restSend()
    }
    
    /// requests reset token
    ///
    /// - Parameters:
    ///   - email: email
    /// - Returns: call observable
    static func initiateResetPassword(email: String) -> Observable<Void> {
        return json(.post, "initiateForgotPassword?email=\(email)")
            .toVoid()
            .restSend()
    }
    
    /// resets forgotten password
    ///
    /// - Parameters:
    ///   - token: forgot password token
    ///   - email: email
    ///   - password: password
    /// - Returns: call observable
    static func resetPassword(token: String, email: String, password: String) -> Observable<Void> {
        return json(.post, "changeForgotPassword", parameters: [
            "forgotPasswordToken": token,
            "email": email,
            "newPassword": password,
            ])
            .toVoid()
            .restSend()
    }
    
    /// restore session
    ///
    /// - Parameter id: session id
    static func restoreSession() -> Observable<Void> {
        guard let _ = TokenUtil.accessToken else { return Observable.error("Invalid session") }
        return Observable.just(())
    }
    
    /// logout
    static func logout() -> Observable<Void> {
        return json(.post, "logout")
            .do(onNext: { (_) in
                UserDefaults.loggedUserId = -1
                TokenUtil.cleanup()
            })
            .toVoid()
            .restSend()
    }
    
    /// gets current user
    ///
    /// - Returns: call observable
    static func getUser() -> Observable<User> {
        return json(.get, "currentUser")
            .map { json in
                User(value: json.object)
            }
            .restSend()
    }
    
}
