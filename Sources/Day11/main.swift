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
    let map: [[Character]]
    
    init(string: String) {
        var expandedMap = string.split(separator: "\n").map { Array($0) }
        var r = 0
        while r < expandedMap.count {
            if expandedMap[r].contains("#") {
                r += 1
                continue
            }
            expandedMap.insert(Array(repeating: ".", count: expandedMap[r].count),
                               at: r)
            r += 2
        }
        var c = 0
        while c < expandedMap[0].count {
            var isEmpty = true
            for r in 0 ..< expandedMap.count {
                if expandedMap[r][c] == "#" {
                    isEmpty = false
                    break
                }
            }
            
            if !isEmpty {
                c += 1
                continue
            }
            
            for r in 0 ..< expandedMap.count {
                expandedMap[r].insert(".", at: c)
            }
            c += 2
        }
        
        map = expandedMap
    }
    
    func shortestDistSum() -> Int {
        var galaxies = [Point]()
        for row in 0 ..< map.count {
            for col in 0 ..< map[row].count {
                if map[row][col] == "#" {
                    galaxies.append(Point(c: col, r: row))
                }
            }
        }
        
        var sum = 0
        var i = 0
        while i < galaxies.count-1 {
            var j = i+1
            while j < galaxies.count {
                sum += galaxies[i].manhattanDistance(galaxies[j])
                j += 1
            }
            i += 1
        }
        return sum
    }
}

let input = Input(string: InputFiles.readInput("Day11") )
print("distance sum:", input.shortestDistSum())

