//
//  File.swift
//  
//
//  Created by Kennedy.Lajustra on 23/12/23.
//

import Foundation
import InputFiles

enum `TileType`: Character {
    case empty = "."
    case mirror1 = "/"
    case mirror2 = "\\"
    case splitter1 = "|"
    case splitter2 = "-"
    
    var isSplitter: Bool {
        return self == .splitter1 || self == .splitter2
    }
}

struct Tile {
    let type: TileType
    var energized: Bool = false
    
    init(character: Character) {
        type = TileType(rawValue: character)!
    }
}

enum Direction: Hashable {
    case right, down, left, up
    
    func nextDir(tile: TileType) -> Direction {
        switch tile {
        case .empty:
            return self
        case .mirror1: //  /
            switch self {
            case .right: return .up
            case .down: return .left
            case .left: return .down
            case .up: return .right
            }
        case .mirror2: //  \
            switch self {
            case .right: return .down
            case .down: return .right
            case .left: return .up
            case .up: return .left
            }
        default: fatalError("shouldn't be called from splitter tile")
        }
    }
    
    var dy: Int {
        switch self {
        case .down: return 1
        case .up: return -1
        default: return 0
        }
    }
    var dx: Int {
        switch self {
        case .left: return -1
        case .right: return 1
        default: return 0
        }
    }
}

struct Beam: Hashable {
    let r: Int
    let c: Int
    let dir: Direction
    init(r: Int, c: Int, dir: Direction) {
        self.r = r
        self.c = c
        self.dir = dir
    }
    
    init(project beam: Beam, dir: Direction) {
        self = Beam(r: beam.r + dir.dy,
                    c: beam.c + dir.dx,
                    dir: dir)
    }
}

struct Map {
    var map: [[Tile]]
    var visited: [[Bool]]
    var beams: [Beam]
    var processed = Set<Beam>()
    
    init(string: String, beams: [Beam]) {
        let map = string.split(separator: "\n")
            .map { line in
                line.map { Tile(character: $0) }
            }
        self.map = map
        visited = Array(repeating: Array(repeating: false, count: map[0].count), count: map.count)
        self.beams = beams
    }
    
    // - beam disappears if they go out of bounds
    // - beam can multiply if they run into a splitter
    func next(beam: Beam) -> [Beam] {
        let tileType = map[beam.r][beam.c].type
//        print("\nafter ", tileType.rawValue, terminator: "")
        let results: [Beam]
        switch tileType {
        case .splitter1: //  |
            if beam.dir == .right || beam.dir == .left {
                results = [Beam(project: beam, dir: .up), Beam(project: beam, dir: .down)]
            } else {
                results = [Beam(project: beam, dir: beam.dir)] // continue
            }
        case .splitter2: //  -
            if beam.dir == .up || beam.dir == .down {
                results = [Beam(project: beam, dir: .left), Beam(project: beam, dir: .right)]
            } else {
                results = [Beam(project: beam, dir: beam.dir)]
            }
        default:
            results = [Beam(project: beam, dir: beam.dir.nextDir(tile: tileType))]
        }
        return results.filter { $0.r >= 0 && $0.r < map.count && $0.c >= 0 && $0.c < map[0].count }
//            .map {
//                print(" (r:\($0.r), \($0.c))", terminator: "")
//                return $0
//            }
    }
    
    mutating func tick() {
        var newBeams = [Beam]()
        
        for beam in beams {
            visited[beam.r][beam.c] = true
            if processed.contains(beam) {
                continue
            }
            newBeams += next(beam: beam)
            processed.insert(beam)
        }
        beams = newBeams
    }
    
    var tilesMap: String {
        return map
            .map { String($0.map { $0.type.rawValue }) }
            .joined(separator: "\n")
    }
}

func solvePart1() {
    let input = InputFiles.readInput("Day16")
    var map = Map(string: input, beams: [Beam(r: 0, c: 0, dir: .right)])
    while map.beams.count > 0 {
        //    readLine()
        map.tick()
    }
    
    var ans = 0
    for line in map.visited {
        for visited in line where visited {
            ans += 1
        }
    }
    
    print("part1:", ans)
}

func solvePart2() {
    let input = InputFiles.readInput("Day16")
    struct Start {
        let colRange: Range<Int>
        let rowRange: Range<Int>
        let dir: Direction
    }
    var ans = 0
    let width = input.split(separator: "\n")[0].count
    let height = input.split(separator: "\n").count
    let ranges: [Start] = [
        .init(colRange: 0 ..< width, rowRange: 0 ..< 1, dir: .down),
        .init(colRange: 0 ..< width, rowRange: (height-1) ..< height, dir: .up),
        .init(colRange: 0 ..< 1, rowRange: 0 ..< height, dir: .right),
        .init(colRange: width-1 ..< width, rowRange: 0 ..< height, dir: .left),
    ]
    
    for start in ranges {
        for r in start.rowRange {
            for c in start.colRange {
                var map = Map(string: input, beams: [Beam(r: r, c: c, dir: start.dir)])
                while map.beams.count > 0 {
                    map.tick()
                }
                var visitCount = 0
                for line in map.visited {
                    for visit in line where visit {
                        visitCount += 1
                    }
                }
                print("visitCount:", visitCount)
                ans = max(ans, visitCount)
            }
        }
    }
    print("part2:", ans)
}

solvePart2()

