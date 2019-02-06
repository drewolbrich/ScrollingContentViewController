//
//  ScrollViewFilter.swift
//  ScrollingContentViewController
//
//  Created by Drew Olbrich on 1/24/19.
//  Copyright 2019 Oath Inc.
//
//  Licensed under the terms of the MIT License. See the file LICENSE for the full terms.
//

import UIKit

/// An object that applies a temporal filter to keyboard frame change notifications
/// and `scrollRectToVisible` calls to avoid unwanted animation.
///
/// When a text field becomes the first responder, iOS presents the keyboard. If the
/// user taps another text field, changing the first responder, iOS may adjust the
/// keyboard's height if an input accessory view is specified. Often, these changes
/// will generate a sequence multiple of `keyboardWillShow` notifications, each with
/// different keyboard frame heights.
///
/// As an extreme example, if the user populates a text field by tapping on an
/// AutoFill input accessory view, and this action causes a password text field to
/// automatically become the first responder, one `keyboardWillHide` notifications
/// and two `keyboardWillShow` notifications will be posted within a span of 0.1
/// seconds.
///
/// If `KeyboardObserver` were to respond to each of these notifications
/// individually, this would result in awkward discontinuities in the scroll view
/// animation that accompanies changes to the keyboard's height.
///
/// To work around this issue, `ScrollViewFilter` filters out sequences of
/// notifications that occur within a small time window, acting only on the final
/// assigned keyboard frame in the sequence.
///
/// `ScrollViewFilter` also filters calls to `scrollRectToVisible`. If a text field
/// is the first responder when a device orientation change occurs, UIKit will call
/// `scrollRectToVisible` with the text field's frame at the end of the transition
/// at a time when `adjustedContentInset` hasn't yet been updated to reflect the
/// orientation change. This will result in the view scrolling unnnecessarily, or
/// worse, to a point beyond the legal scrolling extent of the scroll view. As a
/// workaround, `ScrollViewFilter` defers this call for a short period of time until
/// after `adjustedContentInset` has been updated.
///
/// Because `ScrollViewFilter` filters both keyboard notifications and
/// `scrollRectToVisible` calls, it is also able to handle a special case in which
/// the device orientation changes, resulting in a keyboard frame change
/// notification which coincides with a call to `scrollRectToVisible` which is
/// implicitly made by iOS. If only the keyboard notifications were filtered and
/// `scrollRectToVisible` calls were allowed to occur as originally scheduled, the
/// scroll view would awkwardly scroll up and down after the device orientation
/// change.
internal class ScrollViewFilter {

    /// Delegate that is notified when a change in the keyboard's frame occurs.
    weak var keyboardDelegate: ScrollViewFilterKeyboardDelegate?

    /// Delegate that is notified when `scrollRectToVisible` should be executed.
    weak var scrollDelegate: ScrollViewFilterScrollDelegate?

    /// The delay before calls to `submitKeyboardFrameEvent` or
    /// `submitKeyboardFrameEvent` will result in delegate calls. This value was chosen
    /// to be slightly larger than the interval between successive keyboard frame
    /// notifications that accompany device orientation changes. If a significantly
    /// smaller value is chosen, the view will resize erratically during an orientation
    /// change.
    private let delay: TimeInterval = 0.1

    /// The last submitted keyboard event.
    private var keyboardFrameEvent: KeyboardFrameEvent?

    /// The last submitted scroll rect event.
    private var scrollRectEvent: ScrollRectEvent?

    /// The timer used to apply the temporal filter.
    private var timer: Timer?

    /// The time that the timer started.
    private var timerStartDate: Date?

    /// The timer's time interval.
    private var timerTimeInterval: TimeInterval?

    /// This property is `true` when the temporal filtering is suspended by calling the
    /// `suspend` method.
    private(set) var isSuspended = false

    /// This property is `true` if the timer was active when `suspend` was last called,
    /// or if an attempt was made to start the timer while the filter was suspended.
    private var shouldRestartTimerWhenResumed = false

    /// The time remaining on the timer when it was suspended. This time interval will
    /// be used when filtering is resumed and the timer is restarted.
    private var suspendedTimerTimerInterval: TimeInterval = 0

    deinit {
        cancel()
    }

    /// Submits a keyboard frame event, which will result in a call to
    /// `ScrollViewFilterKeyboardDelegate.scrollViewFilter(_:adjustViewForKeyboardFrameEvent:)`
    /// after a short delay.
    ///
    /// - Parameter keyboardFrameEvent: The keyboard frame event to submit.
    func submitKeyboardFrameEvent(_ keyboardFrameEvent: KeyboardFrameEvent) {
        self.keyboardFrameEvent = keyboardFrameEvent
        startTimer(timeInterval: delay)
    }

