//
//  AppDelegate.swift
//  CodeExample
//
//  Created by Drew Olbrich on 12/29/18.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let signUpViewController = SignUpViewController()
        window.rootViewController = signUpViewController
        window.makeKeyAndVisible()

        return true
    }

}
