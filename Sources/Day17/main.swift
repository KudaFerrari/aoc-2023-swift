//
//  File.swift
//  
//
//  Created by Kennedy.Lajustra on 31/12/23.
//

import Foundation
import Collections

struct Point: Comparable, CustomStringConvertible {
    var r: Int
    var c: Int
    
    func multiplied(by factor: Int) -> Point {
        return Point(r: r * factor, c: c * factor)
    }
    
    static let zero = Point(r: 0, c: 0)
    
    static func +(lhs: Point, rhs: Point) -> Point {
        return Point(r: lhs.r + rhs.r, c: lhs.c + rhs.c)
    }
    static func += (lhs: inout Point, rhs: Point) {
        lhs.r += rhs.r
        lhs.c += rhs.c
    }
    static func <= (lhs: Point, rhs: Point) -> Bool {
        lhs.r <= rhs.r && lhs.c <= rhs.c
    }
    static func < (lhs: Point, rhs: Point) -> Bool {
        lhs.r < rhs.r && lhs.c < rhs.c
    }
    var description: String {
        return "[\(r), \(c)]"
    }
}

enum Axis: Equatable, CustomStringConvertible {
    case horizontal
    case vertical
    
    var turned: Axis {
        return self == .horizontal ? .vertical : .horizontal
    }
    var dirs: [Direction] {
        return self == .vertical ? [.up, .down] : [.left, .right]
    }
    var description: String {
        return self == .horizontal ? "H" : "V"
    }
}

enum Direction: Int {
    case right=0, down, left, up
    var dp: Point {
        switch self {
        case .right: .init(r: 0, c: 1)
        case .down: .init(r: 1, c: 0)
        case .left: .init(r: 0, c: -1)
        case .up: .init(r: -1, c: 0)
        }
    }
}

struct WeightMap: CustomStringConvertible {
    let weight: [[Int]]
    let size: Point
    
    init(input: String) {
        let weight = input
        .split(separator: "\n")
        .map { $0.map { Int(String($0))! } }
        self.weight = weight
        size = Point(r: weight.count, c: weight[0].count)
    }
    
    subscript(p: Point) -> Int {
        return weight[p.r][p.c]
    }
    
    var description: String {
        return weight.map {
            $0.reduce("") { partialResult, v in
                partialResult + "\(v)"
            }
        }.joined(separator: "\n")
    }
}

struct Discovery: Comparable {
    let p: Point
    let dist: Int
    let entryAxis: Axis
    
    static func < (lhs: Discovery, rhs: Discovery) -> Bool {
        return lhs.dist <= rhs.dist
    }
}

let INF = 1_000_000_000

struct Distance: CustomStringConvertible {
    var hmap: [[Int]]
    var vmap: [[Int]]
    init(size: Point) {
        hmap = Array(repeating: Array(repeating: INF, count: size.c), count: size.r)
        vmap = Array(repeating: Array(repeating: INF, count: size.c), count: size.r)
    }
    
    subscript(p: Point, axis: Axis) -> Int {
        get {
            axis == .horizontal ? hmap[p.r][p.c] : vmap[p.r][p.c]
        }
        set {
            if axis == .horizontal {
                hmap[p.r][p.c] = newValue
            } else {
                vmap[p.r][p.c] = newValue
            }
        }
    }
    
    var description: String {
        return zip(vmap, hmap).map { vrow, hrow in
            var line = ""
            for v in vrow {
                let s = v == INF ? "~" : String(v)
                line += s.padding(toLength: 3, withPad: " ", startingAt: 0) + " "
            }
            line += " "
            for v in hrow {
                let s = v == INF ? "~" : String(v)
                line += s.padding(toLength: 3, withPad: " ", startingAt: 0) + " "
            }
            return line
        }
        .joined(separator: "\n")
    }
}

