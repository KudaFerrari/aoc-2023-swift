//
//  main.swift
//  
//
//  Created by Kennedy L on 03/12/23.
//

import Foundation
import InputFiles
import Day2

let ans = readInput("Day2")
    .split(separator: "\n")
    .filter { !$0.isEmpty }
    .map { GameInfo(substring: $0)
            .maxOfEachColor()
            .power()
    }
    .reduce(0) { partialResult, power in
        return partialResult + power
    }
print(ans)
