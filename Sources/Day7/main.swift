//
//  File.swift
//  
//
//  Created by Kennedy.Lajustra on 15/12/23.
//

import Foundation
import InputFiles

enum Day7 {
    enum Card: Int, Comparable {
        case joker, two, three, four, five, six, seven, eight, nine, ten
        case jack, queen, king, ace
        
        init?(character: Character, isPart2: Bool) {
            switch character {
            case "2": self = .two
            case "3": self = .three
            case "4": self = .four
            case "5": self = .five
            case "6": self = .six
            case "7": self = .seven
            case "8": self = .eight
            case "9": self = .nine
            case "T": self = .ten
            case "J": self = isPart2 ? .joker : .jack
            case "Q": self = .queen
            case "K": self = .king
            case "A": self = .ace
            default: return nil
            }
        }
        
        static func < (lhs: Day7.Card, rhs: Day7.Card) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    struct Hand {
        enum `Type`: Int, Comparable {
            case highHand
            case onePair
            case twoPair
            case threeOfAKind
            case fullHouse
            case fourOfAKind
            case fiveOfAKind
            
            init(cards: [Card]) {
                var counts: [Card: Int] = [:]
                for card in cards {
                    if counts[card] != nil {
                        counts[card]! += 1
                    } else {
                        counts[card] = 1
                    }
                }
                self = `Type`(pattern: counts.values.sorted(by: >))
            }
            
            init(pattern: [Int]) {
                let pattern = pattern.sorted(by: >)
                switch pattern {
                case [5]: self = .fiveOfAKind
                case [4,1]: self = .fourOfAKind
                case [3,2]: self = .fullHouse
                case [3,1,1]: self = .threeOfAKind
                case [2,2,1]: self = .twoPair
                case [2,1,1,1]: self = .onePair
                default: self = .highHand
                }
            }
            
            init(part2Cards cards: [Card]) {
                let jokerCount = cards.filter { $0 == .joker }.count
                var counts: [Card: Int] = [:]
                for card in cards.filter({ $0 != .joker }) {
                    if counts[card] != nil { counts[card]! += 1 }
                    else { counts[card] = 1 }
                }
                var pattern = counts.values.sorted(by: >)
                guard pattern.count > 0 else {
                    // all jokers
                    self = .fiveOfAKind
                    return
                }
                pattern[0] += jokerCount
                self = `Type`(pattern: pattern)
            }
            
            static func < (lhs: Day7.Hand.`Type`, rhs: Day7.Hand.`Type`) -> Bool {
                return lhs.rawValue < rhs.rawValue
            }
        }
        
        let cards: [Card]
        let wage: Int
        let type: `Type`
        
        init(substring: Substring, isPart2: Bool) {
            let split = substring.split(separator: " ")
            let cards: [Card] = split[0].map { Card(character: $0, isPart2: isPart2)! }
            self.cards = cards
            wage = Int(split[1])!
            type = isPart2 ? `Type`(part2Cards: cards) : `Type`(cards: cards)
        }
        
        static func compare(lhs: Hand, rhs: Hand) -> Bool {
            if lhs.type == rhs.type {
                for (a,b) in zip(lhs.cards, rhs.cards) {
                    if a == b { continue }
                    return a > b
                }
                return true
            }
            return lhs.type > rhs.type
        }
    }
    
    struct Input {
        let hands: [Hand]
        
        init(string: String, isPart2: Bool = false) {
            hands = string.split(separator: "\n")
                .map { Hand(substring: $0, isPart2: isPart2) }
                .sorted(by: Hand.compare(lhs:rhs:))
                .reversed()
        }
    }
}

let input = Day7.Input(string: InputFiles.readInput("Day7"))
let input2 = Day7.Input(string: InputFiles.readInput("Day7"), isPart2: true)

func sumOfWins(input: Day7.Input) -> Int {
    var i = 0
    var ans = 0
    while i < input.hands.count {
        let rank = i+1
        ans += rank * input.hands[i].wage
//        let win = rank * input.hands[i].wage
//        print(i, input.hands[i].wage, win, input.hands[i].type, input.hands[i].cards)
        i += 1
    }
    return ans
}

print("part1:", sumOfWins(input: input))
print("part2:", sumOfWins(input: input2))
