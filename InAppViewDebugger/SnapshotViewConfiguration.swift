//
//  SnapshotViewConfiguration.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 3/31/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import Foundation

/// Configuration options for the 3D snapshot view.
public struct SnapshotViewConfiguration {
    /// The spacing between layers along the z-axis.
    public var zSpacing: CGFloat = 30.0
    
    /// The scene's background color, which gets rendered behind
    /// all content.
    public var backgroundColor = UIColor.white
    
    /// The color of the borders rendered around each view.
    public var borderColor = UIColor.darkGray
    
    /// The background color of the header rendered above each view
    /// that has name text.
    public var headerColor = UIColor.darkGray
    
    /// The corner radius of the header background.
    public var headerCornerRadius: CGFloat = 8.0
    
    /// The top and bottom inset between the header and the name text.
    public var headerVerticalInset: CGFloat = 8.0
    
    /// The font used to render the name text in the header.
    public var headerFont = UIFont.boldSystemFont(ofSize: 13)
    
    /// The opacity of the header.
    public var headerOpacity: CGFloat = 0.8
    
    public init() {}
}
