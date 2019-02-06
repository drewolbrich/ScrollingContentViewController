//
//  SignUpViewController.swift
//  ManagerExample
//
//  Created by Drew Olbrich on 1/10/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit
import ScrollingContentViewController

/// A class that demonstrates using `ScrollingContentViewManager` in conjunction
/// with an arbitrary `UIViewController` class instead of subclassing
/// `ScrollingContentViewController`.
class SignUpViewController: UIViewController {

    private lazy var scrollingContentViewManager = ScrollingContentViewManager(hostViewController: self)

    /// Helper object that encapsulates code common to all
    /// `ScrollingContentViewController` example applications.
    private var signUpController: SignUpController?

    @IBOutlet weak var contentView: UIView!

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

        scrollingContentViewManager.loadView(forContentView: contentView)

        // Replace the root view with a gradient view.
        view = GradientBackgroundView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the content view's background color to transparent so the gradient
        // background root view can be seen behind it.
        contentView.backgroundColor = nil

        // When ScrollingContentViewManager.contentView is first assigned, this has the
        // side effect of adding a scroll view to the view controller's root view, and
        // adding the content view to the scroll view. If a new view was assigned to this
        // property later, it would replace the existing content view in the scroll view
        // and leave the scroll view unchanged.
        scrollingContentViewManager.contentView = contentView

        // Allow the content view to shrink vertically when the keyboard is presented.
        scrollingContentViewManager.shouldResizeContentViewForKeyboard = true

        // Allow the user to dismiss the keyboard by dragging from the scroll view to the
        // bottom of the screen.
        scrollingContentViewManager.scrollView.keyboardDismissMode = .interactive

        signUpController = SignUpController(logoImageView: logoImageView, nameTextField: nameTextField, emailTextField: emailTextField, passwordTextField: passwordTextField, signUpButton: signUpButton, signInButton: signInButton, delegate: self)
    }

    // Note: This is only required in apps that support device orientation changes.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        scrollingContentViewManager.viewWillTransition(to: size, with: coordinator)
    }

    // Note: This is only required in apps with navigation controllers that are used to
    // push sequences of view controllers with text fields that become the first
    // responder in `viewWillAppear`.
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        scrollingContentViewManager.viewSafeAreaInsetsDidChange()
    }

}

extension SignUpViewController: SignUpControllerDelegate {

    func signUpControllerScrollFirstResponderToVisible(_ signUpController: SignUpController) {
        scrollingContentViewManager.scrollView.scrollFirstResponderToVisible(animated: true)
    }

}
