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
/// keyboard that overlaps the host view controller's root view.
internal class AdditionalSafeAreaInsetsController {

    private weak var delegate: AdditionalSafeAreaInsetsControlling?

    /// The initial value of the `additionalSafeAreaInsets` property before the keyboard
    /// was presented. The `additionalSafeAreaInsets` property is restored to this value
    /// when the keyboard is dismissed.
    private var initialAdditionalSafeAreaInsets: UIEdgeInsets?

    init(delegate: AdditionalSafeAreaInsetsControlling) {
        self.delegate = delegate
    }

    /// The height of the portion of the keyboard that overlaps the host view
    /// controller's root view.
    var bottomInset: CGFloat = 0 {
        didSet {
            guard let hostViewController = delegate?.hostViewController else {
                return
            }

            var adjustedBottomInset = bottomInset
            if bottomInset != 0 && oldValue == 0 {
                // The keyboard was presented.
                let initialAdditionalSafeAreaInsets = hostViewController.additionalSafeAreaInsets
                self.initialAdditionalSafeAreaInsets = initialAdditionalSafeAreaInsets
                adjustedBottomInset = max(adjustedBottomInset, initialAdditionalSafeAreaInsets.bottom)
                self.delegate?.additionalSafeAreaInsetsControllerWillUpdateAdditionalSafeAreaInsetsForPresentedKeyboard(self)
                setAdditionalSafeAreaBottomInset(adjustedBottomInset)
            } else if bottomInset == 0 && oldValue != 0 {
                // The keyboard was dismissed.
                guard let initialAdditionalSafeAreaInsets = initialAdditionalSafeAreaInsets else {
                    assertionFailure()
                    return
                }
                adjustedBottomInset = initialAdditionalSafeAreaInsets.bottom
                self.initialAdditionalSafeAreaInsets = nil
                setAdditionalSafeAreaBottomInset(adjustedBottomInset)
                self.delegate?.additionalSafeAreaInsetsControllerDidUpdateAdditionalSafeAreaInsetsForDismissedKeyboard(self)
            } else if bottomInset != oldValue {
                // The keyboard changed size.
                guard let initialAdditionalSafeAreaInset = initialAdditionalSafeAreaInsets else {
                    assertionFailure()
                    return
                }
                adjustedBottomInset = max(adjustedBottomInset, initialAdditionalSafeAreaInset.bottom)
                setAdditionalSafeAreaBottomInset(adjustedBottomInset)

            } else {
                // The size of the keyboard is unchanged.
                return
            }
        }
    }

    private func setAdditionalSafeAreaBottomInset(_ additionalSafeAreaBottomInset: CGFloat) {
        guard let hostViewController = delegate?.hostViewController else {
            return
        }
        hostViewController.additionalSafeAreaInsets.bottom = additionalSafeAreaBottomInset
    }

}
