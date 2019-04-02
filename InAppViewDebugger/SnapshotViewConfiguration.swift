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
    /// Attributes used to customize the header rendered above the UI element.
    public struct HeaderAttributes {
        /// The background color of the header rendered above each view
        /// that has name text.
        public var color = UIColor.darkGray
        
        /// The corner radius of the header background.
        public var cornerRadius: CGFloat = 8.0
        
        /// The top and bottom inset between the header and the name text.
        public var verticalInset: CGFloat = 8.0
        
        /// The font used to render the name text in the header.
        public var font = UIFont.boldSystemFont(ofSize: 13)
        
        /// The opacity of the header.
        public var opacity: CGFloat = 0.90
        
        public init() {}
    }
    
    /// The spacing between layers along the z-axis.
    public var zSpacing: CGFloat = 50.0
    
    /// The scene's background color, which gets rendered behind
    /// all content.
    public var backgroundColor = UIColor.white
    
    /// The attributes for a header of normal importance.
    public var normalHeaderAttributes: HeaderAttributes = {
        var attributes = HeaderAttributes()
        attributes.color = UIColor(red: 0.000, green: 0.533, blue: 1.000, alpha: 1.000)
        return attributes
    }()
    
    /// The attributes for a header of higher importance.
    public var importantHeaderAttributes: HeaderAttributes = {
        var attributes = HeaderAttributes()
        attributes.color = UIColor(red: 0.961, green: 0.651, blue: 0.137, alpha: 1.000)
        return attributes
    }()
    
    public init() {}
}
