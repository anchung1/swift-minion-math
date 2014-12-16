//
//  game.swift
//  balloon
//
//  Created by Anthony Chung on 12/7/14.
//  Copyright (c) 2014 Anthony Chung. All rights reserved.
//

import Foundation

class Game {

    enum gameMode: UInt32 {
        case add = 0
        case sub = 1
    }
    
    var currentAnswer: UInt32
    var candidates: UInt32
    var maxAddValue: UInt32
    var maxSubValue: UInt32
    var maxIndValue: UInt32
    
    init() {
        self.currentAnswer = 0
        self.candidates = 5
        self.maxAddValue = 10
        self.maxSubValue = 20
        self.maxIndValue = maxSubValue
    }
    
    func getRandom(maxValue: UInt32) -> (UInt32) {
        
        //this returns 0...maxAddValue-1.  Add one to make it base 1
        return arc4random_uniform(maxValue) + 1
    }
    
    func doAddition() -> String {
        let first = getRandom(maxAddValue)
        let second = getRandom(maxAddValue)
        
        self.currentAnswer = first + second
        
        return("\(first) + \(second)")

    }
    
    func doSubtraction() -> String {
        let first = getRandom(maxSubValue)
        let second = getRandom(maxSubValue)

        var output: String
        if first >= second {
            
            self.currentAnswer = first - second
            output = "\(first) - \(second)"
            
        } else {
            
            self.currentAnswer = second - first
            output = "\(second) - \(first)"

        }
        
        return output
        
    }
    
    func getQuestion() -> (String) {
        
        var mode = arc4random_uniform(2)
        if mode == gameMode.add.rawValue {
            return doAddition()
        }
        
        return doSubtraction()
    }
    
    func getAnswer() -> (UInt32) {
        return self.currentAnswer
    }
    
    func getCandidates() -> [UInt32] {
        var numList = [UInt32]()
        
        let answerSlot = arc4random_uniform(self.candidates) + 1
        for i in 1...self.candidates  {
            if i == answerSlot {
                numList.append(getAnswer())
            } else {
                
                var num: UInt32 = 0
                var unique = false
                while !unique {
                    num = getRandom(maxIndValue)
                    if num == getAnswer() {
                        unique = false
                        continue
                    }
                    unique = true
                    for val in numList {
                        if val == num {
                            unique = false
                            break
                        }
                    }
                    
                }
                numList.append(num)
            }
        }
        
        return numList
    }
    
}