//
//  CollectionViewModel.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Modified by TCCODER on 2/23/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/**
 * Convenience viewmodel for collection view controllers
 *
 * - author: TCCODER
 * - version: 1.0
 */
class CollectionViewModel<ObjectClass, CellClass: UICollectionViewCell>: NSObject {
    
    /// initializer
    ///
    /// - Parameter value: initial values
    init(value: [ObjectClass] = []) {
        super.init()
        entries.value = value
    }
    
    /// update this variable to set content
    var entries = Variable<[ObjectClass]>([])
    
    /// selection handler
    var onSelect: ((_ index: Int, _ value: ObjectClass) -> ())?
    
    /// cell configuration
    var configureCell: ((_ index: Int, _ value: ObjectClass, _ values: [ObjectClass], _ cell: CellClass) -> ())?
    
    /// binds data to collection view
    ///
    /// - Parameter collectionView: collectionView to bind to
    func bindData(to collectionView: UICollectionView) {
        let objects = entries.asObservable()
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
