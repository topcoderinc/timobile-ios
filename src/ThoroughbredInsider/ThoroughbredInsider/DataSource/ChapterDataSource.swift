//
//  ChapterDataSource.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/22/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire

// MARK: - chapter & story detail methods
extension RestDataSource {

    /// gets story progress
    ///
    /// - Parameter id: story id
    /// - Returns: call observable
    static func getStoryProgress(id: Int) -> Observable<StoryProgress> {
        return json(.get, "trackStories/\(id)/userProgress")
            .map { json in
                return StoryProgress(value: json.object)
        }
        .restSend()
    }
    
    /// update story progress
    ///
    /// - Parameter id: story progress id
    /// - Returns: call observable
    static func updateStoryProgress(id: Int, progress: StoryProgress) -> Observable<StoryProgress> {
        return json(.put, "currentUser/trackStoryUserProgress/\(id)", parameters: [
            "trackStoryId": progress.trackStoryId,
            "chaptersUserProgress": progress.chaptersUserProgress.toArray().map {
                [
                    "chapterId": $0.chapterId,
                    "wordsRead": $0.wordsRead,
                    "completed": $0.completed
                ]
            }
            ], encoding: JSONEncoding.default)
            .map { json in
                return StoryProgress(value: json.object)
        }
        .restSend()
    }
    
    /// complete story
    ///
    /// - Parameter id: story progress id
    /// - Returns: call observable
    static func completeStory(id: Int) -> Observable<StoryProgress> {
        return json(.put, "currentUser/trackStoryUserProgress/\(id)/complete")
            .map { json in
                return StoryProgress(value: json.object)
        }
        .restSend()
    }
    
    /// receive rewards for story
    ///
    /// - Parameter id: story progress id
    /// - Returns: call observable
    static func receiveRewards(id: Int) -> Observable<StoryReward> {
        return json(.put, "currentUser/trackStoryUserProgress/\(id)/receiveRewards")
            .map { json in
                return StoryReward(value: json.object)
            }
            .restSend()
    }
    
    /// complete additional task for story
    ///
    /// - Parameter id: story progress id
    /// - Returns: call observable
    static func completeAdditionalTask(id: Int) -> Observable<Void> {
        return json(.put, "currentUser/trackStoryUserProgress/\(id)/completeAdditionalTask")
            .toVoid()
            .restSend()
    }
    
}
