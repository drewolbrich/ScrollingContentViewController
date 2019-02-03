//
//  SignUpControllerDelegate.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/9/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// Delegate for SignUpController.
protocol SignUpControllerDelegate: class {

    /// Tells the delegate to scroll the scroll view so that the first responder becomes
    /// visible.
    func signUpControllerScrollFirstResponderToVisible(_ signUpController: SignUpController)

}
