//
//  ScrollingContentViewManager.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/6/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// A helper class that supports a view controller that manages a single scrolling
/// content view.
///
/// `ScrollingContentViewController` is implemented in terms of
/// `ScrollingContentViewManager`. In situations where
/// `ScrollingContentViewController` cannot be subclassed,
/// `ScrollingContentViewManager` may be used instead.
///
/// See [https://github.com/drewolbrich/ScrollingContentViewController](https://github.com/drewolbrich/ScrollingContentViewController/blob/master/README.md) for full documentation.
public class ScrollingContentViewManager: KeyboardObservering, ScrollViewBounceControlling, AdditionalSafeAreaInsetsControlling {

    /// The view controller that hosts the scroll view.
    public private(set) weak var hostViewController: UIViewController?

    /// The scrolling content view.
    ///
    /// When the content view is first assigned, it is parented to a scroll view, which is
    /// added to the host view controller's view hierarchy.
    ///
    /// If the content view has a superview, the scroll view replaces it in the view
    /// hierarchy and all of the superview's constraints that reference the content view
    /// are retargeted to the scroll view. The content view's width and height
    /// constraints and autoresizing mask are transferred to the scroll view.
    ///
    /// If the content view has no superview, the scroll view is parented to the host
    /// view controller's view and it's frame and autoresizing mask are defined to track
    /// its bounds.
    public var contentView: UIView? {
        didSet {
            if contentView == oldValue {
                return
            }

            assert(contentView != nil, "The content view must not be nil")

            if oldValue == nil {
                // This is the first time contentView has been assigned. Add both the scroll view
                // and the content view to the view hierarchy.
                addScrollViewAndContentView()
            } else {
                // A contentView has already been assigned. Replace it with the new content view.

                // Only a single content view is supported, so the scroll view's existing content
                // view, if any, must first be removed. This also removes the existing scroll view
                // constraints.
                oldValue?.removeFromSuperview()

                addContentView()
            }
        }
    }

    /// An object that applies a temporal filter to keyboard frame change notifications
    /// and `scrollRectToVisible` calls to avoid unwanted animation artifacts.
    private let scrollViewFilter = ScrollViewFilter()

    /// The scroll view to which `contentView` is parented. This view is the subview
    /// of `hostViewController.view`.
    public lazy var scrollView = ScrollingContentScrollView(scrollViewFilter: scrollViewFilter)

    /// If `true`, the content view should be resized to compensate for the portion of
    /// the scroll view obscured by the presented keyboard, if possible.
    ///
    /// The default value is `false`.
    public var shouldResizeContentViewForKeyboard = false

    /// If `true`, the view controller's `additionalSafeAreaInsets` property is adjusted
    /// when the keyboard is presented.
    ///
    /// The default value is `true`.
    public var shouldAdjustAdditionalSafeAreaInsetsForKeyboard = true

    /// A constraint that enforces a minimum width for the content view equal to the
    /// scroll view's safe area width.
    private var contentViewMinimumWidthConstraint: NSLayoutConstraint?

    /// A constraint that enforces a minimum height for the content view equal to the
    /// scroll view's safe area height.
    private var contentViewMinimumHeightConstraint: NSLayoutConstraint?

    /// When the keyboard is presented, if `shouldResizeContentViewForKeyboard` is
    /// false, this constraint is assigned to the current height of the content view. It
    /// is deactivated when the keyboard is dismissed. This prevents the content view
    /// from shrinking in response to the presented keyboard.
    private var contentViewMinimumHeightForPresentedKeyboardConstraint: NSLayoutConstraint?

    /// An object that responds to notifications posted by UIKit when the keyboard is
    /// presented or dismissed, and which adjusts the scroll view to compensate.
    ///
    /// This property's access control level is `internal` so it can be accessed by unit
    /// tests.
    internal var keyboardObserver: KeyboardObserver?

    /// An object that modifies the scroll view's `alwaysBounceVertical` property to
    /// reflect the state of the presented keyboard.
    ///
    /// This ensures that when `keyboardDismissMode` is set to `interactive` it will
    /// work as expected, even if the content view is short enough to not require
    /// scrolling.
    private lazy var scrollViewBounceController = ScrollViewBounceController(delegate: self)

