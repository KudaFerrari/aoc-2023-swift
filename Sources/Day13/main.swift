//
//  File.swift
//  
//
//  Created by Kennedy.Lajustra on 17/12/23.
//

import Foundation
import InputFiles

struct Input {
    struct Pattern {
        let map: [[Character]]
        let H: Int
        let W: Int
        
        init(map: [[Character]]) {
            self.map = map
            H = map.count
            W = map[0].count
        }
    }
    let patterns: [Pattern]
    
    init(_ string: String) {
        patterns = string
            .split(separator: "\n\n")
            .map { $0.split(separator: "\n").map { Array($0) } }
            .map { Pattern(map: $0) }
    }
}

func countCols(_ pattern: Input.Pattern) -> (Int,Int?) {
    var c = 1
    var minC: Int? = nil
    var otherCol: Int? = nil
    while c < pattern.W {
        var a = c-1, b = c
        
        var totalDiffCount = 0
        while b < pattern.W, a >= 0 {
            let diffCount = colDiffCount(a, b)
            totalDiffCount += diffCount
            a -= 1
            b += 1
        }
        if otherCol == nil, totalDiffCount == 1 {
            otherCol = c
        }
        
        else if minC == nil, totalDiffCount == 0 {
            minC = c
        }
        
        c += 1
    }
    
    return (minC ?? 0, otherCol)
    
    func colDiffCount(_ a: Int, _ b: Int) -> Int {
        if a < 0 || b >= pattern.W { return 0 }
        var row = 0
        var count = 0
        while row < pattern.H {
            if pattern.map[row][a] != pattern.map[row][b] { count += 1 }
            row += 1
        }
        return count
    }
}

func countRows(_ pattern: Input.Pattern) -> (Int, Int?) {
    var r = 1
    var otherRow: Int? = nil
    var minR: Int? = nil
    while r < pattern.H {
        var a = r-1, b = r
        
        var totalDiffCount = 0
        while b < pattern.H, a >= 0 {
            let diffCount = rowDiffers(a, b)
            totalDiffCount += diffCount
            a -= 1
            b += 1
        }
        
        if totalDiffCount == 1 {
            otherRow = r
        }
        else if minR == nil, totalDiffCount == 0 {
            minR = r
        }
        
        r += 1
    }
 
    return (minR ?? 0, otherRow)
    
    func rowDiffers(_ a: Int, _ b: Int) -> Int {
        if a < 0 || b >= pattern.H { return 0 } // out of bounds
        var count = 0
        var c = 0
        while c < pattern.W {
            if pattern.map[a][c] != pattern.map[b][c] { count += 1 }
            c += 1
        }
        return count
    }
}

func solve1() {
    let input = Input(InputFiles.readInput("Day13"))
    var part1 = 0, part2 = 0
    for p in input.patterns {
        let (col1, col2) = countCols(p)
        let (row1, row2) = countRows(p)
        part1 += col1 + 100 * row1
        part2 += col2 != nil ? col2! : 100 * row2!
    }
    print("part 1:", part1)
    print("part 2:", part2)
}

solve1()