    /// Submits a scroll rect event, which will result in a call to
    /// `ScrollViewFilterScrollDelegate.scrollViewFilter(_:adjustViewForScrollRectEvent:)`
    /// after a short delay.
    ///
    /// - Parameter scrollRectEvent: The scroll rect event to submit.
    func submitScrollRectEvent(_ scrollRectEvent: ScrollRectEvent) {
        self.scrollRectEvent = scrollRectEvent
        startTimer(timeInterval: delay)
    }

    /// Cancels the filter.
    ///
    /// No delegate calls will be made until new events are submitted.
    func cancel() {
        invalidate()

        shouldRestartTimerWhenResumed = false
        suspendedTimerTimerInterval = 0
    }

    /// Immediately notifies the delegates of any pending events.
    ///
    /// If no events are pending, this method has no effect. If the filter is suspended,
    /// no action is taken, but pending events will be acted upon immediately when the
    /// filter is resumed.
    func flush() {
        guard !isSuspended else {
            // Fire the timer immediately when it is resumed.
            suspendedTimerTimerInterval = 0
            return
        }

        timer?.fire()
    }

    /// Suspends filtering.
    ///
    /// The filter may be restarted by calling `resume`.
    func suspend() {
        guard !isSuspended else {
            return
        }

        if timer != nil {
            shouldRestartTimerWhenResumed = true
            suspendedTimerTimerInterval = remainingTimerTimeInterval
        } else {
            shouldRestartTimerWhenResumed = false
            suspendedTimerTimerInterval = 0
        }

        isSuspended = true

        invalidate()
    }

    /// Resumes filtering that was suspended earlier.
    func resume() {
        guard isSuspended else {
            return
        }

        isSuspended = false

        if shouldRestartTimerWhenResumed {
            shouldRestartTimerWhenResumed = false
            startTimer(timeInterval: suspendedTimerTimerInterval)
            suspendedTimerTimerInterval = 0
        }
    }

    /// Invalidates the timer.
    private func invalidate() {
        timer?.invalidate()
        timerStartDate = nil
        timerTimeInterval = nil
    }

    /// Starts the timer that filters scroll view updates.
    private func startTimer(timeInterval: TimeInterval) {
        if isSuspended {
            shouldRestartTimerWhenResumed = true
            suspendedTimerTimerInterval = max(suspendedTimerTimerInterval, timeInterval)
            return
        }

        // Constrain the remaining time interval so it can't get shorter.
        let timeInterval = max(timeInterval, remainingTimerTimeInterval)

        // This must be called after remainingTimerTimeInterval is referenced above, or
        // else remainingTimerTimeInterval will always return zero.
        cancel()

        // Don't bother starting the timer if the interval would be zero.
        if timeInterval == 0 {
            callDelegatesIfNeeded()
            return
        }

        timerStartDate = Date()

        // This value must be stored separately because Timer.timeInterval, which ideally
        // should be referenced below in remainingTimerTimeInterval, returns 0 for
        // non-repeating timers.
        self.timerTimeInterval = timeInterval

        let timer = Timer(timeInterval: timeInterval, repeats: false, block: { [weak self] (timer: Timer) in
            guard let self = self else {
                return
            }
            self.callDelegatesIfNeeded()
            // This is intentionally called after callDelegatesIfNeeded, not before, to allow
            // for the case where the adjustViewForKeyboardFrameEvent delegate call results in
            // a call to submitScrollRectEvent, which will restart the timer but which will
            // also be handled immediately in callDelegatesIfNeeded.
            self.invalidate()
        })

        self.timer = timer

        // RunLoop.Mode.common must be used instead of the default run loop mode, because
        // otherwise the timer will not fire while the scroll view is scrolling, which will
        // be the case when the user swipes to dismiss the keyboard when the scroll view's
        // keyboardDismissMode is set to interactive, in which case the keyboard frame will
        // be adjusted by KeyboardObserver only after an extended delay.
        RunLoop.current.add(timer, forMode: .common)
    }

    /// Calls the keyboard frame delegate and/or the scroll rect delegate, if needed.
    private func callDelegatesIfNeeded() {
        if let keyboardFrameEvent = keyboardFrameEvent {
            self.keyboardFrameEvent = nil
            keyboardDelegate?.scrollViewFilter(self, adjustViewForKeyboardFrameEvent: keyboardFrameEvent)
        }

        if let scrollRectEvent = scrollRectEvent {
            // Note: It's possible that the call to adjustViewForKeyboardFrameEvent, above,
            // results in a new call to submitScrollRectEvent which will be immediately handled
            // here. The corresponding timer will be invalidated in the timer's closure in
            // startTimer, above.
            self.scrollRectEvent = nil
            scrollDelegate?.scrollViewFilter(self, adjustViewForScrollRectEvent: scrollRectEvent)
        }
    }

    /// The amount of time remaining on the previous timer, or zero if there is no active timer.
    private var remainingTimerTimeInterval: TimeInterval {
        guard timer != nil,
            let timerTimeInterval = timerTimeInterval,
            let timerStartDate = timerStartDate else {
            return 0
        }

        return max(0, timerTimeInterval - Date().timeIntervalSince(timerStartDate))
    }

}
