//
//  RealmCollectionViewModel.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 9/4/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift
import RxRealm

/**
 * Convenience viewmodel for collection view controllers
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RealmCollectionViewModel<ObjectClass: Object, CellClass: UICollectionViewCell>: NSObject {
    
    /// track latest values for convenience
    var entries = Variable<[ObjectClass]>([])
    
    /// selection handler
    var onSelect: ((_ index: Int, _ value: ObjectClass) -> ())?
    
    /// cell configuration
    var configureCell: ((_ index: Int, _ value: ObjectClass, _ values: [ObjectClass], _ cell: CellClass) -> ())?
    
    /// binds data to collection view
    ///
    /// - Parameter collectionView: collectionView to bind to
    /// - Parameter limit: limit count
    func bindData(to collectionView: UICollectionView, limit: Int? = nil) {
        guard let realm = try? Realm() else { return }
        var objects = Observable.array(from: realm.objects(ObjectClass.self)).share(replay: 1)
        if let limit = limit {
            objects = objects.map { $0.isEmpty ? $0 : Array($0[0..<min($0.count, limit)]) }
        }
        objects.bind(to: entries)
            .disposed(by: rx.bag)
        objects.bind(to: collectionView.rx.items(cellIdentifier: CellClass.className, cellType: CellClass.self)) { [weak self] index, value, cell in
            guard let strongSelf = self else { return }
            let values = strongSelf.entries.value
            strongSelf.configureCell?(index, value, values, cell)
            }.disposed(by: rx.bag)
        // handle selection
        collectionView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let strongSelf = self else { return }
            let values = strongSelf.entries.value
            strongSelf.onSelect?(indexPath.row, values[indexPath.row])
        }).disposed(by: rx.bag)
    }
}
