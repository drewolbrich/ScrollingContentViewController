//
//  ScrollViewBounceControlling.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/6/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// Delegate for `ScrollViewBounceController`.
internal protocol ScrollViewBounceControlling: class {

    /// Scroll view whose `alwaysBounceVertical` property is manipulated.
    var scrollView: ScrollingContentScrollView { get }

}
