//
//  SignUpViewController.swift
//  StoryboardExample
//
//  Created by Drew Olbrich on 12/23/18.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit
import ScrollingContentViewController

/// A class that demonstrates configuring `ScrollingContentViewController` in
/// Interface Builder using storyboards.
class SignUpViewController: ScrollingContentViewController {

    /// Helper object that encapsulates code common to all
    /// `ScrollingContentViewController` example applications.
    private var signUpController: SignUpController?

    @IBOutlet weak var logoImageView: UIImageView!

    @IBOutlet weak var nameTextField: PillTextField!
    @IBOutlet weak var emailTextField: PillTextField!
    @IBOutlet weak var passwordTextField: PillTextField!

    @IBOutlet weak var signUpButton: PillButton!
    @IBOutlet weak var signInButton: UIButton!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func loadView() {
        // Load all controls and connect all outlets defined by Interface Builder.
        super.loadView()

        // Replace the root view with a gradient.
        view = GradientBackgroundView()
    }

    override func viewDidLoad() {
        // Insert the scroll view as a superview of the content view.
        super.viewDidLoad()

        // Set the content view's background color to transparent so the gradient
        // background root view can be seen behind it.
        contentView.backgroundColor = nil

        // Allow the content view to shrink vertically when the keyboard is presented.
        shouldResizeContentViewForKeyboard = true

        // Allow the user to dismiss the keyboard by dragging from the scroll view to the
        // bottom of the screen.
        scrollView.keyboardDismissMode = .interactive

        signUpController = SignUpController(logoImageView: logoImageView, nameTextField: nameTextField, emailTextField: emailTextField, passwordTextField: passwordTextField, signUpButton: signUpButton, signInButton: signInButton, delegate: self)
    }

}

extension SignUpViewController: SignUpControllerDelegate {

    func signUpControllerScrollFirstResponderToVisible(_ signUpController: SignUpController) {
        scrollView.scrollFirstResponderToVisible(animated: true)
    }

}
