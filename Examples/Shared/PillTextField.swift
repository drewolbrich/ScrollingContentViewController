//
//  PillTextField.swift
//  Examples
//
//  Created by Drew Olbrich on 12/24/18.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// A text field with rounded ends.
class PillTextField: UITextField {

    private let fillColor = UIColor(white: 1, alpha: 0.1)
    private let outlineColor = UIColor(white: 1, alpha: 0.15)
    private let placeholderColor = UIColor(white: 1, alpha: 0.4)

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    private func commonInit() {
        borderStyle = .none

        font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textColor = .white

        // The insertion point's color and the color of selected text.
        tintColor = .white

        updateAttributedPlaceholder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if background?.size.height != bounds.height {
            background = roundedCornersImage(fillColor: fillColor, outlineColor: outlineColor, cornerRadius: bounds.height/2)
        }
    }

    override var placeholder: String? {
        didSet {
            updateAttributedPlaceholder()
        }
    }

    private func updateAttributedPlaceholder() {
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor,
            .font: UIFont.systemFont(ofSize: 17, weight: .medium),
            ]
        if let placeholder = placeholder {
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)
        } else {
            attributedPlaceholder = nil
        }
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: round(bounds.height*0.45), dy: 0)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 280, height: 44)
    }

}
