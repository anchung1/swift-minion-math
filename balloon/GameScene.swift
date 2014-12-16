//
//  GameScene.swift
//  balloon
//
//  Created by Anthony Chung on 12/4/14.
//  Copyright (c) 2014 Anthony Chung. All rights reserved.
//

import SpriteKit
import AVFoundation

enum PhysicsBitMask: UInt32 {
    case None = 0
    case Ship = 1
    case Wall = 2
    case All = 16
}

enum spriteZPosition: CGFloat {
    case background = 1
    case label = 2
    case ship = 3
    case shipLabel = 4
    case questionLabel = 5
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //var ship = SKSpriteNode()
    var spriteSheet = SpriteSheet()
    var correctAnswer: Int = 0
    var inCorrectAnswer: Int = 0
    var hiScore: Int = 0
    
    var count = 0;
    var myShipList = [SKSpriteNode]()
    var gameModel = Game()
    var gameInit = false
    
    
    var question = SKLabelNode()
    var scoreBoard = SKLabelNode()
    var countDownClock = SKLabelNode()
    var hiScoreLabel = SKLabelNode()
    var descLabel = SKLabelNode()
    
    var startTime: CFTimeInterval = 0
    let gameTime: CFTimeInterval = 60
    
    var gameOver = true
    var gameOverTapCount = 5
    
    var candyCounter: Int = 0
    var candyClearCounter: Int = 0
    var candyCounterLabel = SKLabelNode()
    var candyCounterClearLabel = SKLabelNode()

    var audioPlayer = AVAudioPlayer()
    var soundFile = NSURL()
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        setupSound()
        setupCollisionWalls()
        doGameStart()
        
        
        physicsWorld.contactDelegate = self
        
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        let node: SKNode = self.nodeAtPoint(touchLocation)
        
        if gameOver == false {
            //case where user hits sprite
            if node.name == "ship" {
                var label = node.userData?["Value"] as CGFloat
                let answer = CGFloat(gameModel.getAnswer())
                if label == answer {
                    answerHit()

                } else {
                    inCorrectAnswer += 1
                }
            } else if node.name == "value" {
                //case where user touches the number on sprite
                var parentNode = node.parent
                if parentNode?.name == "ship" {
                    var label = parentNode!.userData?["Value"] as CGFloat
                    let answer = CGFloat(gameModel.getAnswer())
                    if label == answer {
                        answerHit()
                    } else {
                        inCorrectAnswer += 1
                    }
                }
            }
        }
        
