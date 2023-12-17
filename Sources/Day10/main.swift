//
//  File.swift
//  
//
//  Created by Kennedy.Lajustra on 16/12/23.
//

import Foundation
import InputFiles

struct Input {
    var map: [[Tile]]
    
    enum Tile: Character {
        case V = "|"
        case H = "-"
        case BL = "L"
        case BR = "J"
        case TR = "7"
        case TL = "F"
        case ground = "."
        case start = "S"
        
        var edgeDiffs: [Point] {
            let nesw = [Point(c: 0, r: -1),
                        Point(c: 1, r: 0),
                        Point(c: 0, r: 1),
                        Point(c: -1, r: 0)]
            switch self {
            case .V: return [nesw[0], nesw[2]]
            case .H: return [nesw[1], nesw[3]]
            case .BL: return [nesw[0], nesw[1]]
            case .BR: return [nesw[0], nesw[3]]
            case .TR: return [nesw[2], nesw[3]]
            case .TL: return [nesw[2], nesw[1]]
            case .ground: return []
            case .start: return nesw
            }
        }
    }
    
    init(string: String) {
        let map = string
            .split(separator: "\n")
            .map { line in
                line.compactMap { Tile(rawValue: $0) }
            }
        self.map = map
        Input.process(map: map)
    }
    
    // (0,0) is at top-left
    struct Point: Hashable, CustomStringConvertible {
        var c: Int
        var r: Int
        var description: String {
            return "(r:\(r),\(c))"
        }
        static func + (lhs: Point, rhs: Point) -> Point {
            return Point(c: lhs.c + rhs.c,
                         r: lhs.r + rhs.r)
        }
    }
    
    static func findStart(map: [[Tile]]) -> Point? {
        var r = 0
        while r < map.count {
            var c = 0
            while c < map[r].count {
                if map[r][c] == .start {
                    return Point(c: c, r: r)
                }
                c += 1
            }
            r += 1
        }
        return nil
    }
    
    static func process(map: [[Tile]]) {
        guard let start = findStart(map: map) else {
            fatalError("start does not exist")
        }
        
        let H = map.count
        let W = map[0].count
        var distances = [Point: Int]()
        var edges = findEdges(from: start)
        var last: Point!
        var runningDist: Int!
        
        for edge in edges {
            runningDist = 1
            last = start
            var curr = edge
            while true {
                print("curr: \(curr)")
                
                if distances[curr] != nil {
                    distances[curr] = min(distances[curr]!, runningDist)
                } else {
                    distances[curr] = runningDist
                }
                
                let next = findNext(last: last, curr: curr)
                runningDist += 1
                if next == start { break }
                last = curr
                curr = next
            }
        }
        
        let maxDist = distances.values.max()!
        print("max distance:", maxDist)
        
        func findNext(last: Point, curr: Point) -> Point {
            let diffs = map[curr.r][curr.c].edgeDiffs
            guard let dn = diffs.first(where: { curr + $0 != last }) else {
                fatalError("no edge from \(curr) excluding \(last)")
            }
            return curr + dn
        }
        
        func findEdges(from p: Point, excluding ep: Point? = nil) -> [Point] {
            // di = N, E, S, W
            let dr = [-1, 0, 1, 0]
            let dc = [0, 1, 0, -1]
            let allowedTile: [[Tile]] = [[.V, .TL, .TR], // north
                                         [.H, .TR, .BR], // east
                                         [.V, .BL, .BR], // south
                                         [.H, .BL, .TL]] // west
            var result = [Point]()
            for di in 0 ..< 4 {
                let r = p.r + dr[di], c = p.c + dc[di]
                guard r >= 0, r < H, c >= 0, c < W else { continue } // out of bounds
                if let ep, r == ep.r, c == ep.c { continue } // excluded
                
                let tile = map[r][c]
                if allowedTile[di].contains(tile) {
                    result.append(Point(c: c, r: r))
                }
            }
            return result
        }
    }
}

let input = Input(string: InputFiles.readInput("Day10"))
