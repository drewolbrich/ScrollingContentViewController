//
//  AdditionalSafeAreaInsetsController.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 12/30/18.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// An object that adjusts the host view controller's
/// `additionalSafeAreaInsets.bottom` property to compensate for the portion of the
/// keyboard that overlaps the scroll view.
internal class AdditionalSafeAreaInsetsController {

    private weak var delegate: AdditionalSafeAreaInsetsControlling?

    /// The initial value of the `additionalSafeAreaInsets` property before the keyboard
    /// was presented. The `additionalSafeAreaInsets` property is restored to this value
    /// when the keyboard is dismissed.
    private var initialAdditionalSafeAreaInsets: UIEdgeInsets?

    init(delegate: AdditionalSafeAreaInsetsControlling) {
        self.delegate = delegate
    }

    var bottomInset: CGFloat = 0 {
        didSet {
            guard let delegate = delegate,
                let hostViewController = delegate.hostViewController,
                let contentViewMinimumHeightConstraint = delegate.contentViewMinimumHeightConstraint else {
                    return
            }

            var adjustedBottomInset = bottomInset
            if bottomInset != 0 && oldValue == 0 {
                // The keyboard was presented.
                let initialAdditionalSafeAreaInsets = hostViewController.additionalSafeAreaInsets
                self.initialAdditionalSafeAreaInsets = initialAdditionalSafeAreaInsets
                adjustedBottomInset = max(adjustedBottomInset, initialAdditionalSafeAreaInsets.bottom)
            } else if bottomInset == 0 && oldValue != 0 {
                // The keyboard was dismissed.
                guard let initialAdditionalSafeAreaInsets = initialAdditionalSafeAreaInsets else {
                    assertionFailure()
                    return
                }
                adjustedBottomInset = initialAdditionalSafeAreaInsets.bottom
                self.initialAdditionalSafeAreaInsets = nil
            } else if bottomInset != oldValue {
                // The keyboard changed size.
                guard let initialAdditionalSafeAreaInset = initialAdditionalSafeAreaInsets else {
                    assertionFailure()
                    return
                }
                adjustedBottomInset = max(adjustedBottomInset, initialAdditionalSafeAreaInset.bottom)
            } else {
                // The size of the keyboard is unchanged.
                return
            }

            if delegate.shouldResizeContentViewForKeyboard {
                // Adjust the additional safe area insets, possibly reducing the size
                // of the content view.
                hostViewController.additionalSafeAreaInsets.bottom = adjustedBottomInset
            } else {
                // Adjust the additional safe area insets, but also increase the minimum height of
                // the content view to compensate. The size of the content view will remain
                // unchanged.
                hostViewController.additionalSafeAreaInsets.bottom = adjustedBottomInset
                contentViewMinimumHeightConstraint.constant = adjustedBottomInset
            }
        }
    }

}
