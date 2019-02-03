//
//  FixedHeightContentView.swift
//  ReassignExample
//
//  Created by Drew Olbrich on 2/2/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// A content view that will have a fixed height defined using `intrinsicContentSize`
/// and a vertical content hugging priority of `required`.
class FixedHeightContentView: UIView {

    /// The desired height of the content view.
    var height: CGFloat = 0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Increase the vertical content hugging priority so the view won't grow beyond its
        // specified size. Without this assignment, the vertical content hugging priority
        // would be defaultLow and the view would grow to fit the available height of the
        // scroll view.
        setContentHuggingPriority(.required, for: .vertical)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

}
