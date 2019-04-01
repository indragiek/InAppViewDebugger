//
//  Snapshot.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 3/31/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

/// A snapshot of the UI element tree in its current state.
public struct Snapshot {
    /// The name of the element, to be displayed in the hierarchy view.
    public let name: String?
    
    /// The name of the element, to be displayed in the view debugger.
    public let viewDebuggerName: String?
    
    /// The frame of the element on screen.
    public let frame: CGRect
    
    /// Returns whether the element is hidden.
    public let isHidden: Bool
    
    /// A snapshot of the element in its current state.
    public private(set) var snapshotImage: CGImage?
    
    /// An array of the snapshots of the child elements.
    public let children: [Snapshot]
    
    /// The element being snapshotted.
    private let element: Element
    
    public init(element: Element) {
        self.element = element
        self.name = element.name
        self.viewDebuggerName = element.viewDebuggerName
        self.frame = element.frame
        self.isHidden = element.isHidden
        self.snapshotImage = element.snapshotImage
        self.children = element.children.map { Snapshot(element: $0) }
    }
}
