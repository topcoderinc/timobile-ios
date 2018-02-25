//
//  RxExtensions.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Modified by TCCODER on 23/2/18.
//  Copyright © 2018  topcoder. All rights reserved.
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
                DispatchQueue.main.async {
                    loader.terminate()
                }
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                if showAlertOnError {
                    showAlert(title: "Error".localized, message: error as? String ?? error.localizedDescription)
                }
                loader.terminate()
            }
        }, onCompleted: {
            DispatchQueue.main.async {
                loader.terminate()
            }
        })
    }
    
}

// MARK: - UIViewController extension
extension UIViewController {
    
    /// chains textfields to proceed between them one by one
    ///
    /// - Parameters:
    ///   - textFields: array of textFields
    ///   - lastReturnKey: last return key type
    ///   - lastHandler: handler for last return
    func chain(textFields: [UITextField], lastReturnKey: UIReturnKeyType = .send, lastHandler: (()->())? = nil) {
        let n = textFields.count
        for (i, tf) in textFields.enumerated() {
            if i < n-1 {
                tf.returnKeyType = .next
                tf.rx.controlEvent(.editingDidEndOnExit)
                    .subscribe(onNext: { value in
                        textFields[i+1].becomeFirstResponder()
                    }).disposed(by: rx.bag)
            }
            else {
                tf.returnKeyType = lastReturnKey
                tf.rx.controlEvent(.editingDidEndOnExit)
                    .subscribe(onNext: { value in
                        lastHandler?()
                    }).disposed(by: rx.bag)
            }
            
        }
    }
    
}
