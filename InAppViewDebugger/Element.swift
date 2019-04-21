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
@objc(IAVDElementLabel) public final class ElementLabel: NSObject {
    /// Classification for an element that determines how it is represented
    /// in the view debugger.
    ///
    /// - normal: An element of normal importance.
    /// - important: An element of higher importance that is highlighted.
    @objc(IAVDElementClassification) public enum Classification: Int {
        case normal
        case important
    }
    
    @objc public let name: String?
    @objc public let classification: Classification
    
    @objc public init(name: String?, classification: Classification = .normal) {
        self.name = name
        self.classification = classification
    }
}

/// A UI element that can be snapshotted.
@objc(IAVDElement) public protocol Element {
    var label: ElementLabel { get }
    var shortDescription: String { get }
    var description: String { get }
    var frame: CGRect { get }
    var isHidden: Bool { get }
    var snapshotImage: CGImage? { get }
    var children: [Element] { get }
}
