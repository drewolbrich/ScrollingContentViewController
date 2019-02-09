//
//  SignUpController.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/9/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// Helper class that encapsulates code common to all
/// `ScrollingContentViewController` example applications.
class SignUpController: NSObject {

    private weak var nameTextField: UITextField?
    private weak var emailTextField: UITextField?
    private weak var passwordTextField: UITextField?

    private weak var signUpButton: UIButton?

    private weak var delegate: SignUpControllerDelegate?

    init(logoImageView: UIImageView, nameTextField: UITextField, emailTextField: UITextField, passwordTextField: UITextField, signUpButton: UIButton, signInButton: UIButton, delegate: SignUpControllerDelegate) {
        super.init()

        self.nameTextField = nameTextField
        self.emailTextField = emailTextField
        self.passwordTextField = passwordTextField

        self.signUpButton = signUpButton

        self.delegate = delegate

        logoImageView.tintColor = .white

        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self

        nameTextField.addTarget(self, action: #selector(updateSignUpButtonIsEnabledState), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(updateSignUpButtonIsEnabledState), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(updateSignUpButtonIsEnabledState), for: .editingChanged)

        signUpButton.isEnabled = false
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)

        configureSignInButton(signInButton)
    }

    @objc func updateSignUpButtonIsEnabledState() {
        guard let nameTextField = nameTextField,
            let emailTextField = emailTextField,
            let passwordTextField = passwordTextField else {
            return
        }

        // In a real app, this test should be more sophisticated and perform full
        // validation on each field separately according to its type.
        let isEnabled = !textFieldIsEmpty(nameTextField) && !textFieldIsEmpty(emailTextField) && !textFieldIsEmpty(passwordTextField)

        signUpButton?.isEnabled = isEnabled
    }

    @objc func signUp() {
        // Dismiss the keyboard.
        UIApplication.shared.keyWindow?.endEditing(true)

        // In a real app, the sign up flow would continue here.
    }

    /// If `true`, the text field contains the empty string, after trimming leading and
    /// trailing whitespace.
    private func textFieldIsEmpty(_ textField: UITextField) -> Bool {
        guard let text = trimmedText(of: textField) else {
            return true
        }
        return text.isEmpty
    }

    /// Strips leading and trailing whitespace.
    private func trimmedText(of textField: UITextField) -> String? {
        return textField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
    }

    private func configureSignInButton(_ signInButton: UIButton) {
        let signInButtonTitleColor: UIColor = .white
        let signInButtonTitleFontSize: CGFloat = 15

        let signInButtonTitle = NSMutableAttributedString()

        let signInButtonTitleRegularFontAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: signInButtonTitleColor,
            .font: UIFont.systemFont(ofSize: signInButtonTitleFontSize, weight: .regular)
            ]
        let signInButtonTitleMediumFontAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: signInButtonTitleColor,
            .font: UIFont.systemFont(ofSize: signInButtonTitleFontSize, weight: .medium)
            ]

        signInButtonTitle.append(NSAttributedString(string: "Already have an account? ", attributes: signInButtonTitleRegularFontAttributes))
        signInButtonTitle.append(NSAttributedString(string: "Sign In", attributes: signInButtonTitleMediumFontAttributes))

        signInButton.setAttributedTitle(signInButtonTitle, for: .normal)
    }

}

extension SignUpController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            emailTextField?.becomeFirstResponder()
            scrollFirstResponderToVisible()
        case emailTextField:
            passwordTextField?.becomeFirstResponder()
            scrollFirstResponderToVisible()
        case passwordTextField:
            passwordTextField?.resignFirstResponder()
        default:
            assertionFailure("Unrecognized text field")
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = trimmedText(of: textField)
    }

    private func scrollFirstResponderToVisible() {
        delegate?.signUpControllerScrollFirstResponderToVisible(self)
    }

}
