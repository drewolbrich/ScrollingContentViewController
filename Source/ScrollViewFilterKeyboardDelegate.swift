//
//  ScrollViewFilterKeyboardDelegate.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/6/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// A protocol that an object implements to be notified by `ScrollViewFilter` about
/// keyboard frame changes.
internal protocol ScrollViewFilterKeyboardDelegate: class {

    /// Adjusts the view to compensate for the portion of the keyboard that overlaps the
    /// scroll view.
    func scrollViewFilter(_ scrollViewFilter: ScrollViewFilter, adjustViewForKeyboardFrameEvent keyboardFrameEvent: KeyboardFrameEvent)

}