    /// An object that adjusts the container view's `additionalSafeAreaInsets.bottom`
    /// property to compensate for the portion of the keyboard that overlaps the scroll
    /// view.
    private lazy var additionalSafeAreaInsetsController = AdditionalSafeAreaInsetsController(delegate: self)

    /// The priority of the content view's minimum width and height constaints.
    ///
    /// The value 500 was chosen so that when one or more constraints with priority
    /// `defaultLow` (250) are used along a particular axis, the content view will
    /// stretch to fill the scroll view's safe area. If all constraints along a
    /// particular axis have priority `defaultHigh` (750) or `required` (1000), they
    /// will be given priority, and the content view will not stretch to fill the scroll
    /// view's safe area.
    ///
    /// In a content view's layout, it may be advantageous to include one constraint
    /// with priority 240, because this value is lower than the default content hugging
    /// priority (250) and consequently, it will help avoid the undesirable behavior
    /// where text fields and labels without height constraints stretch vertically.
    ///
    /// If, instead of constraints, `intrinsicContentSize` is used to define the size of
    /// the content view, then the content view will stretch to fill the scroll view's
    /// safe area because the content view's default content hugging priority is
    /// `defaultLow` (250), which is less than the minimum size constraint priority. The
    /// content view's content hugging priority may optionally be set to `defaultHigh`
    /// (750), in which case the content view will not stretch to fill the scroll view's
    /// safe area.
    private let minimumSizeConstraintPriority = UILayoutPriority(rawValue: 500)

    /// Returns a scrolling content view manager.
    ///
    /// - Parameters hostViewController: The view controller that will host the scroll
    /// view and its content view.
    public init(hostViewController: UIViewController) {
        self.hostViewController = hostViewController

        keyboardObserver = KeyboardObserver(scrollViewFilter: scrollViewFilter, delegate: self)
    }

