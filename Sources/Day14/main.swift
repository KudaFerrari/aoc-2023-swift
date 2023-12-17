//
//  File.swift
//  
//
//  Created by Kennedy.Lajustra on 17/12/23.
//

import Foundation
import InputFiles

struct Input {
    var map: [[Character]]
    let H: Int
    let W: Int
    
    init(string: String) {
        let map = string.split(separator: "\n")
            .map { Array($0) }
        self.map = map
        W = map[0].count
        H = map.count
    }
    
    mutating func rotateRight() {
        // abc  da
        // def  eb
        //      fc
        let newH = W, newW = H
        var temp: [[Character]] = Array(repeating: Array.init(repeating: ".", count: newW), count: newH)
        for r in 0 ..< H {
            let nc = newW - r - 1
            for c in 0 ..< W {
                let nr = c
                temp[nr][nc] = map[r][c]
            }
        }
        
        map = temp
    }
    
    mutating func shiftRocksUp() {
        var c = 0
        while c < W {
            var p = 0
            
            while p+1 < H {
                if map[p][c] != "." {
                    p += 1
                    continue
                }
                
                var q = p+1
                while q < H, map[q][c] != "#" {
                    if map[q][c] == "O" {
                        // swap
                        let temp = map[p][c]
                        map[p][c] = map[q][c]
                        map[q][c] = temp
                        break
                    }
                    q += 1
                }
                p += 1
            }
            c += 1
        }
    }
    
    mutating func shiftCycle() {
        for _ in 0 ..< 4 {
            shiftRocksUp()
            rotateRight()
        }
    }
    
    func countWeight() -> Int {
        var r = 0
        var count = 0
        while r < H {
            let d = H - r
            for c in map[r] {
                if c == "O" {
                    count += d
                }
            }
            r += 1
        }
        return count
    }
    
    func printMap(_ n: Int) {
        print("\n>>>", n)
        for row in map {
            print(String(row))
        }
    }
}

func solve1() {
    var input = Input(string: InputFiles.readInput("Day14"))
    input.shiftRocksUp()
    print("part 1:", input.countWeight())
    
//    input.tiltedMap.forEach { print(String($0)) }
}

func solve2() {
    let input = Input(string: InputFiles.readInput("Day14"))
    let (state, start, L) = findCycle(start: input, f: { input in
        input.shiftCycle()
        return input.countWeight()
    })
    var curr = state
    let mod = (1_000_000_000 - start) % L
    print("(1000000000 - start) % len =", (1000_000_000 - start) % L)
    for i in 0 ..< L {
        let weight = curr.countWeight()
        print("\(start) + \(i):", weight, i == mod ? "<= part 2 answer" : "")
        curr.shiftCycle()
    }
    
    // tortoise and hare -> (meet state, start, len)
    func findCycle(start: Input, f: (inout Input) -> Int) -> (Input, Int, Int) {
        var a = start, b = start
        var va = f(&a)
        var vb = f(&b)
        vb = f(&b)
        
        while va != vb {
            va = f(&a)
            vb = f(&b)
            vb = f(&b)
        }
        
        // find meet point
        var mu = 0
        a = start
        a.shiftRocksUp()
        va = a.countWeight()
        while va != vb {
            va = f(&a)
            vb = f(&b)
            mu += 1
        }
        
        // find len
        var len = 1
        b = a
        vb = f(&b)
        while va != vb {
            vb = f(&b)
            len += 1
        }
        
        return (b, mu, len)
    }
}

solve1()
solve2()
