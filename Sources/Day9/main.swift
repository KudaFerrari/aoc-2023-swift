//
//  File.swift
//  
//
//  Created by Kennedy.Lajustra on 16/12/23.
//

import Foundation
import InputFiles

struct Input {
    let histories: [[Int]]
    
    init(string: String) {
        histories = string.split(separator: "\n")
            .map { $0.split(separator: " ").compactMap{ Int($0) } }
    }
}

fileprivate extension Array {
    subscript(safe i: Int) -> Element? {
        if i < self.count {
            return self[i]
        }
        return nil
    }
}

/// - returns: (extrapolated backward, extrapolated forward)
func extrapolate(history: [Int]) -> (Int, Int) {
    guard history.count > 1 else { fatalError("expected |history| > 1") }
    var histories = [history]
    var row = 0
    var rows = 1
    while row < rows {
        var last = histories[row][0]
        var shouldCreateRow = last != 0
        var i = 1
        let len = histories[row].count
        while i < len {
            let curr = histories[row][i]
            shouldCreateRow = shouldCreateRow || curr != 0
            let diff = curr-last
            if row+1 < histories.count {
                histories[row+1].append(diff)
            } else if shouldCreateRow {
                histories.append([diff])
                rows += 1
            }
            last = curr
            i += 1
        }
        row += 1
    }
    
    for row in 0 ..< rows {
        print(Array(repeating: "  ", count: row).joined(), terminator: "")
        for n in histories[row] {
            print(n, terminator: "   ")
        }
        print("")
    }
    
    return (extrapolateBackward(), extrapolateForward())
    
    func extrapolateBackward() -> Int {
        // a      b     ...
        //   last   ...
        //       ...
        var row = rows-2
        var last = 0
        while row >= 0 {
            let b = histories[row].first!
            // b - a = last  =>  a = b - last
            let a = b - last
            last = a
            row -= 1
        }
        return last
    }
    
    func extrapolateForward() -> Int {
        var row = rows-2
        var last = 0
        while row >= 0 {
            let curr = histories[row].last! + last
            last = curr
            row -= 1
        }
        return last
    }
}

let input = Input(string: InputFiles.readInput("Day9"))
var sumForward = 0
var sumBackward = 0
for history in input.histories {
    let result = extrapolate(history: history)
    sumBackward += result.0
    sumForward += result.1
}
print("forward:", sumForward)
print("backward:", sumBackward)
