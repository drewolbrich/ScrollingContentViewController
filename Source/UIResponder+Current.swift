//
//  UIResponder+Current.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 12/29/18.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//
//  Based on the Stack Overflow answer https://stackoverflow.com/a/52823735/2419404
//  by MarqueIV https://stackoverflow.com/users/168179/marqueiv
//  Licensed under the terms of the Attribution-ShareAlike 3.0 Unported license
//  https://creativecommons.org/licenses/by-sa/3.0/
//

import UIKit

private var foundFirstResponder: UIResponder?

internal extension UIResponder {

    /// The current first responder.
    static var rf_current: UIResponder? {
        UIApplication.shared.sendAction(#selector(UIResponder.storeFirstResponder(_:)), to: nil, from: nil, for: nil)
        defer {
            foundFirstResponder = nil
        }
        return foundFirstResponder
    }

    @objc private func storeFirstResponder(_ sender: AnyObject) {
        foundFirstResponder = self
    }

}
