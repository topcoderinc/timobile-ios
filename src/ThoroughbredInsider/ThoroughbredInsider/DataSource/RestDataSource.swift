//
//  RestDataSource.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/29/17.
//  Copyright © 2017 topcoder. All rights reserved.
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


/**
 * REST data source implementation
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RestDataSource {
    
    /// mock user id
    static private let mockUserId = 1
    
    /// performs login
    ///
    /// - Parameters:
    ///   - username: username
    ///   - password: password
    /// - Returns: call observable
    static func login(username: String, password: String) -> Observable<Void> {
        let allGood = username == Configuration.testEmail && password == Configuration.testPassword
        let result = allGood  ? Observable.just(()) : Observable.error("Wrong credentials")
        if allGood {
            UserDefaults.loggedUserId = mockUserId
        }
        return result.restSend()
    }
    
    /// restore session
    ///
    /// - Parameter id: session id
    static func restoreSession(id: Int) -> Observable<Void> {
        guard id > 0 else { return Observable.error("Invalid session") }
        return Observable.just(()).restSend()
    }
    
    /// logout
    static func logout() -> Observable<Void> {
        UserDefaults.loggedUserId = -1
        return Observable.just(()).restSend()
    }
    
    /// gets states
    ///
    /// - Returns: call observable
    static func getStates() -> Observable<[State]> {
        return load(json: "states")
            .map { json in
                let items = json["items"].arrayValue
                return items.map { State(value: $0.object) }
        }
    }
    
    /// gets racetracks
    ///
    /// - Returns: call observable
    static func getRacetracks() -> Observable<[Racetrack]> {
        return load(json: "racetracks")
            .map { json in
                let items = json["items"].arrayValue
                return items.map { Racetrack(value: $0.object) }
        }
    }
    
    /// gets stories
    ///
    /// - Returns: call observable
    static func getStories(query: String = "") -> Observable<[Story]> {
        return load(json: "story list")
            .map { json in
                let items = json["stories"].arrayValue
                return items.map { Story(value: $0.object) }
        }
    }
    
    /// gets story details
    ///
    /// - Returns: call observable
    static func getStory(id: Int) -> Observable<StoryDetails> {
        return load(json: "story")
            .map { json in
                return StoryDetails(value: json["story"].object)
        }
    }
    
    /// gets story progress
    ///
    /// - Returns: call observable
    static func getStoryProgress(id: Int) -> Observable<[Chapter]> {
        return load(json: "story progress")
            .map { json in
                let items = json["story"]["chapters"].arrayValue
                return items.map { Chapter.create(json: $0) }
        }
    }
    
    /// gets story chapters
    ///
    /// - Returns: call observable
    static func getStoryChapters(id: Int) -> Observable<[Chapter]> {
        return load(json: "story chapter")
            .map { json in
                let items = json["chapter"].arrayValue
                return items.map { Chapter.create(json: $0) }
        }
    }
    
    /// gets story comments
    ///
    /// - Returns: call observable
    static func getStoryComments(id: Int) -> Observable<[Comment]> {
        return load(json: "comments")
            .map { json in
                let items = json["comments"].arrayValue
                return items.map { Comment(value: $0.object) }
        }
    }    
    
    /// gets story comments
    ///
    /// - Returns: call observable
    static func getUser() -> Observable<User> {
        return load(json: "profile")
            .map { json in
                User(value: json["profile"].object)
        }
    }
    
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
    
    /// API configuration
    static private let baseURL = Configuration.apiBaseURL.hasSuffix("/") ? Configuration.apiBaseURL : Configuration.apiBaseURL+"/"
    static private var accessToken: String?

    
    // MARK: - private
    
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
                
                #if HANDLE_LOGOUT
                    //                // If token expired
                    //                if result.response?.statusCode == 401 {
                    //                    AuthenticationUtil.shared.cleanUp()
                    //
                    //                    // notify
                    //                    if let rootVc = RootViewControllerInstance {
                    //                        rootVc.logout()
                    //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    //                            UIApplication.shared.keyWindow?.rootViewController?.showAlert("", ErrorMessages.sessionExpired.text)
                    //                        }
                    //                    }
                    //
                    //                    // do not trigger regular UI alert
                    //                    return Observable.just([:])
                    //                }
                    //                    // response value received
                    //                else
                #endif
                if let value = result.value {
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
}
