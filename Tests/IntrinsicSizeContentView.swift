//
//  IntrinsicSizeContentView.swift
//  ScrollingContentViewControllerTests
//
//  Created by Drew Olbrich on 1/19/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// A view whose size is specified using the `intrinsicContentSize` property instead
/// of using constraints.
class IntrinsicSizeContentView: UIView {

    var width: CGFloat = 200 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    var height: CGFloat = 200 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: height)
    }

}
