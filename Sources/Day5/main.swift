//
//  File.swift
//  
//
//  Created by Kennedy.Lajustra on 13/12/23.
//

import Foundation
import InputFiles

enum Day5 {
    struct Range: CustomDebugStringConvertible {
        let first: Int
        let last: Int
        
        init?(start: Int, length: Int) {
            guard length > 0 else { return nil }
            self.first = start
            self.last = start + length - 1
        }
        
        init(first: Int, last: Int) {
            self.first = first
            self.last = last
        }
        
        var debugDescription: String {
            return "(\(first),\(last))"
        }
    }
    
    struct RangeMap: CustomDebugStringConvertible {
        let from: Range
        let to: Range
        
        init?(sourceStart: Int, destStart: Int, length: Int) {
            guard length > 0 else { return nil }
            from = Range(start: sourceStart, length: length)!
            to = Range(start: destStart, length: length)!
        }
        
        init?(substring: Substring) {
            let numbers = substring.split(separator: " ").compactMap { Int($0) }
            self.init(sourceStart: numbers[1],
                      destStart: numbers[0],
                      length: numbers[2])
        }
        
        func map(value: Int) -> Int? {
            guard from.first <= value, value <= from.last else { return nil }
            return to.first + value - from.first
        }
        
        var debugDescription: String {
            return "\(from.debugDescription) => \(to.debugDescription)"
        }
    }
    
    struct Mapper {
        let ranges: [RangeMap]
        
        init?(substring: Substring) {
            ranges = substring.split(separator: ":\n")[1]
                .split(separator: "\n")
                .compactMap { RangeMap(substring: $0) }
                .sorted { $0.from.first < $1.from.first }
        }
        
        init(ranges: [RangeMap]) {
            self.ranges = ranges
        }
    }
    
    struct Input {
        let seedRanges: [Range]
        let maps: [Mapper]
        
        init?(string: String) {
            let seedMapStr = string.split(separator: "\n\n")
            var seedMax = 0
            seedRanges = {
                var result = [Range]()
                let seedNumbers = seedMapStr[0]
                    .split(separator: ": ")[1]
                    .split(separator: " ")
                    .compactMap { Int(String($0)) }
                print("seedNumbers:", seedNumbers)
                var i = 1
                while i < seedNumbers.count {
                    let r = Range(start: seedNumbers[i-1], length: seedNumbers[i])!
                    result.append(r)
                    seedMax = max(seedMax, r.last)
                    i += 2
                }
                return result
            }()
            maps = seedMapStr[1..<seedMapStr.count]
                .compactMap {
                    let map = Mapper(substring: $0)
                    map?.ranges.forEach { r in
                        seedMax = max(seedMax, max(r.to.last, r.from.last))
                    }
                    return map
                }
                .compactMap { map in
//                    guard let map = Mapper(substring: str) else { return nil }
                    print("seedMax", seedMax)
                    seedMax = Int.max-1
                    var last = 0, i = 0
                    var ranges: [RangeMap] = []
//                    map.ranges.forEach { r in
//                        seedMax = max(seedMax, max(r.to.last, r.from.last))
//                    }

                    
                    while i < map.ranges.count {

                        if last < map.ranges[i].from.first {
                            // crate range last..first-1
                            let len = map.ranges[i].from.first-last
                            let r = RangeMap(sourceStart: last, destStart: last, length: len)!
                            ranges.append(r)
//                            print(">>> create new range \(r.from.first),\(r.from.last)")
                        }
//                        print(">>> append range \(map.ranges[i].from.first),\(map.ranges[i].from.last)")
                        ranges.append(map.ranges[i])
                        last = map.ranges[i].from.last+1
                        i += 1
                    }
                    if last <= seedMax {
                        let len = seedMax-last + 1
                        let r = RangeMap(sourceStart: last, destStart: last, length: len)!
                        ranges.append(r)
                    }
                    return Mapper(ranges: ranges)
                }
        }
        
        func debugPrint() {
            print("seeds:", terminator: "")
            for seed in seedRanges {
                print(" (\(seed.first),\(seed.last))", terminator: "")
            }
            print("\n")
            for (i, map) in maps.enumerated() {
                print("mapper #\(i):")
                for rm in map.ranges {
                    print("(\(rm.from.first),\(rm.from.last)) => (\(rm.to.first),\(rm.to.last))")
                }
                print("")
            }
        }
    }
}

guard let input = Day5.Input(string: InputFiles.readInput("Day5")) else {
    fatalError("failed to parse input")
}

func find(map mapIndex: Int, first: Int, last: Int) {
    print(pad(mapIndex), "find", mapIndex, first, last)
    
    // last mapper (location)
    if mapIndex == input.maps.count {
        if part2 != nil {
            part2 = min(part2!, first)
        } else {
            part2 = first
        }
        return
    }
    
    for range in input.maps[mapIndex].ranges {
        // range contained in the input
        if first <= range.from.first, range.from.last <= last {
            print(pad(mapIndex), "map \(mapIndex) range \(range.from.first),\(range.from.last) contained in \(first),\(last) (inside)")
            print(pad(mapIndex), "(\(range.from.first),\(range.from.last)) => (\(range.to.first),\(range.to.last))")
            find(map: mapIndex+1, first: range.to.first, last: range.to.last)
        }
        // range.first contained in the input [rangeFirst..last]
        else if first <= range.from.first, range.from.first <= last {
            print(pad(mapIndex), "map \(mapIndex) range \(range.from.first),\(range.from.last) contained in \(first),\(last) (first)")
            if let destLast = range.map(value: last) {
                print(pad(mapIndex), "(\(range.from.first),\(last)) => (\(range.to.first),\(destLast))")
                find(map: mapIndex+1,
                     first: range.to.first,
                     last: destLast)
            }
        }
        // range.last contained in the input [input..rangeLast]
        else if first <= range.from.last, range.from.last <= last {
            print(pad(mapIndex), "map \(mapIndex) range \(range.from.first),\(range.from.last) contained in \(first),\(last) (last)")
            if let destFirst = range.map(value: first) {
                print(pad(mapIndex), "(\(first),\(range.from.last)) => (\(destFirst),\(range.to.last))")
                find(map: mapIndex+1,
                     first: destFirst,
                     last: range.to.last)
            }
        }
        // range contains input
        else if range.from.first <= first, last <= range.from.last {
            print(pad(mapIndex), "map \(mapIndex) range \(range.from.first),\(range.from.last) contained in \(first),\(last) (containing input)")
            if let destFirst = range.map(value: first),
               let destLast = range.map(value: last) {
                print(pad(mapIndex), "(\(first),\(last)) => (\(destFirst),\(destLast))")
                find(map: mapIndex+1,
                     first: destFirst,
                     last: destLast)
            }
        } else {
            let outside = range.from.last < first || range.from.first > last
            if !outside {
                print(pad(mapIndex), "range \(range.debugDescription) should be inside")
            }
        }
//        find(map: mapIndex+1, first: first, last: last)
    }
}

func pad(_ n: Int) -> String {
    return Array(repeating: " ", count: n)
        .joined()
}

var part2: Int? = nil
for seedRange in input.seedRanges {
    find(map: 0, first: seedRange.first, last: seedRange.last)
}
print("part2:", part2)
//input.debugPrint()
