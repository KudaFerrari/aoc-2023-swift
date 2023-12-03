//
//  main.swift
//  
//
//  Created by Kennedy L on 03/12/23.
//

import Foundation
import InputFiles

let digitMap: [String:Int] = {
    let digits = [
        "one", "two", "three",
        "four", "five", "six",
        "seven", "eight", "nine"
    ]
    var result = [String:Int]()
    for (i,s) in digits.enumerated() {
        result[s] = i+1        // "one" = 1
        result["\(i+1)"] = i+1 // "1" = 1
        result[String(s.reversed())] = i+1 // "eno" = 1
    }
    return result
}()

enum DigitPos {
    case first, last
}

func getDigit(_ sub: Substring, pos: DigitPos = .first) -> Int? {
    for i in 0 ..< sub.count {
        switch pos {
        case .first:
            let startIndex = sub.index(sub.startIndex, offsetBy: i)
            let subsub = sub[startIndex ..< sub.endIndex]
            if let digit = digitMap.first(where: { key, value in subsub.starts(with: key) })?.value {
                return digit
            }
        case .last:
            let rsub = sub.reversed()
            let startIndex = rsub.index(rsub.startIndex, offsetBy: i)
            let rsubsub = rsub[startIndex ..< rsub.endIndex]
            if let digit = digitMap.first(where: { key, value in rsubsub.starts(with: key) })?.value {
                return digit
            }
        }
    }
    return nil
}

//print(getDigit("one12two"))
//print(getDigit("one12nine", pos: .last))
//print(getDigit("one12nine9", pos: .last))
//print(getDigit("one12nine9ine", pos: .last))

let ans = readInput("Day1")
    .split(separator: "\n")
    .compactMap { sub -> Int? in
        if let first = getDigit(sub),
           let last = getDigit(sub, pos: .last) {
            return Int("\(first)\(last)")
        }
        return nil
    }
    .reduce(0) { partialResult, v in
        return partialResult + v
    }
print(ans)
