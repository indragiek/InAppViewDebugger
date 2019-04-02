//
//  Snapshot.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 3/31/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import Foundation

/// A snapshot of the UI element tree in its current state.
public struct Snapshot {
    public let identifier = UUID().uuidString
    public let label: ElementLabel
    public let frame: CGRect
    public let isHidden: Bool
    public let snapshotImage: CGImage?
    public let children: [Snapshot]
    private let element: Element
    
    public init(element: Element) {
        self.element = element
        self.label = element.label
        self.frame = element.frame
        self.isHidden = element.isHidden
        self.snapshotImage = element.snapshotImage
        self.children = element.children.map { Snapshot(element: $0) }
    }
}
