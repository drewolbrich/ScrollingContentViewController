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

    /// The view controller whose `additionalSafeAreaInsets` property is manipulated.
    var hostViewController: UIViewController? { get }

    /// Tells the delegate that the host view controller's additional safe area insets
    /// are about to be updated because the keyboard has been presented.
    func additionalSafeAreaInsetsControllerWillUpdateAdditionalSafeAreaInsetsForPresentedKeyboard(_ additionalSafeAreaInsetsController: AdditionalSafeAreaInsetsController)

    /// Tells the delegate that the host view controller's additional safe area insets
    /// have been restored to their original values after the keyboard was dismissed.
    func additionalSafeAreaInsetsControllerDidUpdateAdditionalSafeAreaInsetsForDismissedKeyboard(_ additionalSafeAreaInsetsController: AdditionalSafeAreaInsetsController)

}
