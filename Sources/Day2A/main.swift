//
//  main.swift
//  
//
//  Created by Kennedy L on 03/12/23.
//

import Foundation
import InputFiles
import Day2

let allowedCount = CubeCount(red: 12, green: 13, blue: 14)
let ans = readInput("Day2")
    .split(separator: "\n")
    .filter { !$0.isEmpty }
    .map { GameInfo(substring: $0) }
    .filter { $0.isPossible(ifCount: allowedCount) }
    .reduce(0) { partialResult, game in
        return partialResult + game.id
    }
print(ans)
