//
//  KeyboardTests.swift
//  ScrollingContentViewControllerTests
//
//  Created by Drew Olbrich on 1/19/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import XCTest
@testable import ScrollingContentViewController

/// Test case of presenting the keyboard.
class KeyboardTests: XCTestCase {

    var window: UIWindow!

    var scrollingContentViewManager: ScrollingContentViewManager!
    var hostViewController: UIViewController!

    var contentView: ContentView!
    var scrollView: UIScrollView!
    var rootView: UIView!

    let keyboardHeight: CGFloat = 258

    let navigationBarHeight: CGFloat = 64
    let tabBarHeight: CGFloat = 49

    override func setUp() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = false

        hostViewController = UIViewController()

        hostViewController.additionalSafeAreaInsets.top = navigationBarHeight
        hostViewController.additionalSafeAreaInsets.bottom = tabBarHeight

        scrollingContentViewManager = ScrollingContentViewManager(hostViewController: hostViewController)

        contentView = ContentView()

        scrollingContentViewManager.contentView = contentView

        hostViewController.beginAppearanceTransition(true, animated: false)
        window.rootViewController = hostViewController
        hostViewController.view.layoutIfNeeded()
        hostViewController.endAppearanceTransition()

        scrollView = scrollingContentViewManager.scrollView
        rootView = hostViewController.view
    }

    override func tearDown() {
        hostViewController.beginAppearanceTransition(false, animated: false)
        window.rootViewController = nil
        hostViewController.endAppearanceTransition()
        window.isHidden = true
        window = nil

        hostViewController = nil

        scrollView = nil
        rootView = nil
        contentView = nil
    }

    /// Tests that the view hierarchy has the expected topology.
    func testViewHierarchy() {
        // The content view's superview should be the scroll view.
        XCTAssertEqual(contentView.superview, scrollView)

        // The scroll view's superview should be the view controller's root view.
        XCTAssertEqual(scrollView.superview, rootView)
    }

    /// Tests that the content view and the scroll view have the expected size.
    func testDefaultLayout() {
        let rootViewSafeAreaSize = rootView.bounds.inset(by: rootView.safeAreaInsets).size

        // The content view's frame should match the size of the root view's safe area.
        XCTAssertEqual(contentView.frame.size, rootViewSafeAreaSize)

        // The scroll view's content size should match that of the root view's safe area.
        XCTAssertEqual(scrollView.contentSize, rootViewSafeAreaSize)
    }

    /// Tests that presenting the keyboard does not affect the size of the content
    /// view when `shouldResizeContentViewForKeyboard` is `false`.
    func testPresentedKeyboardWithFixedContentView() {
        scrollingContentViewManager.shouldResizeContentViewForKeyboard = false

        let initialSafeAreaSize = rootView.bounds.inset(by: rootView.safeAreaInsets).size

        presentKeyboard()

        let finalSafeAreaSize = CGSize(width: initialSafeAreaSize.width, height: initialSafeAreaSize.height)

        XCTAssertEqual(contentView.frame.size, finalSafeAreaSize)
    }

    /// Tests that presenting the keyboard affects the size of the content view
    /// when `shouldResizeContentViewForKeyboard` is `true`.
    func testPresentedKeyboardWithResizedContentView() {
        scrollingContentViewManager.shouldResizeContentViewForKeyboard = true

        let initialSafeAreaSize = rootView.bounds.inset(by: rootView.safeAreaInsets).size

        let initialBottomInset = scrollView.adjustedContentInset.bottom

        presentKeyboard()

        // The size of the expected safe area of the view controller's root view after the
        // keyboard is presented.
        let expectedSafeAreaSize = CGSize(width: initialSafeAreaSize.width, height: initialSafeAreaSize.height - (keyboardHeight - initialBottomInset))

        XCTAssertEqual(contentView.frame.size, expectedSafeAreaSize)
    }

    private func presentKeyboard() {
        let keyboardFrame = CGRect(x: 0, y: window.bounds.height - keyboardHeight, width: window.bounds.width, height: keyboardHeight)

        // A test keyboard frame must be injected here because keyboard notifications will
        // not be generated when a first responder is assigned within a test.
        let keyboardFrameEvent = KeyboardFrameEvent(keyboardFrame: keyboardFrame, duration: 0.35)
        scrollingContentViewManager.keyboardObserver?.testKeyboardFrameEvent(keyboardFrameEvent)
    }

}
