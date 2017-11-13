//
//  MockDataSource.swift
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

/**
 * mock data source implementation
 *
 * - author: TCCODER
 * - version: 1.0
 */
class MockDataSource {
    
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
        return send(result: result)
    }
    
    /// restore session
    ///
    /// - Parameter id: session id
    static func restoreSession(id: Int) -> Observable<Void> {
        guard id > 0 else { return Observable.error("Invalid session") }
        return send(result: Observable.just(()))
    }
    
    /// logout
    static func logout() -> Observable<Void> {
        UserDefaults.loggedUserId = -1
        return send(result: Observable.just(()))
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
    
    // MARK: - private
    
    /// loads json
    ///
    /// - Parameter name: json name
    /// - Returns: json as observable
    private static func load(json name: String) -> Observable<JSON> {
        if let json = JSON.resource(named: name) {
            return send(result: Observable.just(json))
        }
        else {
            return Observable.error("No such resource")
        }
    }
    
    /// mocks remote call
    ///
    /// - Parameter result: call result
    /// - Returns: delayed call
    private static func send<T>(result: Observable<T>) -> Observable<T> {
        return result.delaySubscription(1.25, scheduler: MainScheduler.instance)
            .share(replay: 1)
    }
    
}
