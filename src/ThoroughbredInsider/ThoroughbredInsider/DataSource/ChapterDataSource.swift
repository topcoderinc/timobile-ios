//
//  ChapterDataSource.swift
//  ThoroughbredInsider
//
//  Created by Nikita Rodin on 2/22/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

// MARK: - chapter, story detail methods
extension RestDataSource {

    /// gets story progress
    ///
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
    /// - Returns: call observable
    static func updateStoryProgress(id: Int, progress: StoryProgress) -> Observable<StoryProgress> {
        return json(.put, "currentUser/trackStoryUserProgress/\(id)", parameters: progress.toDictionary() as? [String: Any])
            .map { json in
                return StoryProgress(value: json.object)
        }
        .restSend()
    }
    
    /// complete story
    ///
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
    /// - Returns: call observable
    static func completeAdditionalTask(id: Int) -> Observable<Void> {
        return json(.put, "currentUser/trackStoryUserProgress/\(id)/completeAdditionalTask")
            .toVoid()
            .restSend()
    }
    
}
