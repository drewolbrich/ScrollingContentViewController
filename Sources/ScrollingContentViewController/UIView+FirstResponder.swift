//
//  UIView+FirstResponder.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 12/29/18.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

internal extension UIView {

    /// The first responder within a view hierarchy.
    var firstResponder: UIResponder? {
        let responder = self as UIResponder
        if responder.isFirstResponder {
            return responder
        }

        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }

        return nil
    }

}
