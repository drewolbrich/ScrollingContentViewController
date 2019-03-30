//
//  InsetContentViewKeyboardTests.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 3/22/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import XCTest
@testable import ScrollingContentViewController

/// Test case of presenting the keyboard over a content view that is inset
/// within the host view controller's root view.
class InsetContentViewKeyboardTests: XCTestCase {

    var window: UIWindow!

    var scrollingContentViewManager: ScrollingContentViewManager!
    var hostViewController: UIViewController!

    var contentView: UIView!
    var scrollView: UIScrollView!
    var rootView: UIView!

    let navigationBarHeight: CGFloat = 64
    let tabBarHeight: CGFloat = 49
    let keyboardHeight: CGFloat = 258

    let contentViewInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

    override func setUp() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = false

        hostViewController = UIViewController()

        hostViewController.additionalSafeAreaInsets.top = navigationBarHeight
        hostViewController.additionalSafeAreaInsets.bottom = tabBarHeight

        scrollingContentViewManager = ScrollingContentViewManager(hostViewController: hostViewController)

        contentView = UIView()

        hostViewController.view.addSubview(contentView)

        // Inset the content view within the initial safe area defined by the navigation
        // bar and tab bar, but not so much that it won't be overlapped by the keyboard
        // when it is presented.
        contentView.frame = hostViewController.view.bounds.inset(by: contentViewInset)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

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
        let scrollViewSafeAreaFrame = scrollView.safeAreaLayoutGuide.layoutFrame

        // The content view's frame should match the size of the root view's safe area that
        // intersects the scroll view frame.
        XCTAssertEqual(contentView.frame.size, scrollViewSafeAreaFrame.size)

        // The scroll view's content size should match that of the root view's safe area
        // that intersects the scroll view frame.
        XCTAssertEqual(scrollView.contentSize, scrollViewSafeAreaFrame.size)
    }

    /// Tests that presenting the keyboard does not affect the size of the content
    /// view when `shouldResizeContentViewForKeyboard` is `false`.
    func testPresentedKeyboardWithFixedContentView() {
        scrollingContentViewManager.shouldResizeContentViewForKeyboard = false

        let initialContentViewSize = scrollView.safeAreaLayoutGuide.layoutFrame.size

        presentKeyboard()

        let expectedContentViewSize = initialContentViewSize

        XCTAssertEqual(contentView.frame.size, expectedContentViewSize)
    }

    /// Tests that presenting the keyboard affects the size of the content view
    /// when `shouldResizeContentViewForKeyboard` is `true`.
    func testPresentedKeyboardWithResizedContentView() {
        scrollingContentViewManager.shouldResizeContentViewForKeyboard = true

        let initialContentViewSize = scrollView.safeAreaLayoutGuide.layoutFrame.size
        let initialBottomSafeAreaInset = rootView.safeAreaInsets.bottom - tabBarHeight

        presentKeyboard()

        let expectedContentViewSize = CGSize(width: initialContentViewSize.width, height: initialContentViewSize.height - (keyboardHeight - tabBarHeight) + initialBottomSafeAreaInset)

        XCTAssertEqual(contentView.frame.size, expectedContentViewSize)
    }

    private func presentKeyboard() {
        let keyboardFrame = CGRect(x: 0, y: window.bounds.height - keyboardHeight, width: window.bounds.width, height: keyboardHeight)

        // A test keyboard frame must be injected here because keyboard notifications will
        // not be generated when a first responder is assigned within a test.
        let keyboardFrameEvent = KeyboardFrameEvent(keyboardFrame: keyboardFrame, duration: 0.35)
        scrollingContentViewManager.keyboardObserver?.testKeyboardFrameEvent(keyboardFrameEvent)
    }

}
