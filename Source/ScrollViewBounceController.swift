//
//  ScrollViewBounceController.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 12/27/18.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// An object that modifies the scroll view's `alwaysBounceVertical` property to
/// reflect the state of the presented keyboard. This ensures that when
/// `keyboardDismissMode` is set to `interactive` it will work as expected, even if
/// the content view is short enough that scrolling wouldn't normally be permitted.
internal class ScrollViewBounceController {

    private weak var delegate: ScrollViewBounceControlling?

    private var initialAlwaysBounceVertical: Bool?

    init(delegate: ScrollViewBounceControlling) {
        self.delegate = delegate
    }

    var bottomInset: CGFloat = 0 {
        didSet {
            guard let scrollView = delegate?.scrollView,
                scrollView.keyboardDismissMode != .none else {
                return
            }

            if bottomInset != 0 && oldValue == 0 {
                // The keyboard was presented.
                initialAlwaysBounceVertical = scrollView.alwaysBounceVertical
                scrollView.alwaysBounceVertical = true
            } else if bottomInset == 0 && oldValue != 0 {
                // The keyboard was dismissed.
                guard let initialAlwaysBounceVertical = initialAlwaysBounceVertical else {
                    assertionFailure()
                    return
                }
                scrollView.alwaysBounceVertical = initialAlwaysBounceVertical
                self.initialAlwaysBounceVertical = nil
            }
        }
    }

}
