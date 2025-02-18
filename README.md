flyerkit-ios-binaries
=====================
FlyerKit is a GUI library for displaying Flipp's flyer content in a native
UIView, supporting iOS 7.0 and higher. Features include:

* Familiar pan and zoom gestures for navigation
* Handling single taps, double taps and long presses (`setTapAnnotations:`,
`setDelegate:`)
* Layering images on top of the flyer (`setBadgeAnnotations:`)
* Highlighting parts of the flyer (`setHighlightAnnotations:`)
* Programmatically animated panning and zooming

Installation
============
FlyerKit is packaged as an iOS Framework. Add `FlyerKit.framework` to your
application's frameworks to install.

Usage
=====
Import `FlyerKit/FlyerKit.h` to get started. The primary class is
`WFKFlyerView`, a UIView subclass that displays the flyer given to
`setFlyerId:usingAccessToken:`. Panning and zooming are automatically enabled.

See the sample application under `FlyerKitSample_Swift/` for a working example.
The sample requires the constants in FlippApiManager.swift to be set
using your merchant identifier and access key, along with a locale and postal
code.

API Documentation
=================
To see how to use the FlyerKit API, please refer to the following documentation:
[https://api.flipp.com/flyerkit/v3.0/documentation](https://api.flipp.com/flyerkit/v3.0/documentation).
