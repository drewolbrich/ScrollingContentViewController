//
//  ScrollingContentViewController.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/6/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// A view controller that manages a single scrolling content view.
///
/// `ScrollingContentViewController` is a subclass of `UIViewController` that
/// provides a `contentView` outlet which can be assigned in Interface Builder or
/// programmatically. The width and height of the content view are constrained to be
/// greater than or equal to the dimensions of the root view's safe area. If the
/// content view's Auto Layout constraints or intrinsic content size require it to
/// exceed the size of the safe area, the content view will scroll freely.
///
/// The view controller's root view acts as a background view. Scrolling content
/// should be added to `contentView` instead of `view`.
///
/// The scroll view that hosts the content view is exposed via the `scrollView`
/// property.
///
/// See [https://github.com/drewolbrich/ScrollingContentViewController](https://github.com/drewolbrich/ScrollingContentViewController/blob/master/README.md) for full documentation.
open class ScrollingContentViewController: UIViewController {

    /// The scrolling content view.
    ///
    /// This view is the subview of `scrollView`.
    @IBOutlet public var contentView: UIView! {
        didSet {
            if !isViewLoaded {
                // If the view controller's root view hasn't been loaded yet, the assignment of
                // scrollingContentViewManager.contentView must be deferred until viewDidLoad is
                // called, because otherwise, no view hierarchy will exist to parent the content
                // view and the scroll view to. This is the code path that is executed when the
                // contentView outlet value defined in Interface Builder is assigned.
            } else {
                scrollingContentViewManager.contentView = contentView
            }
        }
    }

    /// The `UIScrollView` to which `contentView` is parented.
    ///
    /// This view is typically the subview of `ScrollingContentViewController.view`, but
    /// it may be an arbitrary descendant of that view.
    public var scrollView: ScrollingContentScrollView {
        return scrollingContentViewManager.scrollView
    }

    /// If `true`, the content view should be resized to compensate for the portion of
    /// the scroll view obscured by the presented keyboard, if possible.
    ///
    /// The default value is `false`.
    @IBInspectable public var shouldResizeContentViewForKeyboard: Bool {
        set {
            scrollingContentViewManager.shouldResizeContentViewForKeyboard = newValue
        }
        get {
            return scrollingContentViewManager.shouldResizeContentViewForKeyboard
        }
    }

    /// If `true`, the view controller's `additionalSafeAreaInsets` property is adjusted
    /// when the keyboard is presented.
    ///
    /// The default value is `true`.
    @IBInspectable public var shouldAdjustAdditionalSafeAreaInsetsForKeyboard: Bool {
        set {
            scrollingContentViewManager.shouldAdjustAdditionalSafeAreaInsetsForKeyboard = newValue
        }
        get {
            return scrollingContentViewManager.shouldAdjustAdditionalSafeAreaInsetsForKeyboard
        }
    }

    /// An object that manages adding a content view to a scroll view.
    private lazy var scrollingContentViewManager = ScrollingContentViewManager(hostViewController: self)

    /// If you override this method, you must call `super` at some point in your
    /// implementation.
    open override func loadView() {
        // Load all controls and connect all outlets defined by Interface Builder.
        super.loadView()

        scrollingContentViewManager.loadView(forContentView: contentView)
    }

    /// If you override this method, you must call `super` at some point in your
    /// implementation.
    open override func viewDidLoad() {
        // If the content view has been assigned by Interface Builder, add it and the
        // scroll view to the view hierarchy automatically. Otherwise, it is the caller's
        // responsibility to manually assign the `contentView` property in their own
        // implementation of viewDidLoad.
        if let contentView = contentView {
            scrollingContentViewManager.contentView = contentView
        }
    }

    /// If you override this method, you must call `super` at some point in your
    /// implementation.
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        assert(contentView != nil, "Either contentView must be assigned in viewDidLoad, or the contentView outlet must be connected in Interface Builder")

        assert(scrollingContentViewManager.contentView != nil, "The content view was not added to the view hierarchy. Did you forget to call super in viewDidLoad?")

        scrollingContentViewManager.viewWillAppear(animated)
    }

    /// If you override this method, you must call `super` at some point in your
    /// implementation.
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        scrollingContentViewManager.viewSafeAreaInsetsDidChange()
    }

    /// If you override this method, you must call `super` at some point in your
    /// implementation.
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        scrollingContentViewManager.viewWillTransition(to: size, with: coordinator)
    }

}
