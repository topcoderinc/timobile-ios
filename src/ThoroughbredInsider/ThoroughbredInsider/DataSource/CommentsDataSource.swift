//
//  CommentsDataSource.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/22/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

// MARK: - comments methods
extension RestDataSource {
    
    /// gets story comments
    ///
    /// - Returns: call observable
    static func getStoryComments(offset: Int = 0, limit: Int = kDefaultLimit,
                           trackStoryId: Int? = nil, userId: Int? = nil, chapterId: Int? = nil,
                           sortColumn: String? = nil, sortOrder: String? = nil) -> Observable<PageResult<Comment>> {
        let parameters: [String: Any?] = [
            "offset": offset,
            "limit": limit,
            "trackStoryId": trackStoryId,
            "userId": userId,
            "chapterId": chapterId,
            "sortOrder": sortOrder,
            "sortColumn": sortColumn
        ]
        return json(.get, "comments", parameters: parameters.flattenValues())
            .map { json in
                let items = json["items"].arrayValue
                return PageResult(items: items.map { Comment(value: $0.objectWithConvertedDates()) },
                                  total: json["total"].intValue, offset: json["offset"].intValue, limit: json["limit"].intValue)
            }
            .restSend()
    }
    
    /// post a comment
    ///
    /// - Returns: call observable
    static func post(comment: Comment) -> Observable<Comment> {
        return json(.post, "comments", parameters: [
            "text": comment.text,
            "userId": comment.userId,
            "chapterId": comment.chapterId,
            "trackStoryId": comment.trackStoryId,
            "type": comment.type,
            ])
            .map { json in
                return Comment(value: json.objectWithConvertedDates())
            }
            .restSend()
    }
    
    /// deletes a comment
    ///
    /// - Returns: call observable
    static func delete(comment: Comment) -> Observable<Void> {
        return json(.delete, "comments/\(comment.id)")
            .toVoid()
            .restSend()
    }
    
}
