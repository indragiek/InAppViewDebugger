//
//  HierarchyViewConfiguration.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 4/8/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit

/// Configuration options for the hierarchy (tree) view.
public struct HierarchyViewConfiguration {
    /// The maximum depth that is rendered in the tree view. If the
    /// depth of the item exceeds this value, it will be hidden from
    /// view and can only be accessed by tapping the "Subtree" button
    /// of its parent node.
    ///
    /// Setting this to `nil` means there's no maximum.
    public var maxDepth: Int? = 5
    
    public init() {}
}
