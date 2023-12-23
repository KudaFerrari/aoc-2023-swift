//
//  File.swift
//  
//
//  Created by Kennedy.Lajustra on 23/12/23.
//

import Foundation
import InputFiles

let sampleInput = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"

struct Input {
    let strings: [String]
    init(string: String) {
        strings = string.split(separator: ",").map { String($0) }
    }
}
fileprivate extension Array {
    subscript (safe index: Int) -> Element? {
        guard index < self.count else { return nil }
        return self[index]
    }
}

fileprivate extension String {
    subscript (_ i: Int) -> Character? {
        let arr = Array(self)
        return arr[safe: i]
    }
}

func hash(str: String) -> Int {
    guard let cstr = str
        .cString(using: .ascii)?
        .filter({ $0 != 10 })
    else { fatalError("failed to convert to cstr") }
    var current = 0
    for j in 0 ..< cstr.count-1 {
        current += Int(cstr[j])
        current *= 17
        current = current % 256
    }
    return current
}

func hash(arr: [String]) -> Int {
    var sum = 0
    for string in arr {
        let lineHash = hash(str: string)
        sum += lineHash
    }
    return sum
}

//let result = hash(arr: ["HASH"])
//let input = Input(string: sampleInput)

func solvePart1() {
    let input = Input(string: InputFiles.readInput("Day15"))
    let result = hash(arr: input.strings)
    print("part1", result)
}

struct Lens {
    let label: String
    var focalLength: Int
}

struct Step {
    enum Operation {
        case delete
        case set
    }
    
    let lens: Lens?
    let label: String
    let operation: Operation
    let hashValue: Int
    
    init(_ str: Substring) {
        let label: String
        if str.contains("=") {
            let ss = str.split(separator: "=")
            label = String(ss[0])
            let focalLength = Int(ss[1])!
            lens = Lens(label: label, focalLength: focalLength)
            operation = .set
        } else {
            let ss = str.split(separator: "-")
            label = String(ss[0])
            lens = nil
            operation = .delete
        }
        self.label = label
        self.hashValue = hash(str: label)
    }
    
    var debugDescription: String {
        let prefix = operation == .delete ? "-" : "=\(lens!.focalLength)"
        return label + prefix
    }
}

struct Box {
    var lenses: [Lens] = []
    
    func lensIndex(label: String) -> Int? {
        return lenses.firstIndex(where: { $0.label == label })
    }
    
    mutating func set(lens: Lens) {
        if let index = lensIndex(label: lens.label) {
            lenses[index].focalLength = lens.focalLength
        } else {
            lenses.append(lens)
        }
    }
    
    mutating func delete(label: String) {
        if let index = lensIndex(label: label) {
            lenses.remove(at: index)
        }
    }
}

struct Facility: CustomDebugStringConvertible {
    var boxes: [Box] = Array(repeating: Box(), count: 256)
    
    mutating func doStep(_ step: Step) {
        switch step.operation {
        case .delete:
            boxes[step.hashValue].delete(label: step.label)
        case .set:
            boxes[step.hashValue].set(lens: step.lens!)
        }
    }
    
    var debugDescription: String {
        return boxes.enumerated()
            .filter { $0.1.lenses.isEmpty == false }
            .map { i, box in
                return "box \(i): " + box.lenses.map { "[\($0.label) \($0.focalLength)]" }.joined(separator: " ")
            }
            .joined(separator: "\n")
    }
    
    var totalFocusPower: Int {
        var ans = 0
        for i in 0 ..< boxes.count {
            if boxes[i].lenses.isEmpty { continue }
            for j in 0 ..< boxes[i].lenses.count {
                let focusPower = (i+1) * (j+1) * boxes[i].lenses[j].focalLength
                ans += focusPower
            }
        }
        return ans
    }
}

func solvePart2() {
    let steps = InputFiles.readInput("Day15")
        .split(separator: ",")
        .map { Step($0) }
    var facility = Facility()
    for step in steps {
        facility.doStep(step)
//        print("after:", step.debugDescription)
//        print(facility.debugDescription)
    }
    
    print("part 2:", facility.totalFocusPower)
}

//solvePart1()
solvePart2()


