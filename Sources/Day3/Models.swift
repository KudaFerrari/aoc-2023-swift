//
//  Models.swift
//  
//
//  Created by Kennedy L on 03/12/23.
//

import Foundation

public struct Point {
    public let x: Int
    public let y: Int
    
    public func isInside(rect: Rect) -> Bool {
        return rect.pMin.x <= x && x <= rect.pMax.x
            && rect.pMin.y <= y && y <= rect.pMax.y
    }
}

public struct Rect {
    public let pMin: Point
    public let pMax: Point
}

public struct PartNumber {
    public let pos: Point
    public let length: Int
    public let number: Int
    
    public func adjacentRect() -> Rect {
        let pMin = Point(x: pos.x-1, y: pos.y-1)
        let pMax = Point(x: pos.x + length, y: pos.y+1)
        return Rect(pMin: pMin, pMax: pMax)
    }
}

public struct Schematics {
    public let width: Int
    public let height: Int
    public var numbers: [PartNumber]
    public let map: [[Character]]
    
    func doesRectContainsSymbol(_ rect: Rect) -> Bool {
        for y in rect.pMin.y...rect.pMax.y {
            for x in rect.pMin.x...rect.pMax.x {
                if 0 <= x && x < width,
                   0 <= y && y < height {
                    let char = map[y][x]
                    if char != "." && !char.isNumber { return true }
                }
            }
        }
        return false
    }
    
    public func sumPartNumbers() -> Int {
        return numbers.reduce(0) { partialResult, number in
            let rect = number.adjacentRect()
            if doesRectContainsSymbol(rect) {
                return partialResult + number.number
            }
            return partialResult
        }
    }
    
    public func sumGearRatio() -> Int {
        var sum = 0
        var y = 0
        while y < height {
            var x = 0
            
            while x < width {
                if map[y][x] != "*" {
                    x += 1
                    continue
                }
                printAround(x, y)
                let ratio = gearRatio(x, y)
                sum += ratio
                print("gear ratio: \(ratio)")
                x += 1
            }
            y += 1
        }
        
        func printAround(_ x: Int, _ y: Int) {
            print("")
            for r in y-1...y+1 {
                for c in x-1...x+1 {
                    if r >= 0, c >= 0 {
                        print(map[r][c], terminator: "")
                    }
                }
                print("")
            }
        }
        
        func gearRatio(_ x: Int, _ y: Int) -> Int {
            var r = y-1
            var numbers = [PartNumber]()
            print("gear x: \(x), y: \(y)")
            
            while r <= y+1, r < height {
                var c = x-1
                while c <= x+1, c < width {
                    guard r >= 0, c >= 0, let number = Schematics.getNumber(r, c, map, width)
                    else {
                        c += 1
                        continue
                    }
                    numbers.append(number)
                    c = number.pos.x + number.length
                }
                if numbers.count > 2 {
                    print("numbers.count > 2:", numbers.count)
                    for n in numbers {
                        print(n)
                    }
                    return 0
                }
                r += 1
            }
            
            if numbers.count == 2 {
                return numbers[0].number * numbers[1].number
            }
            print("numbers.count != 2:", numbers.count)
            return 0
        }
        return sum
    }
    
    public init(string: String) {
        let map = string.split(separator: "\n")
            .filter { !$0.isEmpty }
            .map { Array($0) }
        let width = map.first!.count
        let height = map.count
        
        self.width = map.first!.count
        self.height = map.count
        self.map = map
        self.numbers = {
            var result = [PartNumber]()
            for r in 0 ..< height {
                var c = 0
                while c < width {
                    if let number = Schematics.getNumber(r, c, map, width) {
                        result.append(number)
                        c += number.length
                        continue
                    }
                    c += 1
                }
            }
            return result
        }()
        
    }
    
    static func getNumber(_ r: Int, _ c: Int, _ map: [[Character]], _ width: Int) -> PartNumber? {
        guard map[r][c].isNumber else { return nil }
        var c = c
        while c-1 >= 0, map[r][c-1].isNumber {
            c -= 1
        }
        let p = Point(x: c, y: r)
        var x = c+1
        var len = 1
        var numStr = [map[r][c]]
        while x < width, map[r][x].isNumber {
            numStr.append(map[r][x])
            x += 1
            len += 1
        }
        return PartNumber(pos: p, length: len, number: Int(String(numStr))!)
    }
}


