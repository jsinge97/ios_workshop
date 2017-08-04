//
//  GameScene.swift
//  SpacegameReloaded
//
//  Created by Training on 01/10/2016.
//  Copyright © 2016 Training. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //    creates variables for the starfield and the player so that they can be loaded in when game starts
    //    note: "var" is for variables that will be changed while "let" is for constants
    
    var starfield:SKEmitterNode!
    var player:SKSpriteNode!
    
    
    //    Cretes a variable for our score label
    var scoreLabel:SKLabelNode!
    
    //    sets the variable for the score
    var score:Int = 0 {
        //        this is written so that any time we update the score, we also update the score label
        //        makes things much, much easier
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    //    creates variable for our timer
    
    var gameTimer:Timer!
    
    
    //    an array of the alien image names that we will use to generate aliens
    var possibleAliens = ["alien", "alien2", "alien3"]
    
    
    //    these allow for collisions between aliens and torpedos
    
//    this is the number 2 in binary
    let alienCategory:UInt32 = 0x1 << 1
    
//    this is the number 1 in binary
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    
    
    //    this sets up a variable we can use to get the movement of the phone
    let motionManger = CMMotionManager()
    
//    sets up an acceleration variable we can set when the device moves
    var xAcceleration:CGFloat = 0
    
    
//    this method is called in the beginning to set up the scene
    
    override func didMove(to view: SKView) {
        
//        sets the starfield variable to our particle file
        starfield = SKEmitterNode(fileNamed: "Starfield")
        
//        sets the position of our particle
        starfield.position = CGPoint(x: 0, y: 1472)
        
//      moves our starfield particles ahead in time
        starfield.advanceSimulationTime(10)
        
//       adds starfield to the scene
        self.addChild(starfield)
        
//        moves the starfield to the back
        starfield.zPosition = -1
        
        
//        sets the player variable to shuttle
        player = SKSpriteNode(imageNamed: "shuttle")
        
        
//        puts the player at the bottom of the screen
        player.position = CGPoint(x: self.frame.size.width / 2, y: player.size.height / 2 + 20)
        
        
//        adds the player to the scene
        self.addChild(player)
        
        
        
//        sets our gravity to no gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
//        This line says "This class will define a function that will be called whenever a torpedo hits a node
//        and will handle it appropriately
        self.physicsWorld.contactDelegate = self
        
        
//        sets the scorelabel to have default text
        scoreLabel = SKLabelNode(text: "Score: 0")
        
//        puts score label in corner
        scoreLabel.position = CGPoint(x: 100, y: self.frame.size.height - 60)
        
//        sets the scorelabel to custom font ofAmericanTypewriter-Bold
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        
//        sets the scorelabel font-size
        scoreLabel.fontSize = 36
        
//        sets the scorelabel color
        scoreLabel.fontColor = UIColor.white
        
//        sets the starting score to 0
        score = 0
        
        
//        adds the scorelabel that we've created to the game
        self.addChild(scoreLabel)
        
        
//        this line says "Our gametimer is going to be a timer that gets called every 0.75 seconds. It will call the function addAlien that we define in this class (self) , and the function name will be called every 0.75 seconds. We would like it to repeat every 0.75 seconds". We also pass in nil to userinfo
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        
//        our motion manager manages the motion of the phone, so it will call the accelerometer update
//        function we define every 0.2 seconds
        motionManger.accelerometerUpdateInterval = 0.2
        
//         we say that the code block below is to be called
//        every 0.2 seconds. it sets the acceleration of the class appropriately
//        it determines the acceleration from the gyroscope (tilting) of the phone
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
        
        
        
    }
    
    
    
    
//    this function is called every 0.75 seconds and it adds an alien to the screen
    func addAlien () {
        
//        shuffles our array of possible images names defined above in the file
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
//        creates a sprite node of the first element of the shuffled alien array, thus creating
//        a random alien
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        
        
//        get's a series of random numbers from an apple defined function
        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
        
//        creates a position variable from one of those random numbers
        let position = CGFloat(randomAlienPosition.nextInt())
        
//        sets the alien x-position as the previous line, and sets the y-position
//        so that they are created off-screen
        alien.position = CGPoint(x: position, y: self.frame.size.height + alien.size.height)
        
        
//        gives the alien physical properties by setting a physics rectangle around the alien
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        
//        gives the alien the physical property of a dynamic body so that things like torpedos
//        can collide with the it (alien)
        alien.physicsBody?.isDynamic = true
        
//        this requires me to explain in person; if you forgot, come find me, and I'll explain again
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
//        adds the alien to the scene
        self.addChild(alien)
        
//        
        let animationDuration:TimeInterval = 6
        
        
//        creates an empty action array that we will start adding actions to
        var actionArray = [SKAction]()
        
//        animates the movement of the alien
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: animationDuration))
        
//        removes the alien once it is off screen
        actionArray.append(SKAction.removeFromParent())
        
//        runs the animations
        alien.run(SKAction.sequence(actionArray))
        
    
    }
    
    
//    called when iphone is touched. Calls the fire torpedo function
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireTorpedo()
    }
    
    
    
//    this function sets up a torpedo, animates the torpedo, and plays the sound of firing
    func fireTorpedo() {
        
//        plays the audio clip of firing a torpedo
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
//        creates a spritekit node that is a torpedo (from our torpedo image file we imported)
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        
//        first, puts the torpedo node in the same place as the spaceship/player
        
        torpedoNode.position = player.position
        
//        then, moves the torpedo up 5 pixels
        torpedoNode.position.y += 5
        
//        gives the torpedo physical properties using the radius of the torpedo (yay Geometry!)
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        
//        gives the torpedo the ability to collide with other objects
        torpedoNode.physicsBody?.isDynamic = true
        
        
        //        this requires me to explain in person; if you forgot, come find me, and I'll explain again

        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        
//        adds the torpedo to the scene
        self.addChild(torpedoNode)
        
        
        let animationDuration:TimeInterval = 0.3
        
//        creates a series of actions that are to be called
        var actionArray = [SKAction]()
        
//        fires the torpedo to the top of the screen
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        
//        removes the torpedo from the scene after it is off the screen
        actionArray.append(SKAction.removeFromParent())
        
//        runs the actions defined above
        torpedoNode.run(SKAction.sequence(actionArray))
        
        
        
    }
    
    
//    function that is called every time two physics bodies collide (in this case, torpedo and alien)
    func didBegin(_ contact: SKPhysicsContact) {
//        defines two variables that will serve as temporary physics bodies
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        
//        the code below basically is determing whether or not a torpedo hit an alien, and if so, called the 
//        appropriate function
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
           torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    
    
    
//    called when a torpedo hits an alien
    
    func torpedoDidCollideWithAlien (torpedoNode:SKSpriteNode, alienNode:SKSpriteNode) {
    
        
//        create an explosion node
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        
//        put the explosion's position where the alien is
        explosion.position = alienNode.position
        
//        add the explosion to the scene
        self.addChild(explosion)
        
        
//        play the explosion sound
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        
//        remove the torpedo and alien from the scene (Because we no longer need either)
        torpedoNode.removeFromParent()
        alienNode.removeFromParent()
        
        
//        remove the explosion from the scene after 2 seconds of seeing the explosion
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        
        
//        add five points to the score
        score += 5
        
        
    }
    
    
//    this method is automatically called once per frame and it will handle the position of the ship
    override func didSimulatePhysics() {
        
//      sets the position to take into the phone movement (set to xAcceleration in didMove) into account
        player.position.x += xAcceleration * 50
        
//        handles moving on and off screen
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
        
    }
    
    
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
