//
//  RoundedCornersImage.swift
//  Examples
//
//  Created by Drew Olbrich on 12/24/18.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// Returns an image containing a rounded corners rectangle with a filled region and
/// outline.
///
/// - Parameters:
///   - fillColor: The color to fill the rectangle with.
///   - outlineColor: The color of the outline.
///   - cornerRadius: The radius of the rounded corners.
///   - outlineWidth: The stroke width of the outline.
/// - Returns: A rounded corners rectangle image.
func roundedCornersImage(fillColor: UIColor?, outlineColor: UIColor?, cornerRadius: CGFloat, outlineWidth: CGFloat = 1) -> UIImage? {
    let size = CGSize(width: cornerRadius*2, height: cornerRadius*2)
    let rect = CGRect(origin: .zero, size: size)

    UIGraphicsBeginImageContext(size)

    guard let context = UIGraphicsGetCurrentContext() else {
        return nil
    }

    context.clear(rect)

    if let fillColor = fillColor {
        context.setFillColor(fillColor.cgColor)
        context.fillEllipse(in: rect)
    }

    if let outlineColor = outlineColor {
        context.setStrokeColor(outlineColor.cgColor)
        context.strokeEllipse(in: rect.insetBy(dx: outlineWidth/2, dy: outlineWidth/2))
    }

    let image = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    let capInsets = UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)

    return image?.resizableImage(withCapInsets: capInsets)
}
