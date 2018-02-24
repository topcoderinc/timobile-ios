//
//  RequestPager.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/25/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import RealmSwift
import RxRealm
import RxCocoa
import RxSwift
import RxPager

/// pager for requests protocol
protocol RequestPagerProtocol {
    
    /// completed flag
    var isCompleted: Bool { get }
    
    /// trigger the next page
    func next()
    
}

/**
 * Adopted pager for requests
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RequestPager<T>: RequestPagerProtocol {
    
    /// page stream
    var page: Observable<PageResult<T>>!
    
    /// completed flag
    var isCompleted: Bool = false
    
    // trigger used to call next page
    private let trigger = PublishSubject<Void>()
    
    /// converts a request with offset/limit parameters to a pager
    ///
    /// - Parameter request: request
    init(request: @escaping (Int, Int) -> Observable<PageResult<T>>) {
        page = Observable.page(make: { (collection) -> Observable<PageResult<T>> in
            return request((collection?.offset ?? 0) + (collection?.items.count ?? 0), kDefaultLimit)
        }, while: { [weak self] (result) -> Bool in
            let hasNext = result.items.count + result.offset < result.total
            self?.isCompleted = !hasNext
            return hasNext
            }, when: trigger.asObservable())
    }
    
    /// trigger the next page
    func next() {
        trigger.onNext(())
    }
}

// MARK: - pager for realm objects extension
extension RequestPager where T: Object {
}
