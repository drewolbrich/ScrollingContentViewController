//
//  SequenceViewController.swift
//  SequenceExample
//
//  Created by Drew Olbrich on 1/13/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit
import ScrollingContentViewController

class SequenceViewController: ScrollingContentViewController {

    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Allow the content view to shrink vertically when the keyboard is presented.
        shouldResizeContentViewForKeyboard = true

        // Allow the user to dismiss the keyboard by swiping down.
        scrollView.keyboardDismissMode = .interactive

        scrollView.alwaysBounceVertical = true

        contentView.backgroundColor = UIColor.init(white: 0.9, alpha: 1)

        textField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if shouldAssignFirstResponder {
            // When the view appears, make the text field the first responder.
            // This causes the keyboard to be immediately presented.
            textField?.becomeFirstResponder()
        }
    }

    func didTapReturnKey() {
        // Override this in subclasses.
    }

    /// If `true`, the `textField` outlet is assigned as the first responder when the
    /// view appears, presenting the keyboard.
    var shouldAssignFirstResponder: Bool {
        return true
    }

}

extension SequenceViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapReturnKey()
        return true
    }

}
