//
//  InAppViewDebugger.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 4/4/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit

/// Takes a snapshot of the specified window and presents the debugger view controller
/// from the root view controller.
///
/// - Parameters:
///   - view: The view controller whose view should be snapshotted.
///   - configuration: Optional configuration for the view debugger.
///   - completion: Completion block to be called once the view debugger has
///   been presented.
public func presentViewDebugger(window: UIWindow? = UIApplication.shared.keyWindow, configuration: Configuration = Configuration(), completion: (() -> Void)? = nil) {
    guard let window = window else {
        return
    }
    let snapshot = Snapshot(element: ViewElement(view: window))
    presentViewDebugger(snapshot: snapshot, rootViewController: window.rootViewController, configuration: configuration, completion: completion)
}

/// Takes a snapshot of the specified view and presents the debugger view controller
/// from the nearest ancestor view controller.
///
/// - Parameters:
///   - view: The view controller whose view should be snapshotted.
///   - configuration: Optional configuration for the view debugger.
///   - completion: Completion block to be called once the view debugger has
///   been presented.
public func presentViewDebugger(view: UIView?, configuration: Configuration = Configuration(), completion: (() -> Void)? = nil) {
    guard let view = view else {
        return
    }
    let snapshot = Snapshot(element: ViewElement(view: view))
    presentViewDebugger(snapshot: snapshot, rootViewController: getNearestAncestorViewController(responder: view), configuration: configuration, completion: completion)
}

/// Takes a snapshot of the view of the specified view controller and presents
/// the debugger view controller.
///
/// - Parameters:
///   - viewController: The view controller whose view should be snapshotted.
///   - configuration: Optional configuration for the view debugger.
///   - completion: Completion block to be called once the view debugger has
///   been presented.
public func presentViewDebugger(viewController: UIViewController?, configuration: Configuration = Configuration(), completion: (() -> Void)? = nil) {
    guard let view = viewController?.view else {
        return
    }
    let snapshot = Snapshot(element: ViewElement(view: view))
    presentViewDebugger(snapshot: snapshot, rootViewController: viewController, configuration: configuration, completion: completion)
}

/// Presents a view debugger for the a snapshot as a modal view controller on
/// top of the specified root view controller.
///
/// - Parameters:
///   - snapshot: The snapshot to render.
///   - rootViewController: The root view controller to present the debugger view
///   controller from.
///   - configuration: Optional configuration for the view debugger.
///   - completion: Completion block to be called once the view debugger has
///   been presented.
public func presentViewDebugger(snapshot: Snapshot, rootViewController: UIViewController?, configuration: Configuration = Configuration(), completion: (() -> Void)? = nil) {
    guard let rootViewController = rootViewController else {
        return
    }
    let debuggerViewController = ViewDebuggerViewController(snapshot: snapshot, configuration: configuration)
    let navigationController = UINavigationController(rootViewController: debuggerViewController)
    topViewController(rootViewController: rootViewController)?.present(navigationController, animated: true, completion: nil)
}
