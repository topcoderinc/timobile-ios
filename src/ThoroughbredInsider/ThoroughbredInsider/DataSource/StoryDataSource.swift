//
//  StoryDataSource.swift
//  ThoroughbredInsider
//
//  Created by Nikita Rodin on 2/22/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

// MARK: - story methods
extension RestDataSource {
    
    /// gets stories
    ///
    /// - Returns: call observable
    static func getStories(offset: Int = 0, limit: Int = kDefaultLimit,
                           title: String? = nil, racetrackId: String? = nil, racetrackIds: String? = nil, tagIds: String? = nil,
                           sortColumn: String? = nil, sortOrder: String? = nil) -> Observable<PageResult<Story>> {
        let parameters: [String: Any?] = [
            "offset": offset,
            "limit": limit,
            "title": title,
            "racetrackId": racetrackId,
            "racetrackIds": racetrackIds,
            "tagIds": tagIds,
            "sortOrder": sortOrder,
            "sortColumn": sortColumn
        ]
        return json(.get, "trackStories", parameters: parameters.flattenValues())
            .map { json in
                let items = json["items"].arrayValue
                return PageResult(items: items.map { Story(value: $0.object) },
                                  total: json["total"].intValue, offset: json["offset"].intValue, limit: json["limit"].intValue)
        }
        .restSend()
    }
    
    /// gets story details
    ///
    /// - Returns: call observable
    static func getStory(id: Int) -> Observable<StoryDetails> {
        return json(.get, "trackStories\(id)")
            .map { json in
                return StoryDetails(value: json.object)
        }
        .restSend()
    }
    
    
}
