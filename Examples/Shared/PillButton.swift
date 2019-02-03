//
//  PillButton.swift
//  Examples
//
//  Created by Drew Olbrich on 12/24/18.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// A button with rounded ends.
class PillButton: UIButton {

    private let normalOutlineColor = UIColor(white: 1, alpha: 0.4)
    private let disabledOutlineColor = UIColor(white: 1, alpha: 0.25)

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    private func commonInit() {
        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled = false

        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)

        setTitleColor(.white, for: .normal)
        setTitleColor(disabledOutlineColor, for: .disabled)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if backgroundImage(for: .normal)?.size.height != bounds.height {
            let normalBackgroundImage = roundedCornersImage(fillColor: nil, outlineColor: normalOutlineColor, cornerRadius: bounds.height/2)
            setBackgroundImage(normalBackgroundImage, for: .normal)

            let disabledBackgroundImage = roundedCornersImage(fillColor: nil, outlineColor: disabledOutlineColor, cornerRadius: bounds.height/2)
            setBackgroundImage(disabledBackgroundImage, for: .disabled)
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 280, height: 44)
    }

}
