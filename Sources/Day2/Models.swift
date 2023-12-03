//
//  Models.swift
//  
//
//  Created by Kennedy L on 03/12/23.
//

import Foundation

public struct CubeCount {
    let red: Int
    let green: Int
    let blue: Int
    
    public func power() -> Int {
        return red * green * blue
    }
    
    public static func <= (_ lhs: CubeCount, _ rhs: CubeCount) -> Bool {
        return lhs.red <= rhs.red && lhs.green <= rhs.green && lhs.blue <= rhs.blue
    }
    
    public init(red: Int, green: Int, blue: Int) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    public init(substring line: Substring) {
        var r = 0, g = 0, b = 0
        
        for sub in line.split(separator: ", ") {
            let count = Int(sub.split(separator: " ").first!)!
            if sub.contains("red") {
                r = count
            } else if sub.contains("green") {
                g = count
            } else if sub.contains("blue") {
                b = count
            }
        }
        
        self.red = r
        self.green = g
        self.blue = b
    }
}

public struct GameInfo {
    public let id: Int
    let counts: [CubeCount]
    
    public init(substring line: Substring) {
        let subs = line.split(separator: ": ")
        let id = Int(String(subs.first!.replacingOccurrences(of: "Game ", with: "")))!
        self.id = id
        self.counts = subs.last!.split(separator: "; ")
            .map { CubeCount(substring: $0) }
    }
    
    public func isPossible(ifCount count: CubeCount) -> Bool {
        counts.allSatisfy { $0 <= count }
    }
    
    public func maxOfEachColor() -> CubeCount {
        let r = counts.map { $0.red }.max()!
        let g = counts.map { $0.green }.max()!
        let b = counts.map { $0.blue }.max()!
        return CubeCount(red: r, green: g, blue: b)
    }
}

extension CubeCount: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "[\(red),\(green),\(blue)]"
    }
}

extension GameInfo: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Game \(id): \(counts.debugDescription)"
    }
}
