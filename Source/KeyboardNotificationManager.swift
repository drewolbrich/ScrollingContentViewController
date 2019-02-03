//
//  KeyboardNotificationManager.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/19/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// A singleton that responds to `keyboardWillShow` and `keyboardWillHide`
/// notification events and forwards them to observers.
///
/// Through its `lastNotification` property, this class also exposes the last
/// received keyboard event, so that view controllers pushed by a navigation
/// controller can query the current frame of the keyboard, which would be
/// otherwise inaccessible to them, since it was determined before they were
/// created.
internal class KeyboardNotificationManager: NSObject {

    static let shared = KeyboardNotificationManager()

    private override init() {
        super.init()

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(notifyObservers(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(notifyObservers(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private struct Observer {
        weak var observing: KeyboardNotificationObserving?
    }

    private var observers: [Observer] = []

    /// The last received keyboard notification.
    private(set) var lastNotification: Notification?

    /// Adds a keyboard notification observer.
    ///
    /// - Parameter observing: The observer to notify when a keyboard notification is
    /// received.
    func addKeyboardNotificationObserver(_ observing: KeyboardNotificationObserving) {
        observers.append(Observer(observing: observing))
    }

    /// Removes a keyboard notification observer.
    ///
    /// - Parameter observing: The observer to remove from the list of observers to
    /// notify when a keyboard notification is received.
    func removeKeyboardNotificationObserver(_ observing: KeyboardNotificationObserving) {
        observers.removeAll { $0.observing === observing }
    }

    /// Notifies all observers about a keyboard notification.
    ///
    /// - Parameter notification: The notification to pass to the observers.
    @objc private func notifyObservers(notification: Notification) {
        lastNotification = notification

        observers.forEach { $0.observing?.didReceiveKeyboardNotification(notification) }
    }

}