    /// Handles an edge case relating to keyboard visibility when
    /// ScrollingContentViewController is used in conjunction with other view
    /// controllers that present the keyboard in the context of a navigation controller.
    ///
    /// The KeyboardNotificationManager singleton handles the case where a navigation
    /// controller pushes a view controller while the keyboard is already visible,
    /// making the keyboard's frame available to the newly pushed view controller.
    /// However, it can only do this if KeyboardNotificationManager is already active
    /// before the keyboard is presented.
    ///
    /// To handle the edge case when the keyboard is already visible when the first view
    /// controller managed by ScrollingContentViewController is pushed by a navigation
    /// controller, this method can be called by the app's delegate's
    /// `application(_:didFinishLaunchingWithOptions:)` method to ensure that the
    /// KeyboardNotificationManager singleton is able to observe the full history of the
    /// keyboard's frame.
    ///
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - launchOptions: The dictionary indicating the reason the app was launched.
    /// - Returns: Always returns `true`.
    class func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = KeyboardNotificationManager.shared
        return true
    }

    /// This method should be called in the view controller's `loadView` method after
    /// `super.loadView` is called.
    ///
    /// In the case that, in `Interface Builder`, the host view controller's
    /// `contentView` outlet is assigned to its root view, this method replaces the root
    /// view with a newly created view. Consequently, when `contentView` is later
    /// assigned, the view controller will have a valid view to parent `scrollView` to,
    /// without creating a cycle in the view hierarchy.
    ///
    /// If the host view controller's `contentView` is not assigned to its root view,
    /// this method has no effect.
    ///
    /// - Parameter contentView: The content view to compare with the root view.
    public func loadView(forContentView contentView: UIView?) {
        guard let hostViewController = hostViewController else {
            return
        }

        if hostViewController.view == contentView {
            hostViewController.view = substitutionRootView(for: contentView)
        }
    }

    /// Creates a root view that is substituted for the content view in the case that
    /// the content view and the root view are the same.
    ///
    /// - Parameter contentView: The content view to base the root view on
    /// - Returns: A root view
    private func substitutionRootView(for contentView: UIView?) -> UIView {
        let rootView = UIView()

        if let contentView = contentView {
            rootView.frame = contentView.frame
        }

        // By default, UIView.backgroundColor is nil, which in the general case would allow
        // black pixels to be seen behind the view, so here it is changed to white, which
        // is the default for UIViewController root views created by Interface Builder.
        rootView.backgroundColor = .white

        return rootView
    }

    /// Adds an initial content view as a subview of the scroll view.
    ///
    /// If the content view has a superview, the scroll view replaces it in the view
    /// hierarchy and all of the superview's constraints that reference the content view
    /// are retargeted to the scroll view. The content view's width and height
    /// constraints and autoresizing mask are transferred to the scroll view.
    ///
    /// If the content view has no superview, the scroll view is parented to the host
    /// view controller's view and it's frame and autoresizing mask are defined to track
    /// its bounds.
    ///
    /// This method may only be called once. To replace an existing content view
    /// with a new one, call `addContentView`.
    private func addScrollViewAndContentView() {
        assert(scrollView.superview == nil, "addScrollViewAndContentView may only be called once")

        assert(contentView !== hostViewController?.view, "When the content view is assigned, it must not be the host view controller's root view. If you are subclassing ScrollingContentViewController, call super.loadView first in loadView, or, in the case of ScrollingContentViewManager, call loadView(forContentView:) after super.loadView in loadView, or assign a root view of your own.")

        guard let contentView = contentView else {
            assertionFailure("The content view is undefined")
            return
        }

        if contentView.superview == nil {
            addScrollViewToHostViewControllerRootView()
        } else {
            insertScrollViewAsSuperviewOfContentView()
        }

        addContentView()
    }

    /// Replaces a content view with the scroll view.
    ///
    /// The scroll view is assigned the content view's frame and autoresizing mask. The
    /// constraints of the content view's superview that target the content view are
    /// retargeted to the scroll view. The width and heights of the content view are
    /// copied to the scroll view.
    private func insertScrollViewAsSuperviewOfContentView() {
        assert(scrollView.superview == nil, "Either of addContentView or insertScrollViewAsSuperview may only be called once")

        guard let contentView = contentView else {
            assertionFailure("The content view is undefined")
            return
        }

        scrollView.translatesAutoresizingMaskIntoConstraints = contentView.translatesAutoresizingMaskIntoConstraints
        scrollView.autoresizingMask = contentView.autoresizingMask
        contentView.autoresizingMask = []
        scrollView.frame = contentView.frame

        guard let superview = contentView.superview else {
            assertionFailure("The content view has no superview")
            return
        }

        if let rootView = hostViewController?.view {
            assert(contentView.isDescendant(of: rootView), "The content view is not a descendant of the host view controller's root view")
        }

        superview.insertSubview(scrollView, belowSubview: contentView)

        redirectConstraints(of: superview, fromItem: contentView, toItem: scrollView)

        // The width and height constraints are transferred from the content view to the
        // scroll view, leaving the content view without width and height constraints. The
        // content view will be assigned replacement minimum width and height constraints
        // later, in `addScrollViewAndContentViewConstraints`.
        moveWidthAndHeightConstraints(of: contentView, to: scrollView)
    }

    /// Adds the content view as a subview of the scroll view.
    private func addContentView() {
        // This assertion is nonviable because scrollView.subviews includes the scroll
        // view's two scroll indicator image views.
        #if false
        assert(scrollView.subviews.isEmpty, "Only one content view may be parented to the scroll view")
        #endif

        guard let contentView = contentView else {
            assertionFailure("The content view is undefined")
            return
        }

        scrollView.addSubview(contentView)

        addScrollViewAndContentViewConstraints()
    }

    /// Logs a warning if the content view's size is undefined.
    public func viewWillAppear(_ animated: Bool) {
        guard let contentView = contentView else {
            assertionFailure("The content view is undefined")
            return
        }

        #if DEBUG
        let contentViewSystemLayoutSize = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let contentViewIntrinsicContentSize = contentView.intrinsicContentSize
        let widthIsDefined = contentViewSystemLayoutSize.width > 0 || contentViewIntrinsicContentSize.width != UIView.noIntrinsicMetric
        let heightIsDefined = contentViewSystemLayoutSize.height > 0 || contentViewIntrinsicContentSize.height != UIView.noIntrinsicMetric
        // Warnings are reported only if both the width and height are undefined. When a
        // layout is intended to scroll along only one axis, it is convenient to leave the
        // size of the other axis undefined.
        // Note: If a root view has no constraints, systemLayoutSizeFitting will return the
        // default size of the view, usually matching the size of the screen, so the
        // warning will not be displayed displayed in that case.
        if !widthIsDefined && !heightIsDefined {
            NSLog("Warning: The content view's size is undefined. You must have an unbroken chain of constraints and views stretching across at least one axis of the content view or the content view's intrinsic content size must be defined.")
        }
        #endif
    }

    /// Responds to changes in the view controller's safe area insets. If this method is
    /// not called, then, in the context of a navigation controller, if a sequence of
    /// view controllers with text fields that become the first responder in
    /// `viewWillAppear` is pushed, the content view will not be sized correctly.
    public func viewSafeAreaInsetsDidChange() {
        keyboardObserver?.viewSafeAreaInsetsDidChange()
    }

    /// Responds to changes in the size of the view, for example in response to device
    /// orientation changes, by adjusting the scroll view's content offset to ensure
    /// that it falls within a legal range.
    ///
    /// If the view controller responds to size changes (for example, resulting from
    /// changes in device orientation), then this method must be called by the view
    /// controller's implementation of `viewWillTransition(to:with:)`.
    public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let initialAdjustedContentInset = scrollView.adjustedContentInset
        let initialContentOffset = scrollView.contentOffset

        // When the device orientation changes, a keyboardWillHide notification is posted,
        // followed by a keyboardDidShow notification only after the device orientation
        // animation completes. If these were responded to immediately, this would result
        // in awkward view resizing animation. To work around this issue, the
        // KeyboardObserver's ScrollViewFilter is suspended during the transition, and as a
        // result, only final size of the keyboard after the animation completes is acted
        // upon.
        keyboardObserver?.suspend()

        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
            var contentOffset = initialContentOffset

            // At this point, if the keyboard is presented, it would be nice to keep the first
            // responder continuously visible on the screen during the transition. However, it
            // appears that there's no way to know what the new size of the keyboard will be,
            // and by extension, the new size of the visible portion of the scroll view, which
            // would be necessary to accurately maintain the first responder's visibility. A
            // survey of iOS 12's apps (e.g. creating a new event in Calendar, or editing a
            // document in Pages) reveals that Apple doesn't attempt to handle this case
            // elegantly either.

            // Pin the top left corner of the view. This matches the general behavior of
            // Apple's iOS apps.
            contentOffset = CGPoint(
                x: contentOffset.x + initialAdjustedContentInset.left - self.scrollView.adjustedContentInset.left,
                y: contentOffset.y + initialAdjustedContentInset.top - self.scrollView.adjustedContentInset.top)

            self.scrollView.contentOffset = self.constrainScrollViewContentOffset(contentOffset)
        }, completion: { (context: UIViewControllerTransitionCoordinatorContext) in
            if self.keyboardObserver?.isSuspended == true {
                self.keyboardObserver?.resume()
            }
        })
    }

    /// Redirects a host view's existing constraints from one item to another item.
    ///
    /// - Parameters:
    ///   - hostView: View whose constraints to modify.
    ///   - fromItem: Item to transfer constraint references from.
    ///   - toItem: Item to transfer constraint references to.
    private func redirectConstraints(of hostView: UIView, fromItem: AnyObject, toItem: AnyObject) {
        let constraints = hostView.constraints
        for constraint in constraints {
            if let firstItem = (constraint.firstItem === fromItem) ? toItem : constraint.firstItem,
                let secondItem = (constraint.secondItem === fromItem) ? toItem : constraint.secondItem,
                firstItem !== constraint.firstItem || secondItem !== constraint.secondItem {
                hostView.removeConstraint(constraint)
                hostView.addConstraint(NSLayoutConstraint(item: firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
            }
        }
    }

    /// Moves width and height constraints from one view to another view.
    ///
    /// - Parameters:
    ///   - fromView: The view to transfer width and height constraints from.
    ///   - toView: The view to transfer width and height constraints to.
    private func moveWidthAndHeightConstraints(of fromView: UIView, to toView: UIView) {
        var constraintsToRemove: [NSLayoutConstraint] = []
        for constraint in fromView.constraints {
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                if let firstItem = (constraint.firstItem === fromView) ? toView : constraint.firstItem {
                    let secondItem = (constraint.secondItem === fromView) ? toView : constraint.secondItem
                    if firstItem === toView || secondItem === toView {
                        toView.addConstraint(NSLayoutConstraint(item: firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
                        constraintsToRemove.append(constraint)
                    }
                }
            }
        }
        fromView.removeConstraints(constraintsToRemove)
    }

    /// Adds the scroll view as a subview of the host view controller's root view.
    ///
    /// The scroll view's frame and autoresizing mask are defined to track the host view
    /// controller's root view's bounds.
    private func addScrollViewToHostViewControllerRootView() {
        assert(scrollView.superview == nil)

        guard let hostViewController = hostViewController else {
            assertionFailure("The host view controller is undefined")
            return
        }

        assert(hostViewController.view != nil, "The host view controller's root view is undefined")

        hostViewController.view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.frame = hostViewController.view.bounds
    }

    /// Constrains the content view to the scroll view's content layout guide,
    /// and adds content view width and height constraints.
    private func addScrollViewAndContentViewConstraints() {
        // See https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithScrollViews.html

        guard let contentView = contentView else {
            assertionFailure("The content view is undefined")
            return
        }

        // The relation greaterThanOrEqualTo is used for the minimumum width and height
        // constraints so the content view is free to stretch to fill the scroll view's
        // safe area.

        let contentViewMinimumWidthConstraint = contentView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.safeAreaLayoutGuide.widthAnchor, multiplier: 1)
        self.contentViewMinimumWidthConstraint = contentViewMinimumWidthConstraint

        let contentViewMinimumHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.safeAreaLayoutGuide.heightAnchor, multiplier: 1)
        self.contentViewMinimumHeightConstraint = contentViewMinimumHeightConstraint

        let contentViewMinimumHeightForPresentedKeyboardConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        self.contentViewMinimumHeightForPresentedKeyboardConstraint = contentViewMinimumHeightForPresentedKeyboardConstraint

        contentViewMinimumWidthConstraint.priority = minimumSizeConstraintPriority
        contentViewMinimumHeightConstraint.priority = minimumSizeConstraintPriority
        contentViewMinimumHeightForPresentedKeyboardConstraint.priority = minimumSizeConstraintPriority

        contentView.translatesAutoresizingMaskIntoConstraints = false

        let constraints: [NSLayoutConstraint] = [
            scrollView.contentLayoutGuide.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            scrollView.contentLayoutGuide.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentViewMinimumWidthConstraint,
            contentViewMinimumHeightConstraint,
            contentViewMinimumHeightForPresentedKeyboardConstraint
            ]

        NSLayoutConstraint.activate(constraints)

        // This constraint is activated only when the keyboard is presented
        // and shouldResizeContentViewForKeyboard is false.
        contentViewMinimumHeightForPresentedKeyboardConstraint.isActive = false
    }

    /// Constrains a scroll view content offset so that it lies within the legal range
    /// of possible values for the rest state of the scroll view.
    ///
    /// - Parameter contentOffset: The content offset to constrain.
    /// - Returns: The constrained content offset.
    private func constrainScrollViewContentOffset(_ contentOffset: CGPoint) -> CGPoint {
        var contentOffset = contentOffset

        let contentSize = scrollView.contentSize
        let visibleContentSize = self.visibleContentSize(of: scrollView)
        let adjustedContentInset = scrollView.adjustedContentInset

        // Don't let the scroll view scroll up past its right/bottom extent. If this isn't
        // done, then if the view is shorter than the scroll view in portrait orientation,
        // and the user scrolls to the bottom in landscape orientation, and then changes
        // the orientation back to portrait, the top of the view will be permanently
        // shifted up off the top of the screen, and there will no way for the user to
        // scroll up to see it.
        contentOffset.x = min(contentOffset.x, contentSize.width - visibleContentSize.width - adjustedContentInset.left)
        contentOffset.y = min(contentOffset.y, contentSize.height - visibleContentSize.height - adjustedContentInset.top)

        // Don't let the scroll view scroll down past its left/top extent. This isn't
        // strictly necessary because, above, the top left corner of the view is pinned,
        // but it supports possible future changes to how the content offset is managed.
        contentOffset.x = max(contentOffset.x, -adjustedContentInset.left)
        contentOffset.y = max(contentOffset.y, -adjustedContentInset.top)

        return contentOffset
    }

    /// The size of the region of the scroll view in which content is visible. This is
    /// size of the scroll view's bounds after its adjusted content inset has been
    /// applied.
    private func visibleContentSize(of scrollView: UIScrollView) -> CGSize {
        return scrollView.bounds.inset(by: scrollView.adjustedContentInset).size
    }

    /// Adjusts the view controller to compensate for the portion of the keyboard that
    /// overlaps the view controller's root view.
    ///
    /// This method is called by `KeyboardObserver` when the keyboard is presented,
    /// dismissed, or changes size.
    ///
    /// - Parameter bottomInset: The height of the area of keyboard's frame that
    /// overlaps the view controller's root view.
    func adjustViewForKeyboard(withBottomInset bottomInset: CGFloat) {
        self.bottomInset = bottomInset
    }

    /// The bottom inset to assign to the view controller's additional safe area to
    /// compensate for the area of the keyboard that overlaps the view controller's root
    /// view.
    private var bottomInset: CGFloat = 0 {
        didSet {
            if bottomInset == oldValue {
                return
            }

            scrollViewBounceController.bottomInset = bottomInset

            if shouldAdjustAdditionalSafeAreaInsetsForKeyboard {
                // When the keyboard is presented, the view controller's
                // additionalSafeAreaInsets.bottom property is adjusted to compensate.
                //
                // This approach was chosen instead of resizing the scroll view's content size,
                // because doing so requires adjusting its scrollIndicatorInsets property to
                // compensate, and on iPhone Xs in landscape orientation, this has the unfortunate
                // side effect of awkwardly shifting the scroll indicator away from the edge of the
                // screen.
                //
                // Additionally, the approach of resizing the scroll view's content size appears to
                // interact poorly with the scroll view's scrollRectToVisible method.
                additionalSafeAreaInsetsController.bottomInset = bottomInset
            }
        }
    }

    func additionalSafeAreaInsetsControllerWillUpdateAdditionalSafeAreaInsetsForPresentedKeyboard(_ additionalSafeAreaInsetsController: AdditionalSafeAreaInsetsController) {
        guard !shouldResizeContentViewForKeyboard else {
            // Don't constrain the height of the keyboard.
            return
        }
        guard let contentViewMinimumHeightForPresentedKeyboardConstraint = contentViewMinimumHeightForPresentedKeyboardConstraint, let contentView = contentView else {
            return
        }

        // When the keyboard is presented, just before AdditionalSafeAreaInsetsController 

        contentViewMinimumHeightForPresentedKeyboardConstraint.constant = contentView.frame.height
        contentViewMinimumHeightForPresentedKeyboardConstraint.isActive = true
    }

    func additionalSafeAreaInsetsControllerDidUpdateAdditionalSafeAreaInsetsForDismissedKeyboard(_ additionalSafeAreaInsetsController: AdditionalSafeAreaInsetsController) {
        contentViewMinimumHeightForPresentedKeyboardConstraint?.isActive = false
    }

}
