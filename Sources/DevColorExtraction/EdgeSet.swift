//
//  EdgeSet.swift
//  DevColorExtraction
//
//  Created by Prachi Gauriar on 8/22/25.
//

import Foundation

/// An efficient set of edges.
public struct EdgeSet: OptionSet, Sendable {
    public let rawValue: Int8


    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
}


extension EdgeSet {
    /// The top edge.
    public static let top = EdgeSet(rawValue: 1 << 0)

    /// The right edge.
    public static let right = EdgeSet(rawValue: 1 << 1)

    /// The bottom edge.
    public static let bottom = EdgeSet(rawValue: 1 << 2)

    /// The left edge.
    public static let left = EdgeSet(rawValue: 1 << 3)

    /// The empty edge set.
    public static let none: EdgeSet = []

    /// The right and left edges.
    public static let horizontal: EdgeSet = [.right, .left]

    /// The top and bottom edges.
    public static let vertical: EdgeSet = [.top, .bottom]

    /// All edges.
    public static let all: EdgeSet = [.top, .right, .bottom, .left]
}
