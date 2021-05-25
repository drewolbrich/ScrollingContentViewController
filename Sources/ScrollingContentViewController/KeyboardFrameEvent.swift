//
//  KeyboardFrameEvent.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/13/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// An event encapsulating both the keyboard's frame and the duration of the
/// animation accompanying the change in the keyboard's frame, as reported by the
/// `keyboardWillShow` or `keyboardWillHide` notification upon which the event is
/// based.
internal struct KeyboardFrameEvent {

    /// The frame of the keyboard in the window's coordinate space.
    var keyboardFrame: CGRect

    /// The duration of the keyboard's show or hide transition.
    var duration: TimeInterval

    /// Returns `true` if the keyboard frame event is the result of a
    /// `UINavigationController` transition.
    var isResultOfNavigationControllerTransition: Bool {
        // As of iOS 12, the duration of a UINavigationController push or pop transition is
        // 0.35 seconds. The transition duration for a keyboard presentation is 0.25
        // seconds.
        return duration > 0.3
    }

}
