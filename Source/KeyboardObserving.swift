//
//  KeyboardObserving.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/6/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// Delegate for `KeyboardObserver`.
internal protocol KeyboardObserving: AnyObject {

    /// View controller over top of which the keyboard is presented.
    var hostViewController: UIViewController? { get }

    /// Content view that contains text fields.
    var contentView: UIView? { get }

    /// Scroll view that is the super view of `contentView`.
    var scrollView: ScrollingContentScrollView { get }

    /// If `true`, the content view should be resized to compensate for the portion of
    /// the scroll view obscured by the presented keyboard, if possible.
    var shouldResizeContentViewForKeyboard: Bool { get }

    /// Adjusts the view controller to compensate for the portion of the keyboard that
    /// overlaps the view controller's root view.
    ///
    /// - Parameter bottomInset: The height of the vertical extent of the keyboard that
    /// overlaps the view controller's root view.
    func adjustViewForKeyboard(withBottomInset bottomInset: CGFloat)

}
