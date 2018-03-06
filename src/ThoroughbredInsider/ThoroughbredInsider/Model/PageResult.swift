//
//  PageResult.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/22/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Page result
 *
 * - author: TCCODER
 * - version: 1.0
 */
struct PageResult<T> {

    /// fields
    var items: Array<T>
    var total = 0
    var offset = 0
    var limit = 0
    
}
