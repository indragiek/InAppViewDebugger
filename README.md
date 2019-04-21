# InAppViewDebugger

[![License](https://img.shields.io/github/license/indragiek/InAppViewDebugger.svg)](LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

<p align="center">
<img alt="InAppViewDebugger" src="images/main.png" width="700">
</p>

`InAppViewDebugger` is a library that implements a view debugger with a 3D snapshot view and a hierarchy view, similar to [Reveal](https://revealapp.com) and [Xcode's own view debugger](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/ExaminingtheViewHierarchy.html). The key distinction is, as the project title suggests, that this can be embedded inside the app and used on-device to debug UI issues without needing to be tethered to a computer.

### Features

* **3D snapshot view implemented in SceneKit**: Gesture controls for zooming, panning, and rotating.
* **Hierarchy (tree) view that synchronizes its selection with the 3D view**: This is a feature I really wanted in Xcode, to be able to visually find a view and see where it is in the hierarchy view
* **Support for [iPad](images/main.png) and [iPhone](images/iphone1.png)**: Layouts are designed specifically for each form factor.
* **Extensible:** The base implementation supports `UIView` hierarchies, but this is easily extensible to support any kind of UI framework (e.g. CoreAnimation or SpriteKit)

### Requirements

* iOS 11.0+
* Xcode 10.1+ (framework built for Swift 4.2)

### Installation

#### CocoaPods

Add the following line to your `Podfile`:

```
pod 'InAppViewDebugger', '~> 1.0.0'
```

#### Carthage

Add the following line to your `Cartfile`:

```
github "indragiek/InAppViewDebugger" "1.0.0"
```

### Usage

#### Swift

From code:

```swift
import InAppViewDebugger

@IBAction func showViewDebugger(sender: AnyObject) {
  InAppViewDebugger.present()
}
```

From `lldb`:

```
(lldb) e -lswift -- import InAppViewDebugger
(lldb) e -lswift -- InAppViewDebugger.present()
```

#### Objective-C

```objc
#import <InAppViewDebugger/InAppViewDebugger-Swift.h>

- (IBAction)showViewDebugger:(id)sender {
  [InAppViewDebugger present];
}
```

The `present` function shows the UI hierarchy for your application's key window, presented over the top view controller of the window's root view controller. There are several other methods available on `InAppViewDebugger` for presenting a view debugger for a given window, view, or view controller.

### Controls

#### Focusing on an Element

To focus on the subhierarchy of a particular element, **long press on the element** to bring up the action menu and tap "Focus". The "Log Description" action will log the description of the element to the console, so that if you're attached to Xcode you can copy the address of the object for further debugging.

<p align="center">
<img alt="Focusing on an Element" src="images/focus.gif" width="700">
</p>

#### Adjusting Distance Between Levels

The slider on the bottom left of the snapshot view can be used to adjust the spacing between levels of the hierarchy:

<p align="center">
<img alt="Adjusting Distance Between Levels" src="images/distance.gif" width="700">
</p>

#### Adjusting Visible Levels

The range slider on the bottom right of the snapshot view can be used to adjust the range of levels in the hierarchy that are visible:

<p align="center">
<img alt="Adjusting Visible Levels" src="images/slicing.gif" width="700">
</p>

#### Showing/Hiding Headers

Each UI element has a header above it that shows its class name. These headers can be hidden or shown by **long pressing on an empty area of the snapshot view** to bring up the action menu:

<p align="center">
<img alt="Showing/Hiding Headers" src="images/headers.gif" width="700">
</p>

#### Showing/Hiding Borders

Similarly to the headers, the borders drawn around each element can also be shown or hidden:

<p align="center">
<img alt="Showing/Hiding Borders" src="images/borders.gif" width="700">
</p>