        //touch 5 times to restart
        if gameOver == true {
            if node.name == "clear candies" {
                candyClearCounter += 1
                if candyClearCounter == 2 {
                    candyCounter = 0
                    showCandyWindow()
                }
            } else {
                gameOverTapCount -= 1
                if gameOverTapCount == 0 {
                    doGameStart()
                } else {
                    updateQuestionLabel()
                }
            }
        }
    }
    
    func setUpGameBoard() -> () {
        
        if gameInit == false {
            let background = SKSpriteNode(imageNamed: "desert-bkgnd.jpg")
            background.anchorPoint = CGPoint(x: 0, y: 0)
            background.position = CGPoint(x: 0, y: 0)
            background.zPosition = spriteZPosition.background.rawValue
            self.addChild(background)
            
            question = SKLabelNode(fontNamed: "Chalkduster")
            question.text = gameModel.getQuestion()
            question.fontSize = 35
            question.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            question.zPosition = spriteZPosition.questionLabel.rawValue
            self.addChild(question)
        
            scoreBoard = SKLabelNode(fontNamed: "Chalkduster")
            scoreBoard.text = "Correct: \(correctAnswer)"
            scoreBoard.fontSize = 35
            scoreBoard.position = CGPoint(x: self.size.width * 0.10, y: self.size.height * 0.90)
            scoreBoard.zPosition = spriteZPosition.label.rawValue
            self.addChild(scoreBoard)
            
            countDownClock = SKLabelNode(fontNamed: "Chalkduster")
            countDownClock.text = "Time: "
            countDownClock.fontSize = 35
            countDownClock.position = CGPoint(x: self.size.width * 0.11, y: self.size.height * 0.95)
            countDownClock.zPosition = spriteZPosition.label.rawValue
            self.addChild(countDownClock)
            
            hiScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
            hiScoreLabel.text = "High: \(hiScore)"
            hiScoreLabel.fontSize = 35
            hiScoreLabel.position = CGPoint(x: self.size.width * 0.10, y: self.size.height * 0.85)
            hiScoreLabel.zPosition = spriteZPosition.label.rawValue
            self.addChild(hiScoreLabel)
            
            descLabel = SKLabelNode(fontNamed: "Chalkduster")
            descLabel.text = "Rank: "
            descLabel.fontSize = 35
            descLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2 - 35)
            descLabel.zPosition = spriteZPosition.label.rawValue
            
            candyCounterLabel = SKLabelNode(fontNamed: "Chalkduster")
            candyCounterLabel.text = "Candies: \(candyCounter)"
            candyCounterLabel.fontSize = 35
            candyCounterLabel.position = CGPoint(x: self.size.width * 0.95, y: self.size.height * 0.95)
            candyCounterLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
            candyCounterLabel.zPosition = spriteZPosition.label.rawValue
            
            candyCounterClearLabel = SKLabelNode(fontNamed: "Chalkduster")
            candyCounterClearLabel.text = "Clear Candies"
            candyCounterClearLabel.fontSize = 35
            candyCounterClearLabel.position = CGPoint(x: self.size.width * 0.95, y: self.size.height * 0.90)
            candyCounterClearLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
            candyCounterClearLabel.name = "clear candies"
            candyCounterClearLabel.zPosition = spriteZPosition.label.rawValue
            
            let values = gameModel.getCandidates()
            
            for i in 0...values.count - 1 {
                println("\(values[i])")
                addShip(values[i])
            }
            
            gameInit = true

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
  
        if startTime == 0 {
            startTime = currentTime
        }
        
        let deltaTime = currentTime - startTime
        let timeLeft = gameTime - deltaTime
        let timeLeftInt: Int = Int(timeLeft)
        if timeLeftInt >= 0 {
            countDownClock.text = "Time: \(timeLeftInt)"
        } else {
            countDownClock.text = "Time: 0"
            doGameOver()
        }
        
        scoreBoard.text = "Correct: \(correctAnswer)"
        if gameOver == true {
            return
        }
        
        
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
        
        var speed: UInt32 = 10

        var rx = CGFloat(arc4random_uniform(speed)) - CGFloat(speed) / 2
        var ry = CGFloat(arc4random_uniform(speed)) - CGFloat(speed) / 2


        if abs(rx) < 3 {
            if rx < 0 {
                rx = -3
            } else {
                rx = 3
            }
        }
        if abs(ry) < 3 {
            if ry < 0 {
                ry = -3
            } else {
                ry = 3
            }
        }

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
        myLabel.name = "value"
        myLabel.zPosition = spriteZPosition.shipLabel.rawValue
        
        //spriteSheet = SpriteSheet(name: "spaceships")
        //spriteSheet.splitSpriteSheet(2, row: 1)
        //var ship = SKSpriteNode(texture: spriteSheet.getFrame(0))

        var ship = SKSpriteNode(imageNamed: "minion1-150")
        ship.position = CGPoint(x: self.size.width/2 , y: self.size.height/2)
        ship.name = "ship"
        ship.zPosition = spriteZPosition.ship.rawValue
        
      
        var diameter = ship.size.height
        if diameter < ship.size.width {
            diameter = ship.size.width
        }
        ship.physicsBody = SKPhysicsBody(circleOfRadius: diameter/2)
        //ship.physicsBody = SKPhysicsBody(rectangleOfSize: ship.size)
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
    
    func updateQuestionLabel() -> () {
        question.text = "Game Over \(gameOverTapCount)"
    }
    func showCandyWindow() -> () {
        candyCounterLabel.text = "Candies: \(candyCounter)"
        if candyCounterLabel.parent == nil {
            self.addChild(candyCounterLabel)
        }
        if candyCounterClearLabel.parent == nil {
            self.addChild(candyCounterClearLabel)
        }
        
    }
    
    func hideCandyWindow() -> () {
        candyClearCounter = 0
        candyCounterLabel.removeFromParent()
        candyCounterClearLabel.removeFromParent()
    }
    
    func doGameOver() -> () {
        if gameOver == true{
            return
        }
        
        gameOver = true
        updateQuestionLabel()
        
        //special case, look for cheating
        
        var wizard = false
        if correctAnswer < 3 {
            descLabel.text = "Rank: NOOB"
        } else if correctAnswer < 6 {
            descLabel.text = "Rank: BRO"
        } else if correctAnswer < 9 {
            descLabel.text = "Rank: PRO"
            //} else if correctAnswer < 12 {
            //descLabel.text = "Rank: EXPERT"
            //} //else if correctAnswer < 15 {
            //descLabel.text = "Rank: MASTER"
            //} //else if correctAnswer < 18 {
            // descLabel.text = "Rank: SENSEI"
            //}
        } else {
            descLabel.text = "Rank: MATH WIZARD (get free candy)"
            wizard = true
            //candyCounter += 1
        }

        if wizard ==  true {
            if checkCheat()==false {
                if correctAnswer > hiScore {
                    hiScore = correctAnswer
                }
                candyCounter += 1
            } else {
                descLabel.text = "Rank: CHEATER"
            }
        }
        
        
        hiScoreLabel.text = "High: \(hiScore)"
        if descLabel.parent == nil {
            self.addChild(descLabel)
            //showCandyWindow()
        }
        
        showCandyWindow()
        //introduce gravity so that ships fall off from scoreboard
        physicsWorld.gravity = CGVector(dx: 0, dy: -2)
    }
    
    func doGameStart() -> () {
        gameOverTapCount = 5
        gameOver = false
        correctAnswer = 0
        inCorrectAnswer = 0
        startTime = 0
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        descLabel.removeFromParent()
        hideCandyWindow()
        
        setUpGameBoard()
    }
    
    func setupCollisionWalls() -> () {
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = PhysicsBitMask.Wall.rawValue
        self.physicsBody?.collisionBitMask = PhysicsBitMask.Ship.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsBitMask.Ship.rawValue
        

    }
    
    func setupSound() -> () {
        soundFile = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("tada", ofType: "wav")!)!
        
        audioPlayer = AVAudioPlayer(contentsOfURL: soundFile, error: nil)
        audioPlayer.numberOfLoops = 0
        audioPlayer.prepareToPlay()
       

    }
    
    func answerHit() -> () {
        if audioPlayer.playing {
            audioPlayer.currentTime = 0
        } else {
            audioPlayer.prepareToPlay()
            audioPlayer.play()

        }

        correctAnswer += 1
        setUpGameBoard()
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
    
    func checkCheat() -> (Bool) {
        
        var totalCount = CGFloat(correctAnswer + inCorrectAnswer)
        if totalCount == 0 {
            return false
        }
        
        //random picks should yield 1/myShipList.count result
        //var expectedValue = 1 / CGFloat(myShipList.count)
        //add 10% leeway
        //expectedValue += 0.10
        var expectedValue: CGFloat = 0.40
        
        var percentageCorrect = CGFloat(correctAnswer) / totalCount
        println("\(percentageCorrect), \(expectedValue)")
        if percentageCorrect <= expectedValue {
            return true
        }

        return false
    }
    
    func didEndContact(contact: SKPhysicsContact) {
    }
    
}