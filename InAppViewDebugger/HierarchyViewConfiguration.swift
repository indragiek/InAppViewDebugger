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
    
    /// The colors of the lines displayed to show the depth of the tree.
    ///
    /// If the depth of a node exceeds the number of colors in this array,
    /// the colors will repeat from the beginning.
    public var lineColors = [
        UIColor(red: 0.816, green: 0.008, blue: 0.106, alpha: 1.000),
        UIColor(red: 0.961, green: 0.651, blue: 0.137, alpha: 1.000),
        UIColor(red: 0.290, green: 0.565, blue: 0.886, alpha: 1.000),
        UIColor(red: 0.314, green: 0.886, blue: 0.757, alpha: 1.000),
        UIColor(red: 0.494, green: 0.827, blue: 0.129, alpha: 1.000),
        UIColor(red: 0.565, green: 0.075, blue: 0.996, alpha: 1.000),
        UIColor(red: 0.741, green: 0.063, blue: 0.878, alpha: 1.000),
        UIColor(red: 0.545, green: 0.341, blue: 0.165, alpha: 1.000)
    ]
    
    /// The width of the lines drawn to show the depth of the tree.
    public var lineWidth: CGFloat = 1.0
    
    /// The spacing between the lines drawn to show the depth of the three.
    public var lineSpacing: CGFloat = 12.0
    
    public init() {}
}
