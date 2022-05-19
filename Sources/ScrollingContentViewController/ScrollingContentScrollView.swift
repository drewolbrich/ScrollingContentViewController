//
//  ScrollingContentScrollView.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/13/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// A scroll view that works with `ScrollingContentViewController` and
/// `ScrollingContentViewManager`.
///
/// See [https://github.com/drewolbrich/ScrollingContentViewController](https://github.com/drewolbrich/ScrollingContentViewController/blob/master/README.md) for full documentation.
public class ScrollingContentScrollView: UIScrollView {

    // The implementation of `scrollRectToVisible` provided by
    // `ScrollingContentScrollView` takes part in the temporal filtering of keyboard
    // frame resizing events provided by `ScrollViewFilter`. Critically, this allows
    // the execution of `scrollRectToVisible` to be delayed until the scroll view's
    // content size and layout has been updated to reflect the size of the keyboard.
    // Without this delay, the scroll view may not scroll by the correct amount, or may
    // scroll beyond the valid range of the scroll view's content offset.

    /// The margin applied when UIKit automatically scrolls the scroll view to make the
    /// first responder visible in response to keyboard presentation or device
    /// orientation changes.
    ///
    /// The default value is 0, which matches the UIKit behavior.
    ///
    /// This value is also applied when `scrollFirstResponderTextFieldToVisible`,
    /// `scrollViewToVisible`, or `scrollRectToVisible` are called, unless overridden
    /// with the optional `margin` parameter provided by those methods.
    public var visibilityScrollMargin: CGFloat = 0

    private weak var scrollViewFilter: ScrollViewFilter?

    internal convenience init(scrollViewFilter: ScrollViewFilter) {
        self.init()

        self.scrollViewFilter = scrollViewFilter
        scrollViewFilter.scrollDelegate = self

        // The UIScrollView contentInsetAdjustmentBehavior property must be set to always.
        // If it's left at its default value, automatic, then in the case when a scrolling
        // content view controller is presented outside of the context of a navigation
        // controller, changes to the size of the content view will result in the content
        // view's safe area insets changing unpredictably. The always behavior is chosen
        // here instead of never because unlike never, the always behavior adjusts the
        // scroll indicator insets, which is desirable, in particular on iPhone Xs in
        // landscape orientation with the keyboard presented.
        contentInsetAdjustmentBehavior = .always
    }

