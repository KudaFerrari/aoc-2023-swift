//
//  File.swift
//  
//
//  Created by Kennedy.Lajustra on 17/12/23.
//

import Foundation

/// (0,0) is at top-left
public struct Point: Hashable, CustomStringConvertible, Comparable {
    public var c: Int
    public var r: Int
    
    public init(c: Int, r: Int) {
        self.c = c
        self.r = r
    }
    
    public var description: String {
        return "(r:\(r),\(c))"
    }
    
    public static func + (lhs: Point, rhs: Point) -> Point {
        return Point(c: lhs.c + rhs.c,
                     r: lhs.r + rhs.r)
    }
    
    public static func < (lhs: Point, rhs: Point) -> Bool {
        if lhs.r == rhs.r { return lhs.c < rhs.c }
        return lhs.r < rhs.r
    }
    
    public func manhattanDistance(_ other: Point) -> Int {
        return abs(other.r - r) + abs(other.c - c)
    }
}
