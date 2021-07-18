//
//  ContentView.swift
//  ScrollingContentViewControllerTests
//
//  Created by Drew Olbrich on 1/19/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// A view assigned `contentView` property in StoryboardTests.storyboard.
class ContentView: UIView {

    /// A constraint that determines the view's width.
    var widthConstraint: NSLayoutConstraint!

    /// A constraint that determine the view's height. This constraint's constant is
    /// manipulated externally to test the behavior of views of varying heights.
    var heightConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false

        widthConstraint = widthAnchor.constraint(equalToConstant: 200)
        heightConstraint = heightAnchor.constraint(equalToConstant: 200)

        // The priority of these constraints must be low, or otherwise they would have a
        // priority of `required` (the default value for NSLayoutConstraint.priority), and
        // would therefore take precedence over the `defaultHigh` constraints that
        // ScrollingContentViewManager adds to determine the size of the content view.
        widthConstraint.priority = .defaultLow
        heightConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([widthConstraint, heightConstraint])
    }

}
