//
//  File.swift
//  
//
//  Created by Kennedy.Lajustra on 15/12/23.
//

import Foundation
import InputFiles

class Node {
    let name: String
    var left: Node!
    var right: Node!
    let isStart: Bool
    let endsWithZ: Bool
    
    init(name: String) {
        self.name = name
        isStart = name.last == "A"
        endsWithZ = name.last == "Z"
    }
}

struct Input {
    let instructions: String
    let start: Node
    let end: Node
    let map: [String: Node]
    
    init(string: String) {
        let split = string.split(separator: "\n\n")
        instructions = String(split[0])
        var nodes: [String: Node] = [:]
        split[1]
            .split(separator: "\n")
            .forEach { line in
                let ssplit = line.split(separator: " = ")
                let name = String(ssplit[0])
                let childNames = ssplit[1][ssplit[1].startIndex.advanced(by: 1) ..< ssplit[1].endIndex.advanced(by: -1)]
                    .split(separator: ", ")
                let leftName = String(childNames[0])
                let rightName = String(childNames[1])
                
                let node = getOrCreateNode(name: name)
                let left = getOrCreateNode(name: leftName)
                let right = getOrCreateNode(name: rightName)
                node.left = left
                node.right = right
            }
        start = nodes["AAA"]!
        end = nodes["ZZZ"]!
        map = nodes
        
        func getOrCreateNode(name: String) -> Node {
            if let node = nodes[name] {
                return node
            }
            let node = Node(name: name)
            nodes[name] = node
            return node
        }
    }
}

let input = Input(string: InputFiles.readInput("Day8"))
var visited = Set<String>()

func walk(_ node: Node) {
    visited.insert(node.name)
    if let left = node.left, !visited.contains(left.name) {
        walk(left)
    }
    print(node.name)
    if let right = node.right, !visited.contains(right.name){
        walk(right)
    }
}

//walk(input.start)
func solve1() {
    let end = input.map.values.first { $0.name == "ZZZ" }!
    let count = count(start: input.start, end: { $0 === end })
    print("part 1:", count)
}

func count(start: Node, end: (Node)->Bool) -> Int {
    var curr = start
    var count = 0
    let chars = Array(input.instructions)
    var i = 0
    
    var loopCount = 0
    var last = 0
    while true {
        //    print("curr:", curr.name)
        let c = chars[i]
        if c == "L" {
            //        print("left")
            curr = curr.left
        } else {
            //        print("right")
            curr = curr.right
        }
        count += 1
        if end(curr) {
            
            loopCount += 1
            print("loop \(loopCount): \(count)  diff: \(count-last)")
            last = count
            if loopCount > 3 { return 0 }
            
//            return count
        }
        i = (i + 1) % chars.count
    }
}
func gcd(_ a: Int, _ b: Int) -> Int {
    var b = b
    var a = a
    var t = b
    while b != 0 {
        t = b
        b = a % b
        a = t
    }
    return a
}
func lcm(_ a: Int, _ b: Int) -> Int {
    return a * b / gcd(a,b)
}

func solve2() {
    var starts = input.map.values.filter { $0.isStart }
    let ends = input.map.values.filter({ $0.endsWithZ })
    print("start count:", starts.count)
    print("end count", ends.count)
    var LCM = 1
    for s in starts {
        let c = count(start: s, end: { e in ends.contains { e === $0 } })
        print(c)
        LCM = lcm(LCM, c)
        print("lcm:", LCM)
    }
}

//solve1()
//solve2()
let ends = input.map.values.filter { $0.endsWithZ }
count(start: input.start, end: { e in ends.contains{ e === $0 } })