func iterateNeighbor(_ p: Point, _ axis: Axis, weightMap: WeightMap, closure: (_ p: Point, _ weight: Int) -> Void) {
    let limit = 3
    for dir in axis.dirs {
        var p = p
        var cweight = 0
        for _ in 0 ..< limit {
            p += dir.dp
            guard .zero <= p, p < weightMap.size else { break }
            cweight += weightMap[p]
            closure(p, cweight)
        }
    }
}

// part 2
func iterateNeighbor2(_ p: Point, _ axis: Axis, weightMap: WeightMap, closure: (_ p: Point, _ weight: Int) -> Void) {
    let maxMove = 10
    let minMove = 4
    for dir in axis.dirs {
        var cweight = 0
        for move in 1...maxMove {
            let p = p + dir.dp.multiplied(by: move)
            guard .zero <= p, p < weightMap.size else { break }
            cweight += weightMap[p]
            if move >= minMove {
                closure(p, cweight)
            }
        }
    }
}


import InputFiles
let input = """
19111
11191
99911
99919
99911
"""
let sampleInput = """
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
"""

func solve(part2: Bool = false) {
    var PQ = Heap<Discovery>()
    let weight = WeightMap(input: InputFiles.readInput("Day17"))
//    let weight = Weight(input: sampleInput)
    let size = weight.size
    var dist = Distance(size: size)
    dist[.zero, .vertical] = 0
    dist[.zero, .horizontal] = 0
    PQ.insert(.init(p: .zero, dist: weight[.zero], entryAxis: .vertical))
    PQ.insert(.init(p: .zero, dist: weight[.zero], entryAxis: .horizontal))
    
    while let curr = PQ.popMin() {
//        print("pop() = \(curr.p), \(curr.entryAxis), dist: \(curr.dist)")
        let p = curr.p
        let entryAxis = curr.entryAxis
        let nextAxis = curr.entryAxis.turned
        func processNeighbor(_ q: Point, weight: Int) {
            if dist[p, entryAxis] + weight < dist[q, nextAxis] {
                dist[q, nextAxis] = dist[p, entryAxis] + weight
                PQ.insert(.init(p: q, dist: dist[q, nextAxis], entryAxis: nextAxis))
            }
        }
        if part2 {
            iterateNeighbor2(curr.p, nextAxis, weightMap: weight, closure: processNeighbor)
        } else {
            iterateNeighbor(curr.p, nextAxis, weightMap: weight, closure: processNeighbor)
        }
//            print("dist:")
//            print(dist)
//            readLine()
    }
    let last = size + Point(r: -1, c: -1)
    print("part \(part2 ? 2 : 1):", min(dist[last, .horizontal], dist[last, .vertical]))
}

func coreTests() {
    func pointTests() {
        let origin = Point(r: 0, c: 0)
        for r in -1 ... 1 {
            for c in -1 ... 1 {
                let p = Point(r: r, c: c)
                print("\(origin) <= \(p) ? \(origin <= p)")
            }
        }
        let size = Point(r: 4, c: 4)
        for r in 3 ... 5 {
            for c in 3 ... 5 {
                let p = Point(r: r, c: c)
                print("\(p) < \(size) ? \(p < size)")
            }
        }
    }
    
    func iterateNeighborTests() {
        let weight = WeightMap(input: input)
        print("""
        weights:
        \(weight)
        iterateNeighbor \(Point.zero), \(Axis.horizontal):
        """)
        iterateNeighbor(.zero, .horizontal, weightMap: weight) { p, weight in
            print("\(p), \(weight)")
        }
        print("iterateNeighbor \(Point.zero), \(Axis.vertical):")
        iterateNeighbor(.zero, .vertical, weightMap: weight) { p, weight in
            print("\(p), \(weight)")
        }
        
        let dist = Distance(size: weight.size)
        print("distances:")
        print(dist)
    }
    
    pointTests()
    iterateNeighborTests()
}
//coreTests()
solve()
solve(part2: true)
