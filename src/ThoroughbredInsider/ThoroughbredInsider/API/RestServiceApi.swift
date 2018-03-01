//
//  RestServiceApi.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/21/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import RxSwift

/// the default limit used for some endpoints
let LIMIT_DEFAULT = 20

/// option: true - will capitalize first word in the error message received from the server, false - will show message as is.
let OPTION_CAPITALIZE_ERROR_MESSAGE = true

/// the list of server messages that need to be converted to correct human-readable messages
let SERVER_RESPONSES_USER_NOT_FOUND = "Not Found: \""
let SERVER_RESPONSE_NOT_PERMITTED = "An attempt was made to perform an operation that is not permitted: "
let SERVER_RESPONSE_INVALID_ARGUMENT = "Invalid or missing argument supplied: "

/// type alias for the callback used to return an occurred error
public typealias FailureCallback = (String)->()

/// error messages
let ERROR_EMPTY_CREDENTIALS = NSLocalizedString("Please provide valid username and password", comment: "Please provide valid username and password")
let ERROR_WRONG_CREDENTIALS = NSLocalizedString("The user is not found.", comment: "The user is not found.")
let ERROR_WRONG_CREDENTIALS_SIGNUP = NSLocalizedString("The credentials you entered are incorrect. Please fill the fields correctly.", comment: "The credentials you entered are incorrect. Please fill the fields correctly.")
let ERROR_PASSWORDS_NOT_MATCH = NSLocalizedString("The passwords do not match to each other", comment: "The passwords do not match to each other")
let ERROR_NEW_PASSWORDS_NOT_MATCH = NSLocalizedString("Confirm password must be equal to new password", comment: "Confirm password must be equal to new password")
let ERROR_WRONG_OLDPASSWORD = NSLocalizedString("The old password you entered is incorrect. Please try again.", comment: "The old password you entered is incorrect. Please try again.")
let ERROR_DIFFERENT_PASSWORDS = NSLocalizedString("New password should differ from the old password", comment: "New password should differ from the old password")

