//
//  FirstViewController.swift
//  SequenceExample
//
//  Created by Drew Olbrich on 1/12/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

class FirstViewController: SequenceViewController {

    override var shouldAssignFirstResponder: Bool {
        return true
    }

    override func didTapReturnKey() {
        performSegue(withIdentifier: "next", sender: nil)
    }

}
