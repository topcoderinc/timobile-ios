//
//  StoryFilter.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/22/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation

/**
 * The filter used to filter stories
 *
 * - author: TCCODER
 * - version: 1.0
 */
struct StoryFilter {

    /// the title
    var title: String = ""

    /// the racetrack IDs
    var racetrackIds = [String]()

    /// the tags
    var tagIds = [String]()

    /// the location
    var location: (lat: Double, lng: Double)?
}
