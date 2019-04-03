//
//  Element.swift
//  LiveSnapshot
//
//  Created by Indragie Karunaratne on 3/30/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import CoreGraphics

/// Provides identifying information for an element that is displayed in the
/// view debugger.
public struct ElementLabel {
    /// Classification for an element that determines how it is represented
    /// in the view debugger.
    ///
    /// - normal: An element of normal importance.
    /// - important: An element of higher importance that is highlighted.
    public enum Classification {
        case normal
        case important
    }
    
    public let name: String?
    public let classification: Classification
    
    public init(name: String?, classification: Classification = .normal) {
        self.name = name
        self.classification = classification
    }
}

/// A UI element that can be snapshotted.
public protocol Element: CustomStringConvertible {
    var label: ElementLabel { get }
    var shortDescription: String { get }
    var frame: CGRect { get }
    var isHidden: Bool { get }
    var snapshotImage: CGImage? { get }
    var children: AnySequence<Element> { get }
}
