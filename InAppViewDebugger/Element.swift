//
//  Element.swift
//  LiveSnapshot
//
//  Created by Indragie Karunaratne on 3/30/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import CoreGraphics

/// A UI element that can be snapshotted.
public protocol Element {
    /// The name of the element, to be displayed in the hierarchy view.
    var name: String? { get }
    
    /// The name of the element, to be displayed in the view debugger.
    var viewDebuggerName: String? { get }
    
    /// Returns the frame of the element on screen.
    var frame: CGRect { get }
    
    /// Returns whether the element is hidden.
    var isHidden: Bool { get }
    
    /// Returns a snapshot of the element in its current state.
    var snapshotImage: CGImage? { get }

    /// Returns a sequence of the children of the element.
    var children: AnySequence<Element> { get }
}
