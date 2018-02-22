//
//  LookupDataSource.swift
//  ThoroughbredInsider
//
//  Created by Nikita Rodin on 2/22/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


// MARK: - lookup methods
extension RestDataSource {

    /// gets states
    ///
    /// - Returns: call observable
    static func getStates(offset: Int = 0, limit: Int = kDefaultLimit) -> Observable<PageResult<State>> {
        return json(.get, "lookup/states", parameters: [
            "offset": offset,
            "limit": limit
            ])
            .map { json in
                let items = json["items"].arrayValue
                return PageResult(items: items.map { State(value: $0.object) },
                                  total: json["total"].intValue, offset: json["offset"].intValue, limit: json["limit"].intValue)
        }
        .restSend()
    }
    
    /// gets racetracks
    ///
    /// - Returns: call observable
    static func getRacetracks(offset: Int = 0, limit: Int = kDefaultLimit,
                              name: String? = nil, stateIds: String? = nil,
                              distanceToLocationMiles: Float? = nil, locationLat: Double? = nil, locationLng: Double? = nil,
                              sortColumn: String? = nil, sortOrder: String? = nil) -> Observable<PageResult<Racetrack>> {
        let parameters: [String: Any?] = [
            "offset": offset,
            "limit": limit,
            "name": name,
            "stateIds": stateIds,
            "distanceToLocationMiles": distanceToLocationMiles,
            "locationLat": locationLat,
            "locationLng": locationLng,
            "sortOrder": sortOrder,
            "sortColumn": sortColumn
        ]
        
        return json(.get, "racetracks", parameters: parameters.flattenValues())
            .map { json in
                let items = json["items"].arrayValue
                return PageResult(items: items.map { Racetrack(value: $0.object) },
                                  total: json["total"].intValue, offset: json["offset"].intValue, limit: json["limit"].intValue)
        }
        .restSend()
    }
    
}
