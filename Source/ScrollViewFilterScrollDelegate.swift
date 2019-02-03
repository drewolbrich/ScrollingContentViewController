//
//  ScrollViewFilterScrollDelegates.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/24/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// A protocol that an object implements to be notified by `ScrollViewFilter` about
/// requests to scroll a specific area of the content so that it is visible in the
/// scroll view.
internal protocol ScrollViewFilterScrollDelegate: class {

    /// Scrolls a specific area of the content so that it is visible in the scroll view.
    func scrollViewFilter(_ scrollViewFilter: ScrollViewFilter, adjustViewForScrollRectEvent scrollRectEvent: ScrollRectEvent)

}
