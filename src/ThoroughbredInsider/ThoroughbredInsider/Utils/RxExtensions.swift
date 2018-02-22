//
//  RxExtensions.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Copyright © 2017 topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx
import RealmSwift
import RxRealm
import RxPager

// MARK: - reactive extension for NSObject
extension Reactive where Base: NSObject {
    
    /// shorthand
    var bag: DisposeBag {
        return disposeBag
    }

}



// MARK: - bind store for object
extension Observable where Element: Object {
    
    /// binds self to store into realm in background
    ///
    /// - Returns: disposable
    func store() -> Disposable {
        let sink: AnyObserver<Element> = Realm.rx.add(update: true)
        return observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .bind(to: sink)
    }
    
}

// MARK: - observe single object changes
extension Reactive where Base: Object {
    
    /// observable for single object
    var observable: Observable<Base> {
        return Observable.from(object: base).share(replay: 1)
    }
    
}

// MARK: - bind store for sequence
extension Observable where Element: Sequence, Element.Iterator.Element: Object {
    
    /// binds self to store into realm in background
    ///
    /// - Returns: disposable
    func store() -> Disposable {
        return observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .bind(to: Realm.rx.add(update: true))
    }
    
}

// MARK: - helpers for view controllers
extension UIViewController {
    
    /// loads data from remote
    func loadData<O: Object>(from observable: Observable<O>) {
        observable.showLoading(on: view)
            .store()
            .disposed(by: rx.bag)
    }
    
    /// loads data from remote
    func loadData<S: Sequence>(from observable: Observable<S>) where S.Iterator.Element: Object {
        observable.showLoading(on: view)
            .store()
            .disposed(by: rx.bag)
    }
    
    /// loads data from remote
    func loadData<O: Object>(from observable: Observable<PageResult<O>>) {
        observable.showLoading(on: view)
            .map { $0.items }
            .store()
            .disposed(by: rx.bag)
    }
    
}

//// MARK: - Error
extension String : Error {}


// MARK: - flatten
extension Observable where Element: Optionable {
    
    /// flattens sequence
    ///
    /// - Returns: flattened observable
    func flatten() -> Observable<Element.Wrapped>  {
        return self
            .filter { e in
                switch e.value {
                case .some(_):
                    return true
                default:
                    return false
                }
            }
            .map { $0.value! }
        
    }
    
}
/// Optionable protocol exposes the subset of functionality required for flatten definition
protocol Optionable {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

/// extension for Optional provides the implementations for Optional enum
extension Optional : Optionable {
    var value: Wrapped? { get { return self } }
}


// MARK: - realm write transform
extension Reactive where Base: Object {
    
    /// wraps write as observable
    func write(transform: @escaping (Base) throws -> Void) -> Observable<Base> {
        let object = self.base
        return Observable.create({ obs -> Disposable in
            do {
                try object.realm?.write {
                    try transform(object)
                }
            }
            catch {
                obs.onError(error)
            }
            obs.onNext(object)
            obs.onCompleted()
            return Disposables.create()
        })
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .share(replay: 1)
    }
    
}

extension Observable where Element: Object {
    /// performs write updates on elements of observable sequence
    func write(transform: @escaping (Element) throws -> Void) -> Observable<Element> {
        return self
            .flatMap { $0.rx.write(transform: transform) }
    }
    
}

// MARK: - shorcuts
extension Observable {
    
    /// shows loading from NOW until error/completion/<optionally> next item; assumes observing on main scheduler
    ///
    /// - Parameter view: view to insert loader into
    /// - Parameter showAlertOnError: set to false to disable showing error alert
    /// - Returns: same observable
    func showLoading(on view: UIView, showAlertOnError: Bool = true, stopOnNext: Bool = false) -> Observable<Element> {
        let loader = LoadingView(parentView: view).show()
        return self.do(onNext: { _ in
            if stopOnNext {
                loader.terminate()
            }
        }, onError: { (error) in
            if showAlertOnError {
                showAlert(title: "Error".localized, message: error as? String ?? error.localizedDescription)
            }
            loader.terminate()
        }, onCompleted: {
            loader.terminate()
        })
    }
    
}

/**
 * Adopted pager for requests
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RequestPager<T: RandomAccessCollection> {
    
    /// page stream
    var page: Observable<T>!
    
    /// completed flag
    var isCompleted: Bool = false
    
    // trigger used to call next page
    private let trigger = PublishSubject<Void>()
    
    /// completed page count
    private var count: Int = 0
    
    /// converts a request with page/size parameters to a pager
    ///
    /// - Parameter request: request
    init(request: @escaping (Int, Int) -> Observable<T>) {
        page = Observable.page(make: { [weak self] (collection) -> Observable<T> in
            let completed = self?.count ?? 0
            self?.count = completed + 1
            return request(completed, kDefaultLimit)
            }, while: { [weak self] (collection) -> Bool in
                let size = collection.count
                let hasNext = Int(size) == kDefaultLimit // full page
                self?.isCompleted = !hasNext
                return hasNext
            }, when: trigger.asObservable())
    }
    
    /// trigger the next page
    func next() {
        trigger.onNext(())
    }
}

