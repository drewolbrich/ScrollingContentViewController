//
//  AdditionalSafeAreaInsetsControlling.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/6/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// Delegate for `AdditionalSafeAreaInsetsController`.
internal protocol AdditionalSafeAreaInsetsControlling: class {

    /// View controller whose `additionalSafeAreaInsets` property is manipulated.
    var hostViewController: UIViewController? { get }

    /// Manipulated content view minimum height constraint.
    var contentViewMinimumHeightConstraint: NSLayoutConstraint? { get }

    /// If `true`, the content view is allowed to shrink to compensate for the reduced
    /// visible area of the screen when the keyboard is presented.
    var shouldResizeContentViewForKeyboard: Bool { get }

}