    public override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        scrollRectToVisible(rect, animated: animated, margin: nil)
    }

    /// Scrolls an area of the content view so it becomes visible.
    ///
    /// Unlike the default `UIScrollView` implementation of `scrollRectToVisible`, the
    /// scrolling does not take place immediately, but is submitted to
    /// `ScrollViewFilter` for later processing.
    ///
    /// Because `super.scrollRectToVisible` is not called immediately, it is possible
    /// that the size and layout of the scroll view's content may have changed by the
    /// time the `adjustViewForScrollRectEvent` method is called, below. Consequently,
    /// this implementation of `scrollRectToVisible` makes an attempt to determine which
    /// of the scroll view's descendants corresponds to the specified rectangle, if any.
    /// When `adjustViewForScrollRectEvent` is called, the final rectangle is determined
    /// relative to the bounds of that view. Without this approach, the scroll view may
    /// scroll too far, and possibly beyond the valid content offset range of the scroll
    /// view.
    ///
    /// - Parameters:
    ///   - rect: The rectangular area to make visible.
    ///   - animated: `true` if the scrolling should be animated.
    ///   - margin: An optional margin around `rect` that should also be made visible.
    ///   If `nil`, the value of `visibilityScrollMargin` is used.
    public func scrollRectToVisible(_ rect: CGRect, animated: Bool, margin: CGFloat? = nil) {
        if let descendantView = self.descendantView(of: self, containing: rect, in: self) {
            // If the rect matches the bounds of the descendant view, we'll substitute it with
            // nil, which will be replaced with the bounds of the descendant view when it is
            // processed later. The handles the case where the descendant view is resized
            // between the time when self.scrollRectToVisible and super.scrollRectToVisible are
            // called.
            // Note: This does not handle the case where the rect is smaller than the
            // descendant view's bounds and the size of the descendant view changes.
            let boundsRect = descendantView.convert(rect, from: self)
            let rect: CGRect? = boundsRect == descendantView.bounds ? nil : boundsRect
            scrollViewFilter?.submitScrollRectEvent(ScrollRectEvent(contentArea: .descendantViewRect(rect, descendantView: descendantView), animated: animated, margin: margin ?? visibilityScrollMargin))

            /// Continues in scrollViewFilter(_:adjustViewForScrollRectEvent:)...
            return
        }

        // No appropriate descendant view could be found, so `rect` is assumed to be defined
        // in the space of the scroll view's content area.
        // Note: This does not handle the case where the size of the scroll view content
        // area changes.
        scrollViewFilter?.submitScrollRectEvent(ScrollRectEvent(contentArea: .scrollViewRect(rect), animated: animated, margin: margin ?? visibilityScrollMargin))

        /// Continues in scrollViewFilter(_:adjustViewForScrollRectEvent:)...
    }

    /// Scrolls the scroll view to make the specified view visible.
    ///
    /// - Parameters:
    ///   - view: The view to make visible.
    ///   - animated: If `true`, the scrolling is animated.
    ///   - margin: An optional margin to apply to the view. If left unspecified,
    ///   `visibilityScrollMargin` is used.
    public func scrollViewToVisible(_ view: UIView, animated: Bool, margin: CGFloat? = nil) {
        scrollViewFilter?.submitScrollRectEvent(ScrollRectEvent(contentArea: .descendantViewRect(view.bounds, descendantView: view), animated: animated, margin: margin ?? visibilityScrollMargin))

        /// Continues in scrollViewFilter(_:adjustViewForScrollRectEvent:)...
    }

    /// Scrolls the scroll view to make the first responder visible. If no first
    /// responder is defined, this method has no effect.
    ///
    /// - Parameters:
    ///   - animated: If `true`, the scrolling is animated.
    ///   - margin: An optional margin to apply to the first responder. If left
    ///   unspecified, `visibilityScrollMargin` is used.
    public func scrollFirstResponderToVisible(animated: Bool, margin: CGFloat? = nil) {
        guard let view = self.firstResponder as? UIView else {
            return
        }

        scrollViewToVisible(view, animated: animated, margin: margin)
    }

    /// Returns the descendant view with the greatest depth whose bounds contains the
    /// specified rectangle.
    ///
    /// - Parameters:
    ///   - view: The view from which the search should start.
    ///   - rect: The rectangle to search for, defined in the coordinate space of `rectView`.
    ///   - rectView: The view that defines the coordinate space in which `rect` is defined.
    /// - Returns: The descendant view that contains `rect`.
    private func descendantView(of view: UIView, containing rect: CGRect, in rectView: UIView) -> UIView? {
        let frame = rectView.convert(rect, to: view)
        for subview in view.subviews {
            // Perform a depth first search so the descendant view with the greatest depth that
            // contains the rectangle will be found first.
            if let descendantView = descendantView(of: subview, containing: rect, in: rectView) {
                return descendantView
            }
            if subview.frame.contains(frame) {
                return subview
            }
        }
        return nil
    }

}

extension ScrollingContentScrollView: ScrollViewFilterScrollDelegate {

    internal func scrollViewFilter(_ scrollViewFilter: ScrollViewFilter, adjustViewForScrollRectEvent scrollRectEvent: ScrollRectEvent) {
        var scrollViewRect: CGRect = .zero

        switch scrollRectEvent.contentArea {
        case .scrollViewRect(let rect):
            scrollViewRect = rect
        case .descendantViewRect(let rect, let descendantView):
            // If rect is nil, make the entire descendant view visible.
            // This handles the case where the descendant view has changed
            // size since scrollRectToVisible was called.
            let rect = rect ?? descendantView.bounds
            scrollViewRect = convert(rect, from: descendantView)
        }

        scrollViewRect = scrollViewRect.insetBy(dx: 0, dy: -scrollRectEvent.margin)

        super.scrollRectToVisible(scrollViewRect, animated: scrollRectEvent.animated)
    }

}
