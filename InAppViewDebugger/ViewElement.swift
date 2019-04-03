//
//  View+Element.swift
//  LiveSnapshot
//
//  Created by Indragie Karunaratne on 3/30/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit

/// An element that represents a UIView.
public struct ViewElement: Element {
    public var label: ElementLabel {
        guard let view = view else {
            return ElementLabel(name: nil)
        }
        if let viewController = getViewController(view: view) {
            let name = "\(String(describing: Swift.type(of: viewController))) (\(String(describing: Swift.type(of: view))))"
            return ElementLabel(name: name, classification: .important)
        } else {
            return ElementLabel(name: String(describing: Swift.type(of: view)))
        }
    }
    
    public var frame: CGRect {
        return view?.frame ?? .zero
    }
    
    public var isHidden: Bool {
        return view?.isHidden ?? false
    }
    
    public var snapshotImage: CGImage? {
        guard let view = view else {
            return nil
        }
        return snapshotView(view)
    }

    public var children: AnySequence<Element> {
        guard let view = view else {
            return AnySequence(EmptyCollection())
        }
        return AnySequence(view.subviews.lazy.map {
            ViewElement(view: $0)
        })
    }
    
    public var shortDescription: String {
        guard let view = view else {
            return ""
        }
        let frame = view.frame
        return String(format: "%@: %p (%.1f, %.1f, %.1f, %.1f)", String(describing: type(of: view)), view, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
    }
    
    public var description: String {
        guard let view = view else {
            return ""
        }
        return view.description
    }
    
    private weak var view: UIView?
    
    public init(view: UIView) {
        self.view = view
    }
}

fileprivate func getNearestAncestorViewController(responder: UIResponder) -> UIViewController? {
    if let viewController = responder as? UIViewController {
        return viewController
    } else if let nextResponder = responder.next {
        return getNearestAncestorViewController(responder: nextResponder)
    }
    return nil
}

fileprivate func getViewController(view: UIView) -> UIViewController? {
    if let viewController = getNearestAncestorViewController(responder: view), viewController.viewIfLoaded == view {
        return viewController
    }
    return nil
}

fileprivate func drawView(_ view: UIView) -> CGImage? {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image?.cgImage
}

fileprivate func hideViewsOnTopOf(view: UIView, root: UIView, hiddenViews: inout [UIView]) -> Bool {
    if root == view {
        return true
    }
    var foundView = false
    for subview in root.subviews.reversed() {
        if hideViewsOnTopOf(view: view, root: subview, hiddenViews: &hiddenViews) {
            foundView = true
            break
        }
    }
    if !foundView {
        if !root.isHidden {
            hiddenViews.append(root)
        }
        root.isHidden = true
    }
    return foundView
}

fileprivate func snapshotVisualEffectBackdropView(_ view: UIView) -> CGImage?
{
    guard let window = view.window else {
        return nil
    }
    var hiddenViews = [UIView]()
    defer {
        hiddenViews.forEach { $0.isHidden = false }
    }
    // UIVisualEffectView is a special case that cannot be snapshotted
    // the same way as any other view. From Apple docs:
    //
    //   Many effects require support from the window that hosts the
    //   UIVisualEffectView. Attempting to take a snapshot of only the
    //   UIVisualEffectView will result in a snapshot that does not
    //   contain the effect. To take a snapshot of a view hierarchy
    //   that contains a UIVisualEffectView, you must take a snapshot
    //   of the entire UIWindow or UIScreen that contains it.
    //
    // To snapshot this view, we traverse the view hierarchy starting
    // from the window and hide any views that are on top of the
    // _UIVisualEffectBackdropView so that it is visible in a snapshot
    // of the window. We then take a snapshot of the window and crop
    // it to the part that contains the backdrop view. This appears to
    // be the same technique that Xcode's own view debugger uses to
    // snapshot visual effect views.
    if hideViewsOnTopOf(view: view, root: window, hiddenViews: &hiddenViews) {
        let image = drawView(window)
        let cropRect = window.convert(view.bounds, from: view)
        return image?.cropping(to: cropRect)
    }
    return nil
}

fileprivate func snapshotView(_ view: UIView) -> CGImage? {
    if let superview = view.superview, let _ = superview as? UIVisualEffectView,
        superview.subviews.first == view {
        return snapshotVisualEffectBackdropView(view)
    }
    var subviewHidden = [Bool]()
    subviewHidden.reserveCapacity(view.subviews.count)
    for subview in view.subviews {
        subviewHidden.append(subview.isHidden)
        subview.isHidden = true
    }
    let image = drawView(view)
    for (subview, isHidden) in zip(view.subviews, subviewHidden) {
        subview.isHidden = isHidden
    }
    return image
}
