//
//  File.swift
//  
//
//  Created by Kennedy.Lajustra on 17/12/23.
//

import Foundation
import InputFiles
import Common

struct Input {
    class Case {
        let conditions: [Character]
        let groups: [Int]
        var used: [Int: Int]
        var orderedGroup: [Int]
        var memo: [Point: Int] = [:] // condition, group
        
        init(_ substring: Substring) {
            let split = substring.split(separator: " ")
            conditions = Array(split[0])
            let groups = split[1].split(separator: ",")
                .map { Int($0)! }
            self.groups = groups
            var used = [Int:Int]()
            for n in groups {
                if used[n] != nil {
                    used[n]! += 1
                } else {
                    used[n] = 1
                }
            }
            self.used = used
            self.orderedGroup = groups
        }
        
        init(part2 substring: Substring) {
            let a = Case(substring)
            let count = 5
            conditions = Array(repeating: a.conditions, count: count).joined(separator: ["?"]).map { $0 }
            groups = Array(repeating: a.groups, count: count).flatMap { $0 }
            used = [:]
            orderedGroup = Array(repeating: a.groups, count: count).flatMap { $0 }
        }
        
        func countWaysOrdered(_ i: Int, _ j: Int, _ d: Int = 0) -> Int {
            if let m = memo[Point(c: j, r: i)] { return m }
//            print("count \(i),\(j)")
            if i >= conditions.count {
                padPrint(j >= orderedGroup.count ? "possible" : "not possible (some not used)")
                memo[Point(c: j, r: i)] = j >= orderedGroup.count ? 1 : 0
                return j >= orderedGroup.count ? 1 : 0
            }
            if j >= orderedGroup.count {
                var i = i
                while i < conditions.count {
                    if conditions[i] == "#" {
                        padPrint("not possible (group is consumed)")
                        memo[Point(c: j, r: i)] = 0
                        return 0
                    }
                    i += 1
                }
                padPrint("possible")
                memo[Point(c: j, r: i)] = 1
                return 1
            }
            
            // count if pos i is broken
            var count = 0
            if canAssumeBroken(orderedGroup[j], brokenAt: i) {
                padPrint("count if \(orderedGroup[j]) broken at \(i)")
                count += countWaysOrdered(i + orderedGroup[j] + 1, j+1)
            }
            
            // count if pos i is working
            if conditions[i] != "#" {
                padPrint("count if pos \(i) is working")
                count += countWaysOrdered(i+1, j)
            }
            
            memo[Point(c: j, r: i)] = count
            return count
                
            func canAssumeBroken(_ count: Int, brokenAt i: Int) -> Bool {
                guard i + count - 1 < conditions.count ||
                        ( i-1 >= 0 && conditions[i-1] == "#" )
                else { return false }
                // i??a??
                // ###.??S
                // n = 3:
                // i..(a-1) must be ? or #
                // a        must be . or ?
                var i = i
                let end = i+count
                while i < end, i < conditions.count {
                    if conditions[i] == "." { return false }
                    i += 1
                }
                
                if end < conditions.count {
                    return conditions[end] != "#"
                }
                return true
            }
            
            func padPrint(_ s: String) {
//                print(String(repeating: "  ", count: d), s, separator: "")
            }
        }
    }
    
    
    let cases: [Case]
    
    init(string: String) {
        cases = string.split(separator: "\n")
            .map { Case($0) }
    }
    
    init(part2 string: String) {
        cases = string.split(separator: "\n")
            .map { Case(part2: $0) }
    }
}


func solve1() {
    let input = Input(string: InputFiles.readInput("Day12"))
    var count = 0
    for c in input.cases {
        let ways = c.countWaysOrdered(0, 0)
//        print("ways:", ways)
        count += ways
    }
    print("part 1:", count)
}

func solve2() {
    var count = 0
    let input2 = Input(part2: InputFiles.readInput("Day12"))
    var i = 1
    for c in input2.cases {
//        print("case:", String(c.conditions), c.orderedGroup)
        let ways = c.countWaysOrdered(0, 0)
//        print("(\(i)/\(input2.cases.count)): \(ways)")
        count += ways
        i += 1
    }
    print("part 2:", count)
}

solve1()
solve2()

// 012345678901234
// ?#?#?#?#?#?#?#?
// ######.#.#.###?
