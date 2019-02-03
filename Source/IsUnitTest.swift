//
//  IsUnitTest.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/29/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import Foundation

/// `true` if the code is executing within the XCTest framework.
internal var isUnitTest: Bool {
    return NSClassFromString("XCTest") != nil
}
