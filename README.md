# ScrollingContentViewController

[![Travis](https://img.shields.io/travis/drewolbrich/ScrollingContentViewController.svg)](https://travis-ci.org/drewolbrich/ScrollingContentViewController)
[![Platform](https://img.shields.io/badge/platform-iOS-lightgray.svg)](http://developer.apple.com/ios)
[![Swift 4.2](https://img.shields.io/badge/swift-4.2-red.svg?style=flat)](https://developer.apple.com/swift)
[![License](https://img.shields.io/github/license/drewolbrich/ScrollingContentViewController.svg)](LICENSE)
[![Twitter](https://img.shields.io/badge/twitter-@drewolbrich-blue.svg)](http://twitter.com/drewolbrich)

* [Overview](#overview)
* [Background](#background)
* [Installation](#installation)
* [Usage](#usage)
* [Caveats](#caveats)
* [Usage Without Subclassing](#usage-without-subclassing)
* [Examples](#examples)
* [View Controller Properties](#view-controller-properties)
* [Scroll View Properties and Methods](#scroll-view-properties-and-methods)
* [How It Works](#how-it-works)
* [Special Cases Handled](#special-cases-handled)
* [License](#license)

## Overview

ScrollingContentViewController makes it easy to create a view controller with a single scrolling content view, or to convert an existing static view controller into one that scrolls. Most importantly, it takes care of several tricky undocumented edge cases involving the keyboard, navigation controllers, and device rotations.   

## Background

A common UIKit Auto Layout task involves creating a view controller with a fixed layout that is too large to fit older, smaller devices, or devices in landscape orientation, or the area of the screen that remains visible when the keyboard is presented. The problem is compounded when [Dynamic Type](https://developer.apple.com/documentation/uikit/uifont/scaling_fonts_automatically) is used to support large font sizes.  

For example, consider this sign up screen, which fits iPhone Xs, but not iPhone SE with a keyboard:

<img src="https://github.com/drewolbrich/ScrollingContentViewController/raw/master/Images/Overview-Comparison.png" width="888px">

This case can be handled by nesting the view inside a scroll view. You could do this manually in Interface Builder, as described by Apple's [Working with Scroll Views](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithScrollViews.html) documentation, but many steps are required. If your view contains text fields, you'll have to write code to adjust the view to compensate for the presented keyboard, as described in [Managing the Keyboard](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html#//apple_ref/doc/uid/TP40009542-CH5-SW3). However, handling the keyboard robustly is [surprisingly complicated](#keyboard-resize-filtering), especially if your app presents a sequence of screens with keyboards in the context of a navigation controller, or when device orientation support is required.

To simplify this task, ScrollingContentViewController inserts the scroll view into the view hierarchy for you at run time, along with all necessary Auto Layout constraints. 

When used in a storyboard, ScrollingContentViewController exposes an outlet called [`contentView`](#contentView) that you connect to the view that you'd like to make scrollable. This may be the view controller's root view or an arbitrary subview. Everything else is taken care of automatically, including responding to keyboard presentation and device orientation changes.

ScrollingContentViewController can be configured using storyboards or entirely in code. The easiest way to use it is by subclassing the `ScrollingContentViewController` class instead of [`UIViewController`](https://developer.apple.com/documentation/uikit/uiviewcontroller). However, when this is not an option, a helper class called `ScrollingContentViewManager` can be composed with your existing view controller class instead.

An explanation of [how ScrollingContentViewController works internally](#how-it-works) is provided below.

## Installation

To install ScrollingContentViewController using CocoaPods, add this line to your Podfile:

```ruby
pod 'ScrollingContentViewController'
```

To install using Carthage, add this to your Cartfile:

```
github "drewolbrich/ScrollingContentViewController"
```

## Usage

Subclasses of `ScrollingContentViewController` may be configured using [storyboards](#storyboards) or in [code](#code). 

This library may also be used without subclassing, by composing the helper class `ScrollingContentViewManager` instead. Refer to [Usage Without Subclassing](#usage-without-subclassing).

### Storyboards

To configure `ScrollingContentViewController` in a storyboard:

1. Create a subclass of `ScrollingContentViewController` and add a new view controller with that class in Interface Builder. Or, if you have an existing view controller that subclasses [`UIViewController`](https://developer.apple.com/documentation/uikit/uiviewcontroller), modify your view controller to subclass `ScrollingContentViewController` instead.

    ```swift
    import ScrollingContentViewController

    class MyViewController: ScrollingContentViewController {
    
        // ...
        
    }
    ```

2. In Interface Builder's outline view, control-click your view controller and connect its [`contentView`](#contentView) outlet to your view controller's root view or any other subview that you want to make scrollable.

    <img src="https://github.com/drewolbrich/ScrollingContentViewController/raw/master/Images/Usage-Storyboards.png" width="471px">

3. If your view controller defines a [`viewDidLoad`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload) method, call `super.viewDidLoad` if you aren't already doing so.

    ```swift
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ...
    }
    ```

4. At run time, the `ScrollingContentViewController` property [`contentView`](#contentView) will now reference the superview of the controls that you laid out in Interface Builder. This superview will no longer be referenced by the [`view`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621460-view) property, which will instead reference an empty root view behind the scrolling content view. If necessary, revise your code to reflect this change.

Your content view will now scroll, provided that you ensure that the content view's Auto Layout constraints [sufficiently define its size](#auto-layout-considerations), and that this size is larger than the safe area.

### Code

To integrate `ScrollingContentViewController` programmatically:

1. Subclass `ScrollingContentViewController` instead of [`UIViewController`](https://developer.apple.com/documentation/uikit/uiviewcontroller).

    ```swift
    import ScrollingContentViewController

    class MyViewController: ScrollingContentViewController {
    
        // ...
        
    }
    ```

2. In your view controller's [`viewDidLoad`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload) method, assign a new view to the [`contentView`](#contentView) property. Add all of your controls to this view instead of referencing the [`view`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621460-view) property so they can scroll freely. The view controller's root view referenced by its [`view`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621460-view) property now acts as a background view behind the scrolling content view. 

    ```swift
    override func viewDidLoad() {
        super.viewDidLoad()

        contentView = UIView()
        
        // Add all controls to contentView instead of view.
        // ...
    }
    ```
    
You may also assign [`contentView`](#contentView) to a subview of your view controller's root view, in which case only that subview will be made scrollable.

## Caveats

### Auto Layout Considerations

For ScrollingContentViewController to determine the height of the scroll view's content, the content view must contain an unbroken chain of constraints and views stretching from the content view’s top edge to its bottom edge. This is also true for the content view's width. This is consistent with the approach described by Apple's [Working with Scroll Views](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithScrollViews.html) documentation.

If you don't define sufficient Auto Layout constraints, ScrollingContentViewController won't be able to determine the size of your content view, and it will not scroll as expected.

If you'd like your content view to stretch to take advantage of the full visible area of the scroll view, relax your constraints to allow for this. For example, in Interface Builder, change the Relation property of one of your height constraints to Greater Than or Equal.

To determine the size of the scroll view's content size, ScrollingContentViewController creates width and height constraints with a relation greater than or equal to the width and height of the scroll view's safe area. The priority of these constraints is 500. Consequently, if you create an unbroken chain of constraints with priority [`defaultHigh`](https://developer.apple.com/documentation/uikit/uilayoutpriority/1622249-defaulthigh) (750) or [`required`](https://developer.apple.com/documentation/uikit/uilayoutpriority/1622241-required) (1000), they will take precedence over ScrollingContentViewController's internal minimum width and height constraints, and your content view will not stretch to fill the scroll view's safe area.

If the size of your view controller is intentionally highly constrained (e.g. consisting exclusively of constraints with [`required`](https://developer.apple.com/documentation/uikit/uilayoutpriority/1622241-required) priority and lacking [`greaterThanOrEqual`](https://developer.apple.com/documentation/uikit/nslayoutconstraint/relation/greaterthanorequal) relation constraints), you may see Auto Layout constraint errors in Interface Builder if the constraints don't match the simulated size of the view, for example, when you switch between simulated device sizes. The easiest way to resolve this issue is to reduce the priority of one of your constraints. The value 240 is a good choice because it is lower than the default content hugging priority (250) and consequently, it will help avoid the undesirable behavior where text fields and labels without height constraints stretch vertically.

<img src="https://github.com/drewolbrich/ScrollingContentViewController/raw/master/Images/Usage-Auto-Layout-Considerations.png" width="663px">

### Intrinsic Content Size

If you'd prefer not to use Auto Layout, the content view's size may be specified using [`intrinsicContentSize`](https://developer.apple.com/documentation/uikit/uiview/1622600-intrinsiccontentsize) instead of constraints.

The default `UIView` content hugging priority is [`defaultLow`](https://developer.apple.com/documentation/uikit/uilayoutpriority/1622250-defaultlow), and consequently, the content view's intrinisic content size will normally be overridden by the minimum size constraints that ScrollingContentViewController assigns. If you'd like [`intrinsicContentSize`](https://developer.apple.com/documentation/uikit/uiview/1622600-intrinsiccontentsize) to take precedence over these constraints, set the content view's content hugging priority to [`required`](https://developer.apple.com/documentation/uikit/uilayoutpriority/1622241-required).

### Changing the Background Color

The content view is positioned within the scroll view's safe area. Consequently, the content view's background color won't extend underneath the status bar, home indicator, navigation bar, or toolbar.

<img src="https://github.com/drewolbrich/ScrollingContentViewController/raw/master/Images/Caveats-Background-Color-Content-View.png" width="233px">

To specify a background color that extends to the edges of the screen:

1. Set the background color of the view controller's root view to the desired color. This view will be visible behind the scroll view, which is transparent.

2. Set the content view's background color to `nil` so it is also transparent.

For example:

```swift
view.backgroundColor = UIColor(red: 1, green: 0.949, blue: 0.788, alpha: 1)
contentView.backgroundColor = nil
```

### Resizing the Content View

If you make changes to your content view that modify its size, you must call the scroll view's [`setNeedsLayout`](https://developer.apple.com/documentation/uikit/uiview/1622601-setneedslayout) method, or otherwise the scroll view's content size won't be updated to reflect the size change, and your view may not scroll correctly.

For example, after updating the view's [`NSLayoutConstraint.constant`](https://developer.apple.com/documentation/uikit/nslayoutconstraint/1526928-constant) properties, you may animate the changes like this:

```swift
UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, 
        options: [], animations: {
    self.scrollView.setNeedsLayout()
    self.scrollView.layoutIfNeeded()
}, completion: nil)
```

### Oversized View Controllers

In Interface Builder, it's possible to design a view controller that is intentionally larger than the height of the screen. To do this, change the view controller's simulated size to Freeform and adjust its height. When used with ScrollingContentViewController, the view controller's oversized content view will scroll freely, assuming its constraints require it to be larger than the screen.

<img src="https://github.com/drewolbrich/ScrollingContentViewController/raw/master/Images/Usage-Oversized-View-Controllers.png" width="609px">

## Usage Without Subclassing

When subclassing `ScrollingContentViewController` is not an option, the helper class `ScrollingContentViewManager` can be composed with your view controller instead:

```swift
import ScrollingContentViewController

class MyViewController: UIViewController {

    lazy var scrollingContentViewManager = ScrollingContentViewManager(hostViewController: self)

    @IBOutlet weak var contentView: UIView!

    override func loadView() {
        // Load all controls and connect all outlets defined by Interface Builder.
        super.loadView()

        scrollingContentViewManager.loadView(forContentView: contentView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // When ScrollingContentViewManager.contentView is first assigned, this has the
        // side effect of adding a scroll view to the content view's superview, and
        // adding the content view to the scroll view.
        scrollingContentViewManager.contentView = contentView

        // Set the content view's background color to transparent so the root view is
        // visible behind it.
        contentView.backgroundColor = nil
    }

    // Note: This method is not strictly required, but logs a warning if the content
    // view's size is undefined.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        scrollingContentViewManager.viewWillAppear(animated)
    }

    // Note: This is only required in apps that support device orientation changes.
    override func viewWillTransition(to size: CGSize,
            with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        scrollingContentViewManager.viewWillTransition(to: size, with: coordinator)
    }

    // Note: This is only required in apps with navigation controllers that are used to
    // push sequences of view controllers with text fields that become the first
    // responder in `viewWillAppear`.
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        scrollingContentViewManager.viewSafeAreaInsetsDidChange()
    }

}
```

The `ScrollingContentViewManager` class supports all of the same [properties](#properties) and [methods](#methods) as `ScrollingContentViewController`.

`ScrollingContentViewManager` can also be used to create a scrolling view controller programatically:

```swift
import ScrollingContentViewController

class MyViewController: UIViewController {

    lazy var scrollingContentViewManager = ScrollingContentViewManager(hostViewController: self)

    let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate your content view here.
        // ...

        // When ScrollingContentViewManager.contentView is first assigned, this has the
        // side effect of adding a scroll view to the view controller's root view, and
        // adding the content view to the scroll view.
        scrollingContentViewManager.contentView = contentView
    }

    // Note: This method is not strictly required, but logs a warning if the content
    // view's size is undefined.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        scrollingContentViewManager.viewWillAppear(animated)
    }

    // Note: This is only required in apps that support device orientation changes.
    override func viewWillTransition(to size: CGSize,
            with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        scrollingContentViewManager.viewWillTransition(to: size, with: coordinator)
    }

    // Note: This is only required in apps with navigation controllers that are used to
    // push sequences of view controllers with text fields that become the first
    // responder in `viewWillAppear`.
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        scrollingContentViewManager.viewSafeAreaInsetsDidChange()
    }

}
```

## Examples

* [StoryboardExample](Examples/StoryboardExample) - Example configuring `ScrollingContentViewController` in a storyboard.

* [CodeExample](Examples/CodeExample) - Example using code only.

* [ManagerExample](Examples/ManagerExample) - Example using `ScrollingContentViewManager` and class composition instead of subclassing `ScrollingContentViewController`.

* [SequenceExample](Examples/SequenceExample) - Example of a sequence of pushed scrolling view controllers with keyboards in the context of a navigation controller. 

* [ReassignExample](Examples/ReassignExample) - Example of dynamically reassigning `contentView`.

## View Controller Properties

The `ScrollingContentViewController` and `ScrollingContentViewManager` classes share the following properties:

### contentView

The scrolling content view parented to the scroll view. 

When this property is first assigned, the view that it references is parented to [`scrollView`](#scrollView), which is then added to the view controller's view hierarchy.

If the content view already has a superview, the scroll view replaces it in the view hierarchy and all of the superview's constraints that reference the content view are retargeted to the content view. The content view's width and height constraints and autoresizing mask are transferred to the scroll view.

If the content view has no superview, the scroll view is parented to the view controller's root view and its frame and autoresizing mask are defined to track the root view's bounds.

If the [`contentView`](#contentView) property is later reassigned, the new content view replaces the old one as the subview of the scroll view, and the scroll view is left otherwise unmodified. 

### scrollView

The scroll view to which [`contentView`](#contentView) is parented.

You may safely modify any of the scroll view's properties. For example, setting [`keyboardDismissMode`](https://developer.apple.com/documentation/uikit/uiscrollview/1619437-keyboarddismissmode) to [`interactive`](https://developer.apple.com/documentation/uikit/uiscrollview/keyboarddismissmode/interactive) or [`onDrag`](https://developer.apple.com/documentation/uikit/uiscrollview/keyboarddismissmode/ondrag) will allow the user to dismiss the keyboard by dragging the scroll view.

The scroll view is implemented as a subclass of [`UIScrollView`](https://developer.apple.com/documentation/uikit/uiscrollview) that provides [additional properties and methods](#scroll-view-properties-and-methods) which you may use to modify its behavior.

### shouldResizeContentViewForKeyboard

A Boolean value that determines whether or not the content view is resized when the keyboard is presented.

* `true` - When the keyboard is presented, the content view shrinks to fit the portion of the scroll view not overlapped by the keyboard, to the extent that this is permitted by the content view's Auto Layout constraints. With an appropriate use of constraints, this may allow for more effective use of the reduced screen real estate.

* `false` - When the keyboard is presented, the content view's size remains unchanged. This is the default value.

### shouldAdjustAdditionalSafeAreaInsetsForKeyboard

A Boolean value that determines whether or not the view controller's [`additionalSafeAreaInsets`](https://developer.apple.com/documentation/uikit/uiviewcontroller/2902284-additionalsafeareainsets) property is adjusted when the keyboard is presented.

* `true` - When the keyboard is presented, the view controller's [`additionalSafeAreaInsets`](https://developer.apple.com/documentation/uikit/uiviewcontroller/2902284-additionalsafeareainsets) property is adjusted to compensate for the portion of the scroll view that is overlapped by the keyboard, ensuring that all of the content view's content is accessible via scrolling. This is the default value.

* `false` - When the keyboard is presented, the view controller's [`additionalSafeAreaInsets`](https://developer.apple.com/documentation/uikit/uiviewcontroller/2902284-additionalsafeareainsets) property remains unchanged. Assign this value if you'd prefer to implement your own keyboard presentation compensation behavior.

## Scroll View Properties and Methods

The scroll view referenced by the [`scrollView`](#scrollView) property of `ScrollingContentViewController` and `ScrollingContentViewManager` provides the following additional properties and methods, beyond those normally provided by [`UIScrollView`](https://developer.apple.com/documentation/uikit/uiscrollview):

### visibilityScrollMargin

A floating point value representing a vertical margin applied to the first responder view frame when the scroll view is scrolled to make the first responder visible. The default value is 0, which matches the UIKit default behavior.

### scrollRectToVisible(animated:margin:)

Scrolls the scroll view to make the rect visible.

The optional `margin` parameter specifies an extra margin around the rect which is also made visible. If `margin` is unspecified or `nil`, the value of [`visibilityScrollMargin`](#visibilityScrollMargin) will be used instead.

### scrollViewToVisible(animated:margin:)

Scrolls the scroll view to make the specified view visible.

The optional `margin` parameter specifies an extra margin around the view which is also made visible. If `margin` is unspecified or `nil`, the value of [`visibilityScrollMargin`](#visibilityScrollMargin) will be used instead.

### scrollFirstResponderToVisible(animated:margin:)

Scrolls the scroll view to make the first responder visible. If no first responder is defined, this method has no effect.

The optional `margin` parameter specifies an extra margin around the first responder which is also made visible. If `margin` is unspecified or `nil`, the value of [`visibilityScrollMargin`](#visibilityScrollMargin) will be used instead.

## How It Works

### View Hierarchy

ScrollingContentViewController inserts a scroll view between the content view and its superview, using Auto Layout to constrain the scroll view's content layout guide to the size of the content view. The content view's size is also constrained to be greater than or equal to the size of the scroll view's safe area, so it can utilize the full area of the screen assigned to the scroll view.

<img src="https://github.com/drewolbrich/ScrollingContentViewController/raw/master/Images/How-It-Works-View-Hierarchy.png" width="496px">

When the content view is first assigned, if it has a superview, the scroll view replaces it in the view hierarchy and all of the superview's constraints that reference the content view are retargeted to the content view. The content view's width and height constraints and autoresizing mask are transferred to the scroll view.

If the content view has no superview, the scroll view is parented to the view controller's root view and its frame and autoresizing mask are defined to track the root view's bounds.

If the ScrollingContentViewController's `contentView` property references its root view, a new `UIView` is allocated and replaces it as the root view so that the scroll view will have an appropriate view to be parented to. 

The content view's superview does not necessarily have to be the view controller's root view, and does not have to match the root view's size.

Refer to Apple's [Working with Scroll Views](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithScrollViews.html) documentation for a detailed description of how scroll views are used with Auto Layout.

### Additional Safe Area Insets

When the keyboard is presented, ScrollingContentViewController modifies the container view controller's [`additionalSafeAreaInsets`](https://developer.apple.com/documentation/uikit/uiviewcontroller/2902284-additionalsafeareainsets) property to compensate for the area of the keyboard that overlaps the scroll view, as recommended in Apple's [Managing the Keyboard](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html#//apple_ref/doc/uid/TP40009542-CH5-SW3) documentation.

Although ScrollingContentViewController modifies [`additionalSafeAreaInsets`](https://developer.apple.com/documentation/uikit/uiviewcontroller/2902284-additionalsafeareainsets) when the keyboard is presented, it restores it to its original value when the keyboard is dismissed. This allows [`additionalSafeAreaInsets`](https://developer.apple.com/documentation/uikit/uiviewcontroller/2902284-additionalsafeareainsets) to be used for other purposes, such as custom tool palettes.

During development, an alternate approach suggested by Apple, modifying the scroll view's content size, was also tried. This requires adjusting the scroll view's [`scrollIndicatorInsets`](https://developer.apple.com/documentation/uikit/uiscrollview/1619427-scrollindicatorinsets) property to compensate for the content size change. Unfortunately, on iPhone Xs in landscape orientation, doing so has the side effect of awkwardly shifting the scroll indicator away from the edge of the screen.

### Keyboard Resize Filtering

When a text field becomes the first responder, UIKit presents the keyboard. If the user taps another text field, changing the first responder, UIKit may adjust the keyboard's height if an input accessory view is specified. These changes may generate a sequence of [`keyboardWillShow`](https://developer.apple.com/documentation/uikit/uiresponder/1621576-keyboardwillshownotification) notifications, each with different keyboard heights.

As an extreme example, if the user populates an email text field by tapping on an AutoFill input accessory view item, and this action has the side effect of causing a password text field to become the first responder, one [`keyboardWillHide`](https://developer.apple.com/documentation/uikit/uikeyboardwillhidenotification) notification and two [`keyboardWillShow`](https://developer.apple.com/documentation/uikit/uiresponder/1621576-keyboardwillshownotification) notifications will be posted within a span of 0.1 seconds.

If ScrollingContentViewController were to respond to each of these notifications individually, this would cause awkward discontinuities in the scroll view animation that accompanies changes to the keyboard's height.

To work around this issue, ScrollingContentViewController filters out sequences of notifications that occur within a small time window, acting only on the final assigned keyboard frame in the sequence. This appears to be consistent with the way Apple's iOS apps are implemented. As of iOS 12, Apple's apps respond to keyboard size changes only after a short delay, and do not animate their views in concert with the keyboard's animation.

During a device orientation transition, a [`keyboardWillHide`](https://developer.apple.com/documentation/uikit/uikeyboardwillhidenotification) notification is posted before the animation starts, followed by [`keyboardWillShow`](https://developer.apple.com/documentation/uikit/uiresponder/1621576-keyboardwillshownotification) after it ends, even though the keyboard remains visible during the transition. Because the duration of the animation exceeds the filtering time window, it is therefore necessary to temporarily suspend filtering during the transition. Otherwise, the content view would resize unnecessarily.

Finally, ScrollingContentViewController correctly handles the case where changes to the size or layout of the scroll view's content may occur in response to keyboard presentation or device orientation changes (in particular when [`shouldResizeContentViewForKeyboard`](#shouldResizeContentViewForKeyboard) is `true`), invaliding the coordinate space of the rectangle passed to  [`scrollRectToVisible`](https://developer.apple.com/documentation/uikit/uiscrollview/1619439-scrollrecttovisible) (most importantly, in the case when that method is called automatically by iOS after keyboard changes) which would otherwise result in the scroll view scrolling by an inappropriate amount or leaving the scroll view with a content offset that is outside of the legal scrolling range.

Refer to Apple's [Managing the Keyboard](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html#//apple_ref/doc/uid/TP40009542-CH5-SW3) documentation for more information about responding to changes in keyboard visibility.

## Special Cases Handled

In addition to [keyboard resize filtering](#keyboard-resize-filtering), above, ScrollingContentViewController addresses a few other edge cases:

### Navigation Controllers

ScrollingContentViewController correctly handles sequences of pushed view controllers in the context of a navigation controller, in particular in the case when each view controller calls a text field's [`becomeFirstResponder`](https://developer.apple.com/documentation/uikit/uiresponder/1621113-becomefirstresponder) method in [`viewWillAppear`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621510-viewwillappear), such that the keyboard remains visible across view controller transitions. 

### Device Orientation Changes

When device orientation changes occur, ScrollingContentViewController improves upon the default scroll view behavior by pinning the upper left corner of the scroll view in place, while at the same time preventing out of range content offsets. This matches the behavior of many of Apple's iOS apps.

### keyboardDismissMode

ScrollingContentViewController automatically enables [`UIScrollView.alwaysBounceVertical`](https://developer.apple.com/documentation/uikit/uiscrollview/1619383-alwaysbouncevertical) while the keyboard is presented if [`UIScrollView.keyboardDismissMode`](https://developer.apple.com/documentation/uikit/uiscrollview/1619437-keyboarddismissmode) is set to anything other than [`none`](https://developer.apple.com/documentation/uikit/uiscrollview/keyboarddismissmode/none), so the keyboard can be dismissed even if the view is too short to normally allow scrolling.

### Arbitrary Scroll View Sizes

ScrollingContentViewController correctly handles the case when the scroll view doesn't cover the full extent of the screen, in which case it may only partially intersect the keyboard.

### Text Field Animation Artifacts

As of iOS 12, if the user taps a sequence of custom text fields, UIKit may awkwardly animate the text field's text. ScrollingContentViewController suppresses this animation.

## License

This project is licensed under the terms of the MIT open source license. Please refer to the file [LICENSE](LICENSE) for the full terms.
