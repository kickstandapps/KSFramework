#KSSlideController
__*Part of KSFramework*__

This controller allows the use of slide in view controllers on both sides of the screen. This functionality was originally seen in apps such as Facebook for presenting a menu. However, `KSSlideController` is not restricted to just menus. Through the use of configurable properties, a broad range of implementations can be created.

Some code for this control was forked from the [MFSideMenu](https://github.com/mikefrederick/MFSideMenu) project by Michael Frederick.

=======

![](http://i.imgur.com/Ah5mP.png)  &nbsp;  ![](http://i.imgur.com/KN4IB.png)

##Features

- Universal device support (iPhone + iPad)
- Universal orientation support (Portrait + Landscape)
- Side views on the left and right side of the screen.
- Storyboard support
- View controller containment
- Works with UINavigationController, UITabBarController, and other types of view controllers
- Nice set of configuration options
- Lightweight, simple and readable code.


##Installation

####CocoaPods
Add `pod '****'` to your Podfile.

####Manually
Add the `KSSlideController` folder to your project. Add required `KSFramework` folders to your project. Add required Apple frameworks to your project. 

`KSSlideController` uses ARC. If you have a project that doesn't use ARC, just add the `-fobjc-arc` compiler flag to the `KSSlideController` files.

######Required KSFramework Folders
- `KSImageAdditions`
- `KSInactiveImageView`
- `KSViewShadow`

######Required Frameworks
- `Accelerate.framework`
- `QuartzCore.framework`

##Usage

####Basic Setup

In your app delegate:<br />
```objective-c
#import "KSSlideController.h"

KSSlideController *controller = [KSSlideController slideControllerWithCenterViewController:centerViewController
                                                   leftViewController:leftViewController
                                                   rightViewController:rightViewController];
self.window.rootViewController = container;
[self.window makeKeyAndVisible];
```

####Opening & Closing Side Views

```objective-c
// toggle the left side view
[slideController toggleLeftViewWithCompletion:^{}];
// toggle the right side view
[slideController toggleRightViewWithCompletion:^{}];
// close the side views
[slideController setSlideControllerState:KSSlideControllerStateClosed completion:^{}];
// open the left side view
[slideController setSlideControllerState:KSSlideControllerStateLeftViewOpen completion:^{}];
// open the right side view
[slideController setSlideControllerState:KSSlideControllerStateRightViewOpen completion:^{}];
```

####Pan Modes

You can specify which areas you want to allow pan gestures on:

```objective-c
// enable panning on the center view controllers & the side views (this is the default behavior):
slideController.panMode = KSSlideControllerPanModeCenterView | KSSlideControllerPanModeSideView;

// disable panning on the side views, only allow panning on the center view controller:
slideController.panMode = KSSlideControllerPanModeCenterView;

// disable all panning
// this means that side views can only be shown/hid through method calls
slideViewController.panMode = KSSlideControllerPanModeNone;
```

####Panning Custom Views

You can add panning to any view like so:

```objective-c
[panView addGestureRecognizer:[slideController panGestureRecognizer];
```

####Listening for Controller Events

You can listen for controller state event changes (i.e. side view will open, side view did open, etc.). See KSSlideController.h for the different types of events.

```objective-c
[[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(slideControllerStateEventOccurred:)
                                                name:KSSlideControllerStateNotificationEvent
                                              object:nil];
- (void)slideControllerStateEventOccurred:(NSNotification *)notification {
    KSSlideControllerStateEvent event = [[[notification userInfo] objectForKey:@"eventType"] intValue];
    KSSlideController *slideController = notification.object;
    // ...
}
```

####Menu Width

```objective-c
// Set the width of side views.
- (void)setSideViewWidth:(CGFloat)sideViewWidth animated:(BOOL)animated;
- (void)setLeftViewWidth:(CGFloat)leftViewWidth animated:(BOOL)animated;
- (void)setRightViewWidth:(CGFloat)rightViewWidth animated:(BOOL)animated;
```

####Sliding Options

Control how the center view and each side view slide.

```objective-c

// Overlap of views. Default is "NO" (center view slides over side views).
@property (nonatomic, assign) BOOL sideViewsInFront;

// Open/close animation duration -- user can pan faster than default duration.
@property (nonatomic, assign) CGFloat slideAnimationDuration;

// Adjust how the background view slides in or out.
// 0 = no background view movement (default).
// > 0 & < 1 = ratio of movement to side view width.
// 1 = full background view movement.
@property (nonatomic, assign) CGFloat slideParallaxFactor;

// Adjust how the background view scales as it slides in or out.
// 1 = no scaling (default).
// < 1 = scale of background view when not focused upon.
@property (nonatomic, assign) CGFloat slideScaleFactor;

// Adjust tint and opacity over inactive center view.
@property (nonatomic, strong) UIColor *slideTintColor;
@property (nonatomic, assign) CGFloat slideTintOpacity;

// Slide in blurring of side views (blur -> sharp as side view opens).
// 0 = no blurring (default).
// 1 = full blur.
@property (nonatomic, assign) CGFloat sideViewBlurFactor;

// Slide out blurring of center view (sharp -> blur as side view opens).
// 0 = no blurring (default).
// 1 = full blur.
@property (nonatomic, assign) CGFloat centerViewBlurFactor;

```


####Shadow

KSSlideController gives you the option to show a shadow between the center view & the side views.

```objective-c
// Shadows are only shown for view "in front".
@property (nonatomic, strong) KSViewShadow *centerViewShadow;
@property (nonatomic, strong) KSViewShadow *leftViewShadow;
@property (nonatomic, strong) KSViewShadow *rightViewShadow;
```

See documentation for [KSViewShadow](https://github.com/kickstandapps/KSFramework/tree/master/KSViewShadow) for available shadow parameters.

##Contact

developer@kickstandapps.com<br />
http://kickstandapps.com<br />
http://twitter.com/kickstandapps
