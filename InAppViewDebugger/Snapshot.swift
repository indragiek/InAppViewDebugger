//
//  Snapshot.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 3/31/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import Foundation

/// A snapshot of the UI element tree in its current state.
@objc(IAVDSnapshot) public final class Snapshot: NSObject {
    @objc public let identifier = UUID().uuidString
    @objc public let label: ElementLabel
    @objc public let frame: CGRect
    @objc public let isHidden: Bool
    @objc public let snapshotImage: CGImage?
    @objc public let children: [Snapshot]
    @objc public let element: Element
    
    @objc public init(element: Element) {
        self.label = element.label
        self.frame = element.frame
        self.isHidden = element.isHidden
        self.snapshotImage = element.snapshotImage
        self.children = element.children.map { Snapshot(element: $0) }
        self.element = element
    }
}
