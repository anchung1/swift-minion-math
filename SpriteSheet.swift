//
//  SpriteSheet.swift
//  balloon
//
//  Created by Anthony Chung on 12/6/14.
//  Copyright (c) 2014 Anthony Chung. All rights reserved.
//

import Foundation
import SpriteKit

class SpriteSheet {
    
    var sheetName: String
    var animationFrame: NSMutableArray

    init() {
        self.sheetName = String("")
        self.animationFrame = NSMutableArray()
        
    }
    
    init(name: String) {
        self.sheetName = name
        self.animationFrame = NSMutableArray()
    }
    
    func splitSpriteSheet(col: Int, row: Int) -> () {
        let myTexture = SKTexture(imageNamed: self.sheetName)
        myTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let x_fraction: CGFloat = 1 / CGFloat(col)
        let y_fraction: CGFloat = 1 / CGFloat(row)
        
        
        //assume we read left -> right, then top -> bottom
        for j in 0...row-1 {
            for i in 0...col-1 {
                let x_pos = CGFloat(i) * x_fraction
                let y_pos = CGFloat(j) * y_fraction
                let rect1 = CGRect(x: x_pos, y: y_pos, width: x_fraction, height: y_fraction)
                
                //textures values (x, y) in range 0->1
                //         values (width, height) in range 0->1
                //println("(\(x_pos),\(y_pos)), (\(x_fraction),\(y_fraction))")
                let frame = SKTexture(rect: rect1, inTexture: myTexture)
                
                animationFrame.addObject(frame)
            }
        }
    }
    
    func getFrame(index: Int) -> SKTexture? {
        
        println("count: \(animationFrame.count)")
        if animationFrame.count < index + 1 {
            println("returning nil")
            return nil
        }
        return animationFrame[index] as? SKTexture
    }
}
