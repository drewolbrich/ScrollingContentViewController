//
//  SignUpViewController.swift
//  CodeExample
//
//  Created by Drew Olbrich on 12/29/18.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit
import ScrollingContentViewController

/// A class that demonstrates configuring `ScrollingContentViewController`
/// programmatically. This view controller is instantiated in `AppDelegate` and
/// installed as the window's root view controller.
class SignUpViewController: ScrollingContentViewController {

    /// Helper object that encapsulates code common to all
    /// `ScrollingContentViewController` example applications.
    private var signUpController: SignUpController?

    private let logoImageView = UIImageView(image: UIImage(named: "Lorem-Ipsum-Logo"))

    private let nameTextField = PillTextField()
    private let emailTextField = PillTextField()
    private let passwordTextField = PillTextField()

    private let signUpButton = PillButton(type: .system)
    private let signInButton = UIButton(type: .system)

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func loadView() {
        // Assign a gradient as the root view.
        view = GradientBackgroundView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the content view.
        createContentView()

        // Allow the content view to shrink vertically when the keyboard is presented.
        shouldResizeContentViewForKeyboard = true

        // Allow the user to dismiss the keyboard by dragging from the scroll view to the
        // bottom of the screen.
        scrollView.keyboardDismissMode = .interactive

        signUpController = SignUpController(logoImageView: logoImageView, nameTextField: nameTextField, emailTextField: emailTextField, passwordTextField: passwordTextField, signUpButton: signUpButton, signInButton: signInButton, delegate: self)
    }

    /// Creates the content view.
    private func createContentView() {
        // When ScrollingContentViewController.contentView is assigned for the first time,
        // this has the side effect of adding a scroll view to the view controller's root
        // view, and adding the content view to the scroll view. If a new view was assigned
        // to this property later, it would replace the existing content view in the scroll
        // view, and leave the scroll view unchanged.
        contentView = UIView()

        // Assign the content view's background color to transparent so it can be seen
        // through it to the gradient background view. This is the default value, but the
        // intent here is to be explicit for example code.
        contentView.backgroundColor = nil

        logoImageView.tintColor = .white

        configureTextFields()

        signUpButton.setTitle("Sign Up", for: .normal)

        addConstraints()
    }

    private func configureTextFields() {
        configureTextField(nameTextField, placeholder: "Name", textContentType: .name, autocapitalizationType: .words, keyboardType: .default, isSecureTextEntry: false)
        configureTextField(emailTextField, placeholder: "Email", textContentType: .emailAddress, autocapitalizationType: .none, keyboardType: .emailAddress, isSecureTextEntry: false)
        configureTextField(passwordTextField, placeholder: "Password", textContentType: nil, autocapitalizationType: .none, keyboardType: .default, isSecureTextEntry: true)
    }

    // swiftlint:disable:next function_parameter_count
    private func configureTextField(_ textField: UITextField, placeholder: String?, textContentType: UITextContentType?, autocapitalizationType: UITextAutocapitalizationType, keyboardType: UIKeyboardType, isSecureTextEntry: Bool) {
        textField.placeholder = placeholder
        textField.autocapitalizationType = autocapitalizationType
        textField.autocorrectionType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        textField.smartQuotesType = .no
        textField.spellCheckingType = .no
        textField.returnKeyType = .next
        textField.keyboardType = keyboardType
        textField.enablesReturnKeyAutomatically = true
        textField.isSecureTextEntry = isSecureTextEntry
    }

    // swiftlint:disable:next function_body_length
    private func addConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)

        addPillViewConstraints(to: nameTextField)
        addPillViewConstraints(to: emailTextField)
        addPillViewConstraints(to: passwordTextField)

        addPillViewConstraints(to: signUpButton)

        contentView.addSubview(logoImageView)
        contentView.addSubview(stackView)
        contentView.addSubview(signUpButton)
        contentView.addSubview(signInButton)

        let logoImageTopLayoutGuide = UILayoutGuide()
        let logoImageBottomLayoutGuide = UILayoutGuide()
        let signUpButtonBottomLayoutGuide = UILayoutGuide()

        contentView.addLayoutGuide(logoImageTopLayoutGuide)
        contentView.addLayoutGuide(logoImageBottomLayoutGuide)
        contentView.addLayoutGuide(signUpButtonBottomLayoutGuide)

        let constraints: [NSLayoutConstraint] = [
            contentView.centerXAnchor.constraint(equalTo: logoImageView.centerXAnchor),
            contentView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            contentView.centerXAnchor.constraint(equalTo: signUpButton.centerXAnchor),
            contentView.centerXAnchor.constraint(equalTo: signInButton.centerXAnchor),

            contentView.topAnchor.constraint(equalTo: logoImageTopLayoutGuide.topAnchor),
            logoImageView.topAnchor.constraint(equalTo: logoImageTopLayoutGuide.bottomAnchor),

            logoImageView.bottomAnchor.constraint(equalTo: logoImageBottomLayoutGuide.topAnchor),
            stackView.topAnchor.constraint(equalTo: logoImageBottomLayoutGuide.bottomAnchor),

            signUpButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 48),

            signUpButton.bottomAnchor.constraint(equalTo: signUpButtonBottomLayoutGuide.topAnchor),
            signInButton.topAnchor.constraint(equalTo: signUpButtonBottomLayoutGuide.bottomAnchor),

            contentView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 30),

            logoImageTopLayoutGuide.heightAnchor.constraint(equalTo: logoImageBottomLayoutGuide.heightAnchor),
            logoImageBottomLayoutGuide.heightAnchor.constraint(equalTo: signUpButtonBottomLayoutGuide.heightAnchor, multiplier: 2, constant: 0),
            signUpButtonBottomLayoutGuide.heightAnchor.constraint(greaterThanOrEqualToConstant: 16)
            ]

        logoImageView.setContentHuggingPriority(.required, for: .vertical)
        logoImageView.setContentHuggingPriority(.required, for: .horizontal)

        contentView.addConstraints(constraints)
    }

    private func addPillViewConstraints(to pillView: UIView) {
        let widthConstraint = pillView.widthAnchor.constraint(equalToConstant: 280)
        widthConstraint.priority = UILayoutPriority.defaultLow - 10

        let heightConstraint = pillView.heightAnchor.constraint(equalToConstant: 44)
        heightConstraint.priority = .required

        pillView.addConstraints([widthConstraint, heightConstraint])
    }

}

extension SignUpViewController: SignUpControllerDelegate {

    func signUpControllerScrollFirstResponderToVisible(_ signUpController: SignUpController) {
        scrollView.scrollFirstResponderToVisible(animated: true)
    }

}
