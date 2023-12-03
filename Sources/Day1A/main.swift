//
//  main.swift
//
//
//  Created by Kennedy L on 03/12/23.
//

import Foundation
import InputFiles

let ans = readInput("Day1")
    .split(separator: "\n")
    .compactMap { sub -> Int? in
        guard let firstDigit = sub.first { $0.isNumber },
        let lastDigit = sub.reversed().first(where: { $0.isNumber }) else {
            return .none
        }
        return Int("\(firstDigit)\(lastDigit)")
    }
    .reduce(0) { partialResult, v in
        return partialResult + v
    }
print(ans)
    
