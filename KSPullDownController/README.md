#KSPullDownController
__*Part of KSFramework*__

This controller allows the use of a view controller to be pulled down do display another view controller. It can be used to create something as simple as a “pull-to-refresh” controller. However, it can also be used to present other views such as menus. Through the use of configurable properties, a broad range of implementations can be created.


##Features

- Universal device support (iPhone + iPad)
- Universal orientation support (Portrait + Landscape)
- Storyboard support
- View controller containment
- Nice set of configuration options
- Lightweight, simple and readable code.


##Installation

####CocoaPods
Add the following to your Podfile.
`pod 'KSFramework/KSPullDownController', '~> 1.0’`

####Manually
Add the `KSPullDownController` folder to your project. There are no dependencies for this controller. 

`KSPullDownController` uses ARC. If you have a project that doesn't use ARC, just add the `-fobjc-arc` compiler flag to the `KSPullDownController` files.


##Usage

####Basic Setup

The easiest way to use `KSPullDownController` is to subclass the controller and use the `scrollView` property to customize the view as you would in a normal view controller (besides the obvious difference of it being a UIScrollView and not a UIView).

The view that will be accessed when the user pulls down should be controlled by it’s own UIViewController. This property can be set either within the custom subclass or externally, such as in the app delegate.

```objective-c
self.pullDownViewController = self.myMenuViewController;

// or

pullDownController.pullDownViewController = [[MyMenuViewController alloc] init];
```

####Opening & Closing the Pull Down View

It is possible to set the state of the KSPullDownController. You may also specify an animation duration to animate the state change.
```objective-c
// Open the pull down view
[pullDownController setPullDownControllerState:KSPullDownControllerStateOpen withAnimationDuration:0.5];
// Close the pull down view
[pullDownController setPullDownControllerState:KSPullDownControllerStateClosed withAnimationDuration:0.5];
```

####Retrieving the State

The current state of the KSPullDownController can be retrieved using the following readonly property. To set the state, please use the method listed above.

```objective-c
@property (nonatomic, assign, readonly) KSPullDownControllerState pullDownControllerState;
```

####Completion Blocks

You can set blocks to be called when the pull down view is opened or closed. This can be used to implement “pull-to-refresh” along with many other possibilities.

```objective-c
// Set a block to be called when the pull down view is opened or closed.
@property (nonatomic, copy) void (^openPullDownViewCompletion)();
@property (nonatomic, copy) void (^closePullDownViewCompletion)();
```

####Pull Down View Height and Break Point

```objective-c
// Set the height of the pull down view.
@property (nonatomic, assign) CGFloat pullDownViewHeight;

// Set the height at which the pull down view will release open/closed.
@property (nonatomic, assign) CGFloat pullDownBreakPoint;
```

####Status Bar Options

The following properties can be used to control the status bar behavior in iOS 7. These properties will not do anything in any version of iOS prior to iOS 7.

```objective-c
// All views will extend behind the status bar to the top of the screen (this is the default behavior):
pullDownController.statusBarMode = KSPullDownStatusBarModeOverlay;

// All views start below the status bar:
pullDownController.statusBarMode = KSPullDownStatusBarModeOffset;
```

The color can also be set at any time.

```objective-c
// Set the color of the status bar
@property (nonatomic, strong) UIColor *statusBarColor;
```

The status bar can behave oddly when an app-wide change is made elsewhere, such as showing or hiding the status bar. The following method should be called in such situations to eliminate issues.

```objective-c
// Call when changing app-wide status bar (hiding/showing).
- (void)updateStatusBarFrame;
```

####Scroll Indicator

This property can be used to show or hide the scroll indicator on the contained UIScrollView. Setting the scroll indicator property on the UIScrollView itself should be avoided as the controller needs to handle the scroll indicator behavior when the pull down view is opened.

```objective-c
@property (nonatomic, assign) BOOL showScrollIndicator;
```

####Delegate

A delegate may be assigned to the KSPullDownController using the following property.

```objective-c
@property (nonatomic, weak) id<KSPullDownControllerDelegate> delegate;
```

The delegate may receive the optional method below to be informed when the ratio of visible pull down view is changed.

For example, as the main UIScrollView is pulled down, exposing the pull down view, the delegate will see this method return increasing numbers from 0.0 (fully closed) to 1.0 (fully open).

```objective-c
// Returns the ratio of pull down view that is shown.
- (void) pullDownViewControllerOpenRatio:(CGFloat)openRatio;
```

##Contact

developer@kickstandapps.com<br />
http://kickstandapps.com<br />
http://twitter.com/kickstandapps
