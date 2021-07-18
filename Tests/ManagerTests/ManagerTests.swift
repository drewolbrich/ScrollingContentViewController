//
//  ManagerTests.swift
//  ScrollingContentViewControllerTests
//
//  Created by Drew Olbrich on 1/19/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import XCTest
import ScrollingContentViewController

/// Test case of using `ScrollingContentViewManager` in code.
class ManagerTests: XCTestCase {

    var window: UIWindow!

    var scrollingContentViewManager: ScrollingContentViewManager!
    var hostViewController: UIViewController!

    var contentView: ContentView!
    var scrollView: UIScrollView!
    var rootView: UIView!

    override func setUp() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = false

        hostViewController = UIViewController()

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

    /// Tests that the size of the content view is the expected size for the case of a
    /// view that's taller than root view's safe area.
    func testExpandedLayout() {
        contentView.heightConstraint.constant = 2000

        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()

        // The content view should stretch to larger than the root view's safe area.
        XCTAssertEqual(contentView.frame.size.height, contentView.heightConstraint.constant)

        // The scroll view's content size height should match that of the content view.
        XCTAssertEqual(scrollView.contentSize.height, contentView.heightConstraint.constant)
    }

}