/**
 * RESTful data source implementation
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RestServiceApi: RESTApi {

    /// the singleton
    static let shared = RestServiceApi(baseUrl: Configuration.apiBaseUrl)

    // MARK: - Sign In/Up

    /// Authenticate using given username and password
    ///
    /// - Parameters:
    ///   - username: the username (email)
    ///   - password: the password
    ///   - rememberPassword: the flag used to enable autologin
    ///   - callback: the callback to invoke when successfully authenticated and return UserInfo
    ///   - failure: the callback to invoke when an error occurred
    func authenticate(username: String, password: String, rememberPassword: Bool, callback: @escaping (UserInfo) -> (), failure: @escaping FailureCallback) {
        let emptyStringCallback: FailureCallback = { (_) -> () in
            failure(ERROR_EMPTY_CREDENTIALS)
        }
        if !ValidationUtils.validateEmail(username, emptyStringCallback)
            || !ValidationUtils.validateStringNotEmpty(password, emptyStringCallback) {
            return
        }
        let parameters: [String: Any] = [
            "email": username,
            "password": password
        ]
        self.setAccessToken(nil)
        post("login", parameters: parameters, success: { (json) in

            self.setAccessToken(json["accessToken"].string)

            self.getCurrentUser(callback: { (user) in
                let userInfo = UserInfo()
                userInfo.id = user.id
                userInfo.firstName = user.firstName
                userInfo.lastName = user.lastName
                userInfo.email = user.email
                userInfo.profilePhotoURL = user.profilePhotoURL
                AuthenticationUtil.sharedInstance.isSocialLogin = false
                AuthenticationUtil.sharedInstance.rememberPassword = rememberPassword
                AuthenticationUtil.sharedInstance.userInfo = userInfo
                callback(userInfo)
            }, failure: failure)
        }, failure: createUserRelatedFailureCallback(failure))
    }

    /// Create callback that process errors and makes them human-readable
    ///
    /// - Parameter failure: the failure callback
    /// - Returns: the wrapped failure callback
    private func createUserRelatedFailureCallback(_ failure: @escaping FailureCallback) -> FailureCallback {
        return { error in
            var alternativeError: String?
            if error.hasPrefix(SERVER_RESPONSES_USER_NOT_FOUND) {
                alternativeError = error.replace(SERVER_RESPONSES_USER_NOT_FOUND, withString: "").replace("\"", withString: "")
            }
            else if error.hasPrefix(SERVER_RESPONSE_NOT_PERMITTED) {
                alternativeError = error.replace(SERVER_RESPONSE_NOT_PERMITTED, withString: "")
            }
            else if error.hasPrefix(SERVER_RESPONSE_INVALID_ARGUMENT) {
                alternativeError = error.replace(SERVER_RESPONSE_INVALID_ARGUMENT, withString: "")
            }
            if let error = alternativeError {
                if OPTION_CAPITALIZE_ERROR_MESSAGE { alternativeError = error.capitalizeFirstWord() }
                failure(alternativeError!)
            }
            else {
                failure(error)
            }
        }
    }

    /// Register account. Just assign random IDs.
    ///
    /// - Parameters:
    ///   - userInfo: the user info
    ///   - confirmPassword: the password from the second field
    ///   - failure: the failure callback to return an error
    func register(userInfo: UserInfo, confirmPassword: String, callback: @escaping (UserInfo) -> (), failure: @escaping FailureCallback) {
        let emptyStringCallback: FailureCallback = { (_) -> () in
            failure(ERROR_WRONG_CREDENTIALS_SIGNUP)
        }
        if !ValidationUtils.validateStringNotEmpty(userInfo.firstName, emptyStringCallback)
            || !ValidationUtils.validateStringNotEmpty(userInfo.lastName, emptyStringCallback)
            || !ValidationUtils.validateEmail(userInfo.email, failure)
            || !ValidationUtils.validateStringNotEmpty(userInfo.password, emptyStringCallback)
            || !ValidationUtils.validateStringNotEmpty(confirmPassword, emptyStringCallback) {
            return
        }
        else if userInfo.password != confirmPassword {
            failure(ERROR_PASSWORDS_NOT_MATCH)
            return
        }

        var parameters = userInfo.toUser().toParameters()
        parameters["password"] = userInfo.password

        post("signup", parameters: parameters, success: { json in
            userInfo.id = json["id"].intValue
            callback(userInfo)
        }, failure: failure)
    }

    /// Verify email. Will be used in future.
    ///
    /// - Parameters:
    ///   - email: the email
    ///   - token: the token
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func verifyEmail(email: String, token: String, callback: @escaping ()->(), failure: @escaping FailureCallback) {
        if !ValidationUtils.validateEmail(email, failure)
        || !ValidationUtils.validateStringNotEmpty(token, failure) {
            return
        }
        let parameters = ["email": email, "verificationToken": token]
        get("verifyEmail", parameters: parameters, success: {_ in callback()}, failure: createUserRelatedFailureCallback(failure))
    }

    /// Initiate password reset
    ///
    /// - Parameters:
    ///   - email: the email
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func forgotPassword(email: String, callback: @escaping ()->(), failure: @escaping FailureCallback) {
        if !ValidationUtils.validateEmail(email, failure) {
            return
        }
        post("initiateForgotPassword?email=\(email)", parameters: [:], success: {_ in callback()}, failure: createUserRelatedFailureCallback(failure))
    }

    /// Reset password
    ///
    /// - Parameters:
    ///   - email: the email
    ///   - newPassword: the new password
    ///   - token: the token
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func resetPassword(email: String, newPassword: String, token: String, callback: @escaping ()->(), failure: @escaping FailureCallback) {
        if !ValidationUtils.validateEmail(email, failure)
            || !ValidationUtils.validateStringNotEmpty(newPassword, failure)
            || !ValidationUtils.validateStringNotEmpty(token, failure) {
            return
        }
        let parameters = [
            "email": email,
            "forgotPasswordToken": token,
            "newPassword": newPassword
        ]
        post("changeForgotPassword", parameters: parameters, success: {_ in callback()}, failure: failure)
    }

    /// Update password
    ///
    /// - Parameters:
    ///   - oldPassword: the old password
    ///   - newPassword: the new password
    ///   - confirmPassword: the new password from the second field
    ///   - token: the token
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func updatePassword(oldPassword: String, newPassword: String, confirmPassword: String, callback: @escaping ()->(), failure: @escaping FailureCallback) {
        if !ValidationUtils.validateStringNotEmpty(oldPassword, failure)
            || !ValidationUtils.validateStringNotEmpty(newPassword, failure)
            || !ValidationUtils.validateStringNotEmpty(confirmPassword, failure) {
            return
        }
        else if newPassword != confirmPassword {
            failure(ERROR_NEW_PASSWORDS_NOT_MATCH)
            return
        }
        let parameters = [
            "oldPassword": oldPassword,
            "newPassword": newPassword
        ]
        put("updatePassword", parameters: parameters, success: {_ in callback()}, failure: createUserRelatedFailureCallback(failure))
    }

    /// Logout
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func logout(callback: @escaping ()->(), failure: @escaping FailureCallback) {
        post("logout", parameters: [:], success: {_ in
            self.setAccessToken(nil) // clean up token
            callback()
        }, failure: { error in
            self.setAccessToken(nil)
            failure(error)
        })
    }

    // MARK: - Lookups

    /// Get states
    ///
    /// - Parameters:
    ///   - name: the name
    ///   - offset: the offset of the items
    ///   - limit: the number of items to load
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getStates(name: String = "", offset: Any? = nil, limit: Int = LIMIT_DEFAULT, callback: @escaping ([State], Any)->(), failure: @escaping FailureCallback) {
        var parameters: [String: String] = [
            "offset": "\(nextPage(offset, limit))",
            "limit": "\(limit)"
        ]
        if !name.isEmpty { parameters["name"] = name }
        get("lookup/states", parameters: parameters, success: { json in
            let list = json["items"].arrayValue.map{State.fromJson($0)}
            let nextOffset = (offset as? Int ?? 0) + list.count
            callback(list, nextOffset)
        }, failure: failure)
    }

    // MARK: - Stories

    /// Search stories
    ///
    /// - Parameters:
    ///   - filter: the filter to apply
    ///   - offset: the offset of the items
    ///   - limit: the number of items to load
    ///   - sorting: the sorting type
    ///   - sortOrder: the sorting order
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func searchStories(filter: StoryFilter? = nil, sorting: StorySortingType? = nil, sortOrder: String? = nil,
                          offset: Any? = nil,
                          limit: Int = LIMIT_DEFAULT,
                          callback: @escaping ([Story], Any)->(), failure: @escaping FailureCallback) {

        var parameters: [String: String] = [
            "offset": "\(nextPage(offset, limit))",
            "limit": "\(limit)"
        ]
        if let sorting = sorting {
            parameters["sortColumn"] = sorting.rawValue
        }
        if let sortOrder = sortOrder {
            parameters["sortOrder"] = sortOrder
        }

        if let filter = filter {
            if !filter.title.isEmpty { parameters["title"] = filter.title }
            if !filter.tagIds.isEmpty { parameters["tagIds"] = filter.tagIds.joined(separator: ",") }
            if !filter.racetrackIds.isEmpty { parameters["racetrackId"] = filter.racetrackIds.joined(separator: ",") }
            if let location = filter.location { parameters["locationLat"] = "\(location.lat)"; parameters["locationLng"] = "\(location.lng)" }
        }

        get("trackStories", parameters: parameters, success: { (json) in
            let list = json["items"].arrayValue.map{Story.fromJson($0)}
            let nextOffset = (offset as? Int ?? 0) + list.count
            callback(list, nextOffset)
        }, failure: failure)
    }

    /// Search racetracks
    ///
    /// - Parameters:
    ///   - name: the name
    ///   - stateIds: the states
    ///   - distanceToLocationMiles: the distance ot location miles
    ///   - location: the location
    ///   - offset: the offset of the items
    ///   - limit: the number of items to load
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func searchRacetracks(name: String = "",
                          stateIds: [String] = [],
                          distanceToLocationMiles: Double? = nil,
                          location: (lat: Double, lng: Double)? = nil,
                          offset: Any? = nil,
                          limit: Int = LIMIT_DEFAULT,
                          sortColumn: String = "id",
                          sortOrder: String = "asc",
                          callback: @escaping ([Racetrack], Any)->(), failure: @escaping FailureCallback) {
        var parameters: [String: String] = [
            "offset": "\(nextPage(offset, limit))",
            "limit": "\(limit)",
            "sortColumn": "id",
            "sortOrder": sortOrder
        ]
        if !name.isEmpty { parameters["name"] = name }
        if !stateIds.isEmpty { parameters["stateIds"] = stateIds.joined(separator: ",") }
        if let d = distanceToLocationMiles { parameters["distanceToLocationMiles"] = "\(d)" }
        if let location = location { parameters["locationLat"] = "\(location.lat)"; parameters["locationLng"] = "\(location.lng)" }

        get("racetracks", parameters: parameters, success: { (json) in
            let list = json["items"].arrayValue.map{Racetrack.fromJson($0)}
            let nextOffset = (offset as? Int ?? 0) + list.count
            callback(list, nextOffset)
        }, failure: failure)
    }

    /// Get story details
    ///
    /// - Parameters:
    ///   - id: the ID
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getStory(id: String, callback: @escaping (Story)->(), failure: @escaping FailureCallback) {
        get("trackStories/\(id)", parameters: [:], success: { (json) in
            callback(Story.fromJson(json))
        }, failure: failure)
    }

    /// Get user progress for given story
    ///
    /// - Parameters:
    ///   - story: the story
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getStoryProgress(for story: Story, callback: @escaping (StoryProgress)->(), failure: @escaping FailureCallback) {
        get("trackStories/\(story.id)/userProgress", parameters: [:], success: { (json) in
            let chapters = story.chapters.toArray()
            let map = chapters.hashmapWithKey({$0.id})
            let progress = StoryProgress.fromJson(json, chapters: map)
            let chapterProgresses = progress.chaptersUserProgress.toArray()
            for chapter in chapters {
                if let chapterProgress = chapterProgresses.filter({$0.chapter?.id == chapter.id}).first {
                    chapter.progress = chapterProgress
                }
            }
            callback(progress)
        }, failure: failure)
    }

    /// Complete additional task
    ///
    /// - Parameters:
    ///   - progressId: the progress ID
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func completeAdditionalTask(progressId: Int, callback: @escaping ()->(), failure: @escaping FailureCallback) {
        put("currentUser/trackStoryUserProgress/\(progressId)/completeAdditionalTask", parameters: [:], success: { (json) in
            callback()
        }, failure: failure)

    }

    /// Update progress
    ///
    /// - Parameters:
    ///   - progress: the progress
    ///   - storyProgress: the story progress
    ///   - story: the story
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func updateProgress(_ progress: ChapterProgress, storyProgress: StoryProgress?, story: Story, callback: @escaping ()->(), failure: @escaping FailureCallback) {
        let mainBlock: (StoryProgress)->() = { storyProgress in

            if let existingProgress = storyProgress.chaptersUserProgress.toArray().filter({$0.id == progress.id}).first {
                existingProgress.completed = progress.completed
                existingProgress.wordsRead = progress.wordsRead
            }
            else {
                storyProgress.chaptersUserProgress.append(progress)
            }
            self.put("currentUser/trackStoryUserProgress/\(storyProgress.id)", parameters: storyProgress.toParameters(), success: { (json) in
                callback()
            }, failure: failure)
        }

        if let storyProgress = storyProgress {
            mainBlock(storyProgress)
        }
        else {
            getStoryProgress(for: story, callback: mainBlock, failure: failure)
        }
    }

    /// Complete story progress
    ///
    /// - Parameters:
    ///   - storyProgress: the story progress
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func completeStory(storyProgress: StoryProgress, callback: @escaping ()->(), failure: @escaping FailureCallback) {
        put("currentUser/trackStoryUserProgress/\(storyProgress.id)/complete", parameters: [:], success: { (json) in
            storyProgress.completed = true
            callback()
        }, failure: failure)
    }

    /// Receive rewards
    ///
    /// - Parameters:
    ///   - storyProgress: the story progress
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func receiveRewards(storyProgress: StoryProgress, callback: @escaping (StoryReward)->(), failure: @escaping FailureCallback) {
        put("currentUser/trackStoryUserProgress/\(storyProgress.id)/receiveRewards", parameters: [:], success: { (json) in
            storyProgress.cardsAndRewardsReceived = true
            callback(StoryReward.fromJson(json))
        }, failure: failure)
    }

    // MARK: - Comments

    /// Receive rewards
    ///
    /// - Parameters:
    ///   - storyProgress: the story progress
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func searchComments(userId: Int? = nil, chapterId: Int? = nil, trackStoryId: Int? = nil, types: String? = nil,
                        offset: Any? = nil,
                        limit: Int = LIMIT_DEFAULT,
                        sortColumn: String = "createdAt",
                        sortOrder: String = "desc",
                        callback: @escaping ([Comment], Any)->(), failure: @escaping FailureCallback) {
        var parameters: [String: String] = [
            "offset": "\(nextPage(offset, limit))",
            "limit": "\(limit)",
            "sortColumn": sortColumn,
            "sortOrder": sortOrder
        ]
        if let userId = userId { parameters["userId"] = userId.toString() }
        if let chapterId = chapterId { parameters["chapterId"] = chapterId.toString() }
        if let trackStoryId = trackStoryId { parameters["trackStoryId"] = trackStoryId.toString() }
        if let types = types { parameters["types"] = types }

        get("comments", parameters: parameters, success: { (json) in
            let list = json["items"].arrayValue.map{Comment.fromJson($0)}
            let nextOffset = (offset as? Int ?? 0) + list.count
            callback(list, nextOffset)
        }, failure: failure)
    }

    /// Create (post) comment
    ///
    /// - Parameters:
    ///   - comment: the comment
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func createComment(_ comment: Comment, callback: @escaping (Comment)->(), failure: @escaping FailureCallback) {
        post("comments", parameters: comment.toParameters(), success: { (json) in
            let updatedComment = Comment.fromJson(json)
            comment.id = updatedComment.id
            comment.createdAt = updatedComment.createdAt
            comment.updatedAt = updatedComment.updatedAt
            comment.user.id = updatedComment.userId
            comment.userId = updatedComment.userId
            callback(comment)
        }, failure: failure)
    }

    /// Delete comment
    ///
    /// - Parameters:
    ///   - comment: the comment
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func deleteComment(_ comment: Comment, callback: @escaping ()->(), failure: @escaping FailureCallback) {
        delete("comments/\(comment.id)", parameters: [:], success: { (json) in
            callback()
        }, failure: failure)
    }

    /// Get current user
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getCurrentUser(callback: @escaping (User)->(), failure: @escaping FailureCallback) {
        get("currentUser", parameters: [:], success: { (json) in
            callback(User.fromJson(json))
        }, failure: failure)
    }
}
