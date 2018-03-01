//
//  MockDataSource.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/29/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
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
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - unused methods removed
 */
class MockDataSource {
    
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
