//
//  RestDataSource.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/22/18.
//  Copyright © 2018 topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift
import SwiftyJSON
import RxRealm
import Alamofire
import RxAlamofire

/// Errors
enum ErrorMessages: String {
    case resourceNotFound = "Resource not found"
    case sessionExpired = "Your session has expired, please log in again"
    case unknown = "Unknown error"
    
    /// localized text
    var text: String {
        return rawValue.localized
    }
}

/// default limit
let kDefaultLimit = 10

/**
 * REST data source implementation
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RestDataSource {
    
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
    
    /// restore session
    ///
    /// - Parameter id: session id
    static func restoreSession() -> Observable<Void> {
        guard let _ = accessToken else { return Observable.error("Invalid session") }
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
    }
    
    // MARK: - mock methods
    
    /// gets story comments
    ///
    /// - Returns: call observable
    static func getAchievements(tab: TIPointsViewController.Tabs) -> Observable<[Achievement]> {
        return load(json: tab == .achievements ? "points achievemenrs" : "points daily tasks")
            .map { json in
                let items = json["achivements"].arrayValue
                return items.map { Achievement(value: $0.object) }
        }
    }
    
    /// gets shop items
    ///
    /// - Returns: call observable
    static func getShopItems() -> Observable<[Card]> {
        return load(json: "shop")
            .map { json in
                let items = json["cards"].arrayValue
                return items.map { Card(value: $0.object) }
        }
    }
    
    // MARK: - private

    /// API configuration
    static private let baseURL = Configuration.apiBaseUrl.hasSuffix("/") ? Configuration.apiBaseUrl : Configuration.apiBaseUrl+"/"
    static private var accessToken: String? {
        return TokenUtil.accessToken
    }

    
    /// loads json
    ///
    /// - Parameter name: json name
    /// - Returns: json as observable
    private static func load(json name: String) -> Observable<JSON> {
        if let json = JSON.resource(named: name) {
            return Observable.just(json).restSend()
        }
        else {
            return Observable.error("No such resource")
        }
    }
    
    /// json call shortcut
    ///
    /// - Parameters:
    ///   - method: request method
    ///   - url: relative url
    ///   - parameters: parameters
    ///   - encoding: parameters encoding
    ///   - headers: additional headers
    /// - Returns: request observable
    static func json(_ method: Alamofire.HTTPMethod,
                     _ url: URLConvertible,
                     parameters: [String: Any]? = nil,
                     encoding: ParameterEncoding = URLEncoding.default,
                     headers: [String: String]? = nil,
                     addAuthHeader: Bool = true
        )
        -> Observable<JSON>
    {
        var headers = headers ?? [:]
        if let token = accessToken, addAuthHeader {
            headers["Authorization"] = "Bearer \(token)"
        }
        return RxAlamofire
            .request(method, "\(baseURL)\(url)", parameters: parameters, encoding: encoding, headers: headers)
            .responseJSON()
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .default)) // process everything in background
            .flatMap { (result: DataResponse<Any>) -> Observable<Any> in
                
                if result.response?.statusCode == 401 {
                    TokenUtil.cleanup()
                    
                    // notify
                    if let vc = UIApplication.shared.delegate?.window??.rootViewController {
                        vc.dismiss(animated: true, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            vc.showAlert(title: "", message: ErrorMessages.sessionExpired.text)
                        }
                    }
                    
                    // do not trigger regular UI alert
                    return Observable.just([:])
                }
                // response value received
                else if let value = result.value {
                    #if DEBUG
                        print(value)
                    #endif
                    
                    // guard from error messages
                    guard let statusCode = result.response?.statusCode, 200...205 ~= statusCode else {
                        let message: Error? = JSON(value)["message"].string
                        return Observable.error(message ?? result.error ?? ErrorMessages.resourceNotFound.text)
                    }
                    // successful response
                    return Observable.just(value)
                }
                // no value even
                return Observable.error(result.error ?? ErrorMessages.resourceNotFound.text)
            }
            .map { JSON($0) }
    }
    
}

// MARK: - shortcut for REST service
extension Observable {
    
    /// wrap remote call in shareReplay & observe on main thread
    func restSend() -> Observable<Element> {
        return self.observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
    /// discard result type
    func toVoid() -> Observable<Void> {
        return self.map { _ in }
    }
}
