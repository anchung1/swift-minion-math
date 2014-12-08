//
//  game.swift
//  balloon
//
//  Created by Anthony Chung on 12/7/14.
//  Copyright (c) 2014 Anthony Chung. All rights reserved.
//

import Foundation

class Game {
    
    var currentAnswer: UInt32
    var candidates: UInt32
    var maxValue: UInt32
    
    init() {
        self.currentAnswer = 0
        self.candidates = 5
        self.maxValue = 10
    }
    
    func getRandom() -> (UInt32) {
        
        //this returns 0...maxValue-1.  Add one to make it base 1
        return arc4random_uniform(self.maxValue) + 1
    }
    
    func getQuestion() -> (String) {
        let first = getRandom()
        let second = getRandom()
        
        self.currentAnswer = first + second
        
        return("\(first) + \(second)")
        
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
                    num = getRandom() + getRandom()
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