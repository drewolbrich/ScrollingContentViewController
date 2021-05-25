//
//  ScrollRectEvent.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/26/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// An event encapsulating a deferred call to `scrollRectToVisible(_:animated:)`.
internal struct ScrollRectEvent {

    enum ContentArea {
        /// The content view should be scrolled to make visible a rectangle in the
        /// coordinate space of the scroll view's content area.
        case scrollViewRect(_ rect: CGRect)

        /// The content view should be scrolled to make visible a rectangle in the
        /// coordinate space of the bounds of a descendant view of the content view.
        /// If `rect` is nil, the bounds of the descendant view is made visible.
        case descendantViewRect(_ rect: CGRect?, descendantView: UIView)
    }

    /// The area of the scroll view's content to make visible.
    var contentArea: ContentArea

    /// `true` if the scrolling should be animated.
    var animated: Bool

    /// A margin that should be added to the content area.
    var margin: CGFloat

}
