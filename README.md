#KSFramework

An iOS framework containing helpful classes and categories. The framework can be used as a whole or individual components can be used on their own.

##Installation of Entire KSFramework

####CocoaPods
Add the following to your Podfile.
`pod 'KSFramework', '~> 1.0'`

####Manually
Add all `KSFramework` folders to your project except the `Example` folder. Add required Apple frameworks to your project. 

`KSFramework` uses ARC. If you have a project that doesn't use ARC, just add the `-fobjc-arc` compiler flag to all the `KSFramework` files.

######Required Frameworks
- `Accelerate.framework`
- `QuartzCore.framework`

##Components

Each component can be used without including the entire `KSFramework`. See the relevant link for the component you're interested in for specific documentation and installation instructions.

####[KSImageAdditions](https://github.com/kickstandapps/KSFramework/tree/master/KSImageAdditions)

This controller adds several useful categories to add image processing functionality to UIView, UIScrollView, and UIImage.

####[KSInactiveImageView](https://github.com/kickstandapps/KSFramework/tree/master/KSInactiveImageView)

This control acts as a UIImageView, but with the added ability to make an image appear inactive through the use of tinting, scaling, and blurring.

One potential use is locating the KSInactiveImageView in place of a view and passing in a screenshot. The screenshot can then be manipulated to make view appear inactive.

####[KSSlideController](https://github.com/kickstandapps/KSFramework/tree/master/KSSlideController)

This controller allows the use of slide in view controllers on both sides of the screen. This functionality was originally seen in apps such as Facebook for presenting a menu. However, `KSSlideController` is not restricted to just menus. Through the use of configurable properties, a broad range of implementations can be created.

####[KSViewShadow](https://github.com/kickstandapps/KSFramework/tree/master/KSViewShadow)

This controller adds a configurable shadow to any view that is passed to it.

##Contact

developer@kickstandapps.com<br />
http://kickstandapps.com<br />
http://twitter.com/kickstandapps

