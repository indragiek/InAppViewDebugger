
//
//  Box.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 4/1/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

/// Reference type that wraps any type.
final class Box<T> {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}
