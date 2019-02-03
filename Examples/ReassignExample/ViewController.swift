//
//  ViewController.swift
//  ReassignExample
//
//  Created by Drew Olbrich on 2/2/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit
import ScrollingContentViewController

/// A class that demonstrates dynamically reassigning the `contentView` property of
/// a `ScrollingContentViewController`.
class ViewController: ScrollingContentViewController {

    @IBOutlet var firstContentView: FixedHeightContentView!
    @IBOutlet var secondContentView: FixedHeightContentView!

    override func viewDidLoad() {
        super.viewDidLoad()

        firstContentView.height = 568
        secondContentView.height = 320

        view.backgroundColor = UIColor.init(white: 0.94, alpha: 1)
    }

    @IBAction func toggleContentView(_ sender: Any) {
        if contentView == firstContentView {
            contentView = secondContentView
        } else {
            contentView = firstContentView
        }
    }

}
