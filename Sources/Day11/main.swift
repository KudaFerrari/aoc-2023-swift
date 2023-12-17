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
    var emptyRowSum: [Int]
    var emptyColSum: [Int]
    
    init(string: String) {
        var expandedMap = string.split(separator: "\n").map { Array($0) }
        var emptyRows = 0
        var emptyRowSum = [Int]()
        for r in 0 ..< expandedMap.count {
            if expandedMap[r].contains("#") {
                emptyRowSum.append(emptyRows)
                continue
            }
            emptyRows += 1
            emptyRowSum.append(emptyRows)
        }
        var emptyCols = 0
        var emptyColSum = [Int]()
        for c in 0 ..< expandedMap[0].count {
            var isEmpty = true
            for r in 0 ..< expandedMap.count {
                if expandedMap[r][c] == "#" {
                    isEmpty = false
                    break
                }
            }
            
            if !isEmpty {
                emptyColSum.append(emptyCols)
                continue
            }
            
            emptyCols += 1
            emptyColSum.append(emptyCols)
        }
        
        map = expandedMap
        self.emptyRowSum = emptyRowSum
        self.emptyColSum = emptyColSum
    }
    
    func emptyColsBetween(_ i: Int, _ j: Int) -> Int {
        if i > j { return emptyColSum[i] - emptyColSum[j] }
        return emptyColSum[j] - emptyColSum[i]
    }
    
    func emptyRowsBetween(_ i: Int, _ j: Int) -> Int {
        if i > j { return emptyRowSum[i] - emptyRowSum[j] }
        return emptyRowSum[j] - emptyRowSum[i]
    }
    
    func shortestDistSum(emptyDistance: Int) -> Int {
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
                let cols = emptyColsBetween(galaxies[i].c, galaxies[j].c)
                let rows = emptyRowsBetween(galaxies[i].r, galaxies[j].r)
                let dist = galaxies[i].manhattanDistance(galaxies[j])
                let expandedRows = rows * emptyDistance - rows
                let expandedCols = cols * emptyDistance - cols
                sum += dist + expandedRows + expandedCols
                j += 1
            }
            i += 1
        }
        return sum
    }
}

//let input = Input(string: InputFiles.readInput("Day11Sample"))
let input = Input(string: InputFiles.readInput("Day11"))
print("distance sum 2:", input.shortestDistSum(emptyDistance: 2))
print("distance sum 10:", input.shortestDistSum(emptyDistance: 10))
print("distance sum 100:", input.shortestDistSum(emptyDistance: 100))
print("distance sum 1000000:", input.shortestDistSum(emptyDistance: 1000000))

