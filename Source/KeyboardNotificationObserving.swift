//
//  KeyboardNotificationObserving.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/19/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import Foundation

/// A protocol for objects that should be notified by `KeyboardNotificationManager`
/// when keyboard show or hide notifications are received.
internal protocol KeyboardNotificationObserving: class {

    /// Tells the observer that a keyboard notification has been received.
    func didReceiveKeyboardNotification(_ notification: Notification)

}
