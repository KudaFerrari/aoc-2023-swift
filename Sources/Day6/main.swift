//
//  main.swift
//
//
//  Created by Kennedy.Lajustra on 14/12/23.
//

import Foundation
import InputFiles

let inputStr = """
Time:        53     89     76     98
Distance:   313   1090   1214   1201
"""

enum Day6 {
    struct Race {
        let time: Int
        let distance: Int
    }
    
    struct Input: CustomDebugStringConvertible {
        let races: [Race]
        
        init(_ string: String) {
            let lines = string.split(separator: "\n")
            let times = lines[0].split(separator: ":")[1]
                .split(separator: " ")
                .compactMap { Int($0) }
            let distances = lines[1].split(separator: ":")[1]
                .split(separator: " ")
                .compactMap { Int($0) }
            races = zip(times, distances).map { Race(time: $0, distance: $1) }
        }
        
        var debugDescription: String {
            return """
            time: \(time)
            distance: \(distance)
            """
        }
    }
    struct InputPart2 {
        let race: Race
        
        init?(string: String) {
            let lines = string.split(separator: "\n")
            let timeStr = lines[0].split(separator: ":")[1]
                .replacing(" ", with: "")
            guard let time = Int(timeStr) else { return nil }
            let distStr = lines[1].split(separator: ":")[1]
                .replacing(" ", with: "")
            guard let distance = Int(distStr) else { return nil }
            race = Race(time: time, distance: distance)
        }
    }
}

func distance(heldTime: Int, maxTime: Int) -> Int {
    let remainingTime = maxTime-heldTime
    if remainingTime <= 0 { return 0 }
    let speed = heldTime
    return speed * remainingTime
}

func countWays(race: Day6.Race) -> Int {
    var count = 0
    for t in 1 ..< race.time {
        if distance(heldTime: t, maxTime: race.time) > race.distance {
//            print("hold for \(t) wins")
            count += 1
        }
    }
    return count
}

let input = Day6.Input(inputStr)
let ans = input.races.reduce(1, { result, race in
    return result * countWays(race: race)
})
print("part1", ans)

guard let input2 = Day6.InputPart2(string: inputStr) else {
    fatalError("failed to parse input part 2")
}
print("part2", countWays(race: input2.race))

