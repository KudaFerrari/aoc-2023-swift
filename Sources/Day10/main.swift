//
//  File.swift
//  
//
//  Created by Kennedy.Lajustra on 16/12/23.
//

import Foundation
import InputFiles
import Common

struct Input {
    enum Tile: Character, CaseIterable {
        case V = "|"
        case H = "-"
        case BL = "L"
        case BR = "J"
        case TR = "7"
        case TL = "F"
        
        case ground = "."
        case start = "S"
        case inside = "I"
        case outside = "O"
        
        static var loopTiles: [Tile] {
            let nonLoop: [Tile] = [.ground, .start, .inside, .outside]
            return allCases.filter { nonLoop.contains($0) == false }
        }
        
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
            case .start: return nesw
            default : return []
            }
        }
    }
    
    
    
    var map: [[Tile]]
    let W: Int
    let H: Int
    lazy var loopMap: [[Tile]] = {
        return findLoop()
    }()
    lazy var regionMap: [[Tile]] = {
        return insideOutsideMap()
    }()
    
    init(string: String) {
        let map = string
            .split(separator: "\n")
            .map { line in
                line.compactMap { Tile(rawValue: $0) }
            }
        self.map = map
        H = map.count
        W = map[0].count
    }
    
    func findStart() -> Point? {
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
    
    func startTileType(startPos p: Point) -> Tile {
        let edges = findEdges(from: p)
        guard let tile = Tile.loopTiles
            .first(where: {
                $0.edgeDiffs.map { $0+p }.sorted() == edges.sorted()
            })
        else { fatalError("Invalid start tile edge") }
        return tile
    }
    
    private func findLoop() -> [[Tile]] {
        guard let start = findStart() else {
            fatalError("start does not exist")
        }
        var result = Array(repeating: Array.init(repeating: Tile.ground, count: W),
                           count: H)
        assignTile(start, startTileType(startPos: start))
        let startEdge = findEdges(from: start)[0]
        var last = start
        var curr = startEdge
        while true {
            copyTile(curr)
            let next = findNext(last: last, curr: curr)
            if next == start { break }
            last = curr
            curr = next
        }
        return result
        
        func assignTile(_ p: Point, _ tile: Tile) {
            result[p.r][p.c] = tile
        }
        func copyTile(_ p: Point) {
            result[p.r][p.c] = map[p.r][p.c]
        }
    }
    
    func printMaxDist() {
        guard let start = findStart() else {
            fatalError("start does not exist")
        }
        
        var distances = [Point: Int]()
        let startingEdges = findEdges(from: start)
        var last: Point!
        var runningDist: Int!
        
        for edge in startingEdges {
            runningDist = 1
            last = start
            var curr = edge
            while true {
//                print("curr: \(curr)")
                
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
        
    }
    
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
    
    private mutating func insideOutsideMap() -> [[Tile]] {
        var result = loopMap
        for r in 0 ..< H {
            scanHorizontal(r: r)
        }
        for c in 0 ..< W {
            scanVertical(c: c)
        }
        return result
        
        typealias Perm = (prev: Tile, curr: Tile)
        func scanVertical(c: Int) {
            // if found    7 7 F F -
            //      and    J L J L
            // intersects: 0 1 1 0 1
            let crossingPerms: [Perm] = [(.TR, .BL), (.TL, .BR)]
            var temp: Tile? = nil
            var isOutside = true
            for r in 0 ..< H {
                let tile = result[r][c]
                if tile == .H { isOutside.toggle() }
                else if temp != nil,
                        let crossingPerm = crossingPerms.first(where: { p in
                            return p.prev == temp! && p.curr == tile
                        }) {
                    temp = nil
                    isOutside.toggle()
                }
                else if tile == .ground {
                    result[r][c] = isOutside ? .outside : .inside
                }
                else if tile == .TR || tile == .TL { temp = tile }
            }
        }
        
        func scanHorizontal(r: Int) {
            // crossing perm L,7 or F,J
            let crossingPerms: [Perm] = [(.BL, .TR), (.TL, .BR)]
            var temp: Tile? = nil
            var isOutside = true
            for c in 0 ..< W {
                let tile = result[r][c]
                if tile == .V { isOutside.toggle() }
                else if temp != nil,
                        let _ = crossingPerms.first(where: { p in
                            return p.prev == temp! && p.curr == tile
                        }) {
                    temp = nil
                    isOutside.toggle()
                }
                else if tile == .ground {
                    result[r][c] = isOutside ? .outside : .inside
                }
                else if tile == .BL || tile == .TL { temp = tile }
            }
        }
    }
}

func mapToString(_ map: [[Input.Tile]]) -> String {
    return map.map { String($0.map { $0.rawValue }) }.joined(separator: "\n")
}

func solvePart1() {
    let input = Input(string: InputFiles.readInput("Day10"))
    input.printMaxDist()
}

func solvePart2() {
//    let mapA = """
//    .L.......L
//    .S------7.
//    .|L.-..L|.
//    .|.F--7.|.
//    L|.|LL|.|.
//    .|LL7FJ.|L
//    .|..||.L|.
//    .L--JL--J.
//    L...L....L
//    """
//    let regionA = """
//    OOOOOOOOOO
//    OF------7O
//    O|IIIIII|O
//    O|IF--7I|O
//    O|I|OO|I|O
//    O|IL7FJI|O
//    O|II||II|O
//    OL--JL--JO
//    OOOOOOOOOO
//    """
    var input = Input(string: InputFiles.readInput("Day10"))
//    print("loop:", mapToString(input.loopMap), separator: "\n", terminator: "\n")
//    print("region:", mapToString(input.regionMap), separator: "\n", terminator: "\n")
    var count = 0
    for row in input.regionMap {
        for tile in row where tile == .inside {
            count += 1
        }
    }
    print("inside count:", count)
}

solvePart1()
solvePart2()

//print("start loop tile:", input.startTileType(startPos: input.findStart()!))
//print(mapToString(input.loopMap))

//let input2 = Input(string: simpleMap)
//input2.loopMap == simpleMapExpectation
