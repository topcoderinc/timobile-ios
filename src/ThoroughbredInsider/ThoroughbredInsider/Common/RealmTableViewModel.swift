//
//  TableViewModel.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Modified by TCCODER on 23/2/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift
import RxRealm

/**
 * Convenience viewmodel for table view controllers
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RealmTableViewModel<ObjectClass: Object, CellClass: UITableViewCell>: NSObject {

    /// track latest values for convenience
    var entries = Variable<[ObjectClass]>([])
    
    /// selection handler
    var onSelect: ((_ index: Int, _ value: ObjectClass) -> ())?
    
    /// cell configuration
    var configureCell: ((_ index: Int, _ value: ObjectClass, _ values: [ObjectClass], _ cell: CellClass) -> ())?
    
    /// binds data to table view
    ///
    /// - Parameter tableView: tableView to bind to
    /// - Parameter limit: limit count
    /// - Parameter sortDescriptors: sort descriptors
    /// - Parameter predicate: filter predicate
    func bindData(to tableView: UITableView, limit: Int? = nil, sortDescriptors: [SortDescriptor]? = nil, predicate: NSPredicate? = nil) {
        guard let realm = try? Realm() else { return }
        let filteredObjects = predicate != nil ? realm.objects(ObjectClass.self).filter(predicate!) : realm.objects(ObjectClass.self)
        var objects = Observable.array(from: filteredObjects.sorted(by: sortDescriptors ?? [])).share(replay: 1)
        if let limit = limit {
            objects = objects.map { $0.isEmpty ? $0 : Array($0[0..<min($0.count, limit)]) }
        }
        bindData(to: tableView, sequence: objects)
    }
    
    /// binds data to table view
    ///
    /// - Parameter tableView: tableView to bind to
    /// - Parameter sequence: data sequence
    func bindData(to tableView: UITableView, sequence: Observable<[ObjectClass]>) {
        sequence.bind(to: entries)
            .disposed(by: rx.bag)
        sequence.bind(to: tableView.rx.items(cellIdentifier: CellClass.className, cellType: CellClass.self)) { [weak self] index, value, cell in
            guard let strongSelf = self else { return }
            let values = strongSelf.entries.value
            strongSelf.configureCell?(index, value, values, cell)
            }.disposed(by: rx.bag)
        // handle selection
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let strongSelf = self else { return }
            let values = strongSelf.entries.value
            strongSelf.onSelect?(indexPath.row, values[indexPath.row])
        }).disposed(by: rx.bag)
    }
    
}
