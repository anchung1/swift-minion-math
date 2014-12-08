//
//  GameScene.swift
//  balloon
//
//  Created by Anthony Chung on 12/4/14.
//  Copyright (c) 2014 Anthony Chung. All rights reserved.
//

import SpriteKit

enum PhysicsBitMask: UInt32 {
    case None = 0
    case Ship = 1
    case Wall = 2
    case All = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //var ship = SKSpriteNode()
    var spriteSheet = SpriteSheet()
    var correctAnswer: Int = 0
    
    
    //var rx: CGFloat = 0.0
    //var ry: CGFloat = 0.0
    var count = 0;
    var myShipList = [SKSpriteNode]()
    var gameModel = Game()
    
    
    var question = SKLabelNode()
    var scoreBoard = SKLabelNode()
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        //test()

        setUpGameBoard()
        
        setupCollisionWalls()
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        //TODO: put label inside space ship
        //      use list to animate
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        let node: SKNode = self.nodeAtPoint(touchLocation)
        
        if node.name == "ship" {
            var label = node.userData?["Value"] as CGFloat
            let answer = CGFloat(gameModel.getAnswer())
            if label == answer {
                correctAnswer += 1
                setUpGameBoard()
                println("hit")
            } else {
                println("miss: answer:\(answer)")
            }
          
            
        }
    }
    
    func setUpGameBoard() -> () {
        
        if correctAnswer == 0 {
            question = SKLabelNode(fontNamed: "Chalkduster")
            question.text = gameModel.getQuestion()
            question.fontSize = 35
            question.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            self.addChild(question)
        
            scoreBoard = SKLabelNode(fontNamed: "Chalkduster")
            scoreBoard.text = "Correct: \(correctAnswer)"
            scoreBoard.fontSize = 35
            scoreBoard.position = CGPoint(x: self.size.width * 0.10, y: self.size.height * 0.9)
            self.addChild(scoreBoard)
            
            let values = gameModel.getCandidates()
            
            for i in 0...values.count - 1 {
                println("\(values[i])")
                addShip(values[i])
            }

        } else {
            
            question.text = gameModel.getQuestion()
            let values = gameModel.getCandidates()
            
            var i = 0
            for ship in myShipList {
                
                let label = ship.userData?["Label"] as SKLabelNode
                
                label.text = "\(values[i])"
                ship.userData?.setValue(CGFloat(values[i]), forKey: "Value")
                i += 1
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
  
        scoreBoard.text = "Correct: \(correctAnswer)"
        
        for ship in myShipList {
            var rx = ship.userData?["RX"] as CGFloat
            var ry = ship.userData?["RY"] as CGFloat
            
            //println("\(rx), \(ry)")
            if ship.physicsBody?.resting == true {
                //println("rest mode")
                randomThrust(ship.physicsBody!)
            }
            
            ship.physicsBody?.applyImpulse(CGVector(dx: rx, dy: ry))
        }

    }
    
    func randomThrust(body: SKPhysicsBody) -> () {
        
        var speed: UInt32 = 32

        var rx = CGFloat(arc4random_uniform(speed)) - CGFloat(speed) / 2
        var ry = CGFloat(arc4random_uniform(speed)) - CGFloat(speed) / 2
        
        let node = body.node
        node?.userData?.setValue(rx, forKey: "RX")
        node?.userData?.setValue(ry, forKey: "RY")
        
     
        //body.velocity = CGVector(dx: rx, dy: ry)
        //body.applyForce(CGVector(dx: rx, dy: ry))
    
    }
    
    func addShip(label: UInt32) -> () {
        count++;
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "\(label)";
        myLabel.fontSize = 35;
        myLabel.position = CGPoint(x:0, y:0);
        
        spriteSheet = SpriteSheet(name: "spaceships")
        spriteSheet.splitSpriteSheet(2, row: 1)
        
        
        var ship = SKSpriteNode(texture: spriteSheet.getFrame(0))
        ship.position = CGPoint(x: self.size.width/2 , y: self.size.height/2)
        ship.name = "ship"
        
      
        //ship.physicsBody = SKPhysicsBody(circleOfRadius: ship.size.width/2)
        ship.physicsBody = SKPhysicsBody(rectangleOfSize: ship.size)
        ship.physicsBody?.dynamic = true
        ship.physicsBody?.affectedByGravity = true
      
        
        ship.physicsBody?.categoryBitMask = PhysicsBitMask.Ship.rawValue
        ship.physicsBody?.collisionBitMask = PhysicsBitMask.Wall.rawValue + PhysicsBitMask.Ship.rawValue
        ship.physicsBody?.contactTestBitMask = PhysicsBitMask.Wall.rawValue + PhysicsBitMask.Ship.rawValue
        
        ship.userData = NSMutableDictionary()
        randomThrust(ship.physicsBody!)
        ship.userData?.setValue(CGFloat(label), forKey: "Value")
        
        
        ship.addChild(myLabel)
        self.addChild(ship)
        
        ship.userData?.setValue(myLabel, forKey: "Label")
        myShipList.append(ship)
        

    }
    
    func setupCollisionWalls() -> () {
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = PhysicsBitMask.Wall.rawValue
        self.physicsBody?.collisionBitMask = PhysicsBitMask.Ship.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsBitMask.Ship.rawValue
        

    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var body1: SKPhysicsBody? = nil
        var body2: SKPhysicsBody? = nil

        if contact.bodyA.categoryBitMask == PhysicsBitMask.Ship.rawValue {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        
        if contact.bodyB.categoryBitMask == PhysicsBitMask.Ship.rawValue {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1?.categoryBitMask != PhysicsBitMask.Ship.rawValue {
            //println("ship not in collision")
            return
        }
        
        randomThrust(body1!)
        
    }
    
    func didEndContact(contact: SKPhysicsContact) {
    }
}