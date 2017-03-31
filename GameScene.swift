//
//  GameScene.swift
//  Double Dot
//
//  Created by Emmanuel Douge on 11/2/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
import GoogleMobileAds
import Firebase
//set our to be the contact delegate
class GameScene: SKScene {
    
    //MARK: Member Variables
    
    //instertial ad
    var interstitial: GADInterstitial!
    
    //player class simply holds sava data
    var player = Player()
    
    //houses all nodes that will displayed before gameplay, hence menu
    let menuLayer: SKNode = SKNode()
    
    //houses all nodes that will take part in the gameplay, scoreLabel, dots etc
    let gameLayer: SKNode = SKNode()
    
    //hud for in game that follows the player and holds score, best, etc
    let gameHudLayer: SKNode = SKNode()
    
    //houses the scene width and height in .0 & .1 respectively, must be used
    //after init
    var wh: (CGFloat, CGFloat) = (0.0,0.0)
    
    //stores all possible spawn positions of the destination dot
    var arrayOfPos = [CGPoint]()
    
    //this tuple holds a collection of the type of collision
    var collisionBools: (Bool, Bool, Bool) = (false, false, false)
    
    //cameraNode
    private let cameraNode = SKCameraNode()
    
    //the dot rotation dot the player controls
    private var mainDot: Dot = Dot()
    
    //the dot the player is aiming for
    private var destDot: SKShapeNode = SKShapeNode()
    
    
    let camShakeArr = [4 , 6 , 8, 10]
    
    //default state allows nothnig to happen
    var currentState: GameState = .Loading
    
    //score label during the game
    var scoreLabel = SKLabelNode.init(fontNamed: "Katahdin Round")
    
    //best score label
    var bestScoreLabel = SKLabelNode.init(fontNamed: "Katahdin Round")
    
    //holds the score
    var score: Int = 0
    
    //the current radius of the dest dot, it is initiliazed in beginGame()
    var currentRadiusOfDestDot:CGFloat = 0.0
    
    //is the game muted
    var isSoundMuted: Bool = false
    
    //this is the sound that is played for every successful tap
    var bgMusic: AVAudioPlayer = AVAudioPlayer.init()
    
    //this is the sound that is played for every successful tap
    var positiveSound: AVAudioPlayer = AVAudioPlayer.init()
    
    //this is the sound played on every failed tap
    var negativeSound: AVAudioPlayer = AVAudioPlayer.init()
    
    //MARK: Setup
    
    override func didMove(to view: SKView)
    {
        self.setUpScene()
        self.setupSound()
    }
    
    override init(size: CGSize)
    {
        super.init(size: size)
        print(size)
        //setup basis of layers
        self.addChild(menuLayer)
        menuLayer.zPosition = 20
        
        gameLayer.zPosition = 10
        self.addChild(gameLayer)
        print("Ran game scene init")
        
        
        //setup screen w/h
        wh = UIScreen.main.bounds.wh
        
        
        self.backgroundColor = bgColor
        
        //init camera
        cameraNode.position = CGPoint.init(x: wh.0/2, y: wh.1/2)
        self.addChild(cameraNode)
        self.camera = cameraNode
//        cameraNode.setScale(3)
        
        //init hud
        self.cameraNode.addChild(gameHudLayer)
        
        
        //init spawn positions
        let radiusMax: CGFloat = CGFloat(wh.0/5.175)*2
        arrayOfPos =
            [CGPoint.init(x: 0, y: radiusMax), // top middle
            CGPoint.init(x: radiusMax, y: 0), // far right
            CGPoint.init(x: 0, y: -radiusMax), // bottom midde
            CGPoint.init(x: -radiusMax, y: 0), // far left
            CGPoint.init(x: radiusMax/1.5, y: radiusMax*0.75), // right top corner
            CGPoint.init(x: radiusMax*0.75, y: -radiusMax/1.5),//bot right corner
            CGPoint.init(x: -radiusMax*0.75, y: radiusMax/1.5), // left top corner
            CGPoint.init(x: -radiusMax*0.75, y: -radiusMax/1.5)] // left bottom corner
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    
    //gets everything ready for play after everything is initialized
    func setUpScene()
    {
        self.createAndLoadInterstitial()
        //self.saveGame()
        //load game
        player = self.loadGame()
        print("First play ? \(player.firstPlay)")
        
        print("Setting up scene")
        //set up gamelabel
        let gameLabel: SKLabelNode = SKLabelNode.init(fontNamed: "Katahdin Round")
        gameLabel.name = "Game Label"
        gameLabel.text = "D   UBLE"
        gameLabel.fontSize = wh.0/5.175
        gameLabel.position = CGPoint.init(x: wh.0/2, y: wh.1/1.3)
        gameLabel.fontColor = SKColor.orange
        menuLayer.addChild(gameLabel)
        
        //set up spinning minidot for D [O] UBLE
        let miniDot: Dot = Dot.init(miniDotName: "Mini Dot")
        gameLabel.addChild(miniDot)
        miniDot.setScale(wh.0/1182.85)
        miniDot.position.x -= wh.0/4.85
        miniDot.position.y += wh.0/12.5
        
        //set up DOT label
        let dotLabel: SKLabelNode = SKLabelNode.init(fontNamed: "Katahdin Round")
        dotLabel.text = "D   T"
        dotLabel.fontSize = wh.0/4.14
        dotLabel.position.y -= wh.0/4
        dotLabel.fontColor = SKColor.orange
        gameLabel.addChild(dotLabel)
        
        //set up spinning minidot for D [O] T
        let miniDot2: Dot = Dot.init(miniDotName: "Mini Dot")
        dotLabel.addChild(miniDot2)
        miniDot2.setScale(wh.0/828)
        miniDot2.position.y += wh.0/12
        
        //setup play button
        let playButton = SKSpriteNode.init(texture: SKTexture.init(imageNamed: "playButton"), size: CGSize.init(width: wh.0/4.14, height: wh.0/4.14))
        playButton.position = CGPoint.init(x: wh.0/2, y: wh.1/3)
        playButton.name = "Play Button"
        menuLayer.addChild(playButton)
        
        self.loadCorrectMuteButton()
        
        //fade in
        menuLayer.alpha = 0.0
        menuLayer.run(SKAction.fadeIn(withDuration: 0.6), completion: {
            self.currentState = .Menu
        })
        
        
    }

    func beginGame()
    {
        //load add
        if(interstitial.hasBeenUsed == true)
        {
            print("Loading new ad")
            self.createAndLoadInterstitial()
        }
        
        print("Play button tapped, starting game")
        //entering game
        currentState = .InGame
        
        //fade out labels
        self.menuLayer.run(SKAction.fadeOut(withDuration: 0.3))
        self.resetHudScore()
        //init mainDot
        print("Base mainDot node position is \(mainDot.position)")
        gameLayer.addChild(mainDot)
        mainDot.position = CGPoint.init(x: wh.0/2, y: wh.1/2)
        mainDot.zPosition = 12;
        
        if(player.firstPlay == true)
        {
            self.playTutorial()
        }
        //set current destDot size to default value
        self.currentRadiusOfDestDot = wh.0/10
        self.spawnNextDot()
        
    }
    
    
    func setupGameOver()
    {
        //present ad
        let randInt: Int = Int(arc4random_uniform(2))
        if(randInt == 0)
        {
            print("displaying AD")
            self.presentAd()
        }
        
        
        //save game
        self.saveGame()
        
        //gameover mode
        self.currentState = .GameOver
        
        //make secDot fall off
        self.mainDot.secDot.physicsBody = SKPhysicsBody.init(rectangleOf:
            self.mainDot.secDot.frame.size)
        self.mainDot.secDot.physicsBody?.isDynamic = true
        
        //move back button in
        let backButton = SKSpriteNode.init(texture: SKTexture.init(imageNamed: "backButton"), size: CGSize.init(width: wh.0/4.14, height: wh.0/4.14))
        backButton.alpha = 0
        backButton.position = self.mainDot.position
        backButton.position.x -= wh.0/4
        backButton.position.y -= wh.1/4
        backButton.name = "Back Button"
        gameLayer.addChild(backButton)
        
        //move replay button in
        let replayButton = SKSpriteNode.init(texture: SKTexture.init(imageNamed: "replayButton"), size: CGSize.init(width: wh.0/4.14, height: wh.0/4.14))
        replayButton.alpha = 0
        replayButton.position = self.mainDot.position
        replayButton.position.x += wh.0/4
        replayButton.position.y -= wh.1/4
        replayButton.name = "Replay Button"
        gameLayer.addChild(replayButton)
        
        //fade buttons in
        replayButton.run(SKAction.fadeIn(withDuration: 0.3))
        backButton.run(SKAction.fadeIn(withDuration: 0.3))
        
        
        //dim maindot and dest dot
        self.mainDot.run(SKAction.fadeAlpha(to: 0.5, duration: 0.3))
        
        //remove the inner dots to avoid opacity overlap during fade
        self.destDot.removeAllChildren()
        self.destDot.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
    }
    
    //MARK: Sound
    func setupSound()
    {
        //set up bgMusic
        let pathToBg = Bundle.main.path(forResource: "bgMusic", ofType:"mp3")!
        let urlToBg = URL(fileURLWithPath: pathToBg)
        //set up positive sound
        let pathToPos = Bundle.main.path(forResource: "positiveSound", ofType:"wav")!
        let urlToPos = URL(fileURLWithPath: pathToPos)
        //set up negative sound
        let pathToNeg = Bundle.main.path(forResource: "negativeSound", ofType:"wav")!
        let urlToNeg = URL(fileURLWithPath: pathToNeg)
        do
        {
            bgMusic = try AVAudioPlayer(contentsOf: urlToBg)
            positiveSound = try AVAudioPlayer(contentsOf: urlToPos)
            negativeSound = try AVAudioPlayer(contentsOf: urlToNeg)
        }
        catch
        {
            print("Error setting up sound")
        }
        
        if(isSoundMuted == false)
        {
            bgMusic.numberOfLoops = -1
            bgMusic.play()
        }
        
    }
    
    //play certain sound depending on string
    func playSound(name: String)
    {
        if(isSoundMuted == false)
        {
            if(name == "Positive")
            {
                positiveSound.stop()
                positiveSound.play()
            }
            else if(name == "Negative")
            {
                negativeSound.stop()
                negativeSound.play()
            }
        }
    }
    
    //mutes sound and also changes mute button to match it
    func muteSound()
    {
        
        //turn sound off
        if(isSoundMuted == true)
        {
            print("Unmuting sound")
            isSoundMuted = false
            self.loadCorrectMuteButton()
            bgMusic.play()
        }
        //turn sound off
        else
        {
            print("Muting sound")
            isSoundMuted = true
            self.loadCorrectMuteButton()
            bgMusic.stop()
        }
        
    }
    
    func loadCorrectMuteButton()
    {
        print("Loading correct mute button")
        //kill old sound node
        let oldSoundNode = menuLayer.childNode(withName: "Mute Button")
        oldSoundNode?.removeFromParent()
        
        //choose correct sprite based on if muted
        let soundSprite = (isSoundMuted == false) ? "soundIsOn" : "soundIsOff"
    
        //replace old sound node with correct sprite
        let newSoundNode = SKSpriteNode.init(texture: SKTexture.init(imageNamed: soundSprite), size: CGSize.init(width: wh.0/8.34, height: wh.0/8.34))
        newSoundNode.position = CGPoint.init(x: wh.0/2, y: wh.0/5)
        newSoundNode.name = "Mute Button"
        menuLayer.addChild(newSoundNode)
    }
    //adds a label to the screen "TAP ANYWHERE", fades in and out
    func playTutorial()
    {
        //tapLabel init basics
        let tapLabel:SKLabelNode = SKLabelNode.init(fontNamed: "Katahdin Round")
        tapLabel.name = "Tap Label"
        tapLabel.text = "TAP ANYWHERE"
        tapLabel.fontColor = ballColor
        tapLabel.fontSize = wh.0/20
        gameHudLayer.addChild(tapLabel)
        tapLabel.position.y -= wh.1/3
        tapLabel.alpha = 0
        
        //declared in constants fade in and out
        tapLabel.run(fadeInAndOut(speed: 0.8))
        
        /// saves the game so that the tutorial never runs again
        self.saveGame()
    }
    
    
    //MARK: Score and Score Label related
    //load in the score for the HUD
    func loadInHud()
    {
        score = 0
        scoreLabel.text = "\(score)"
        scoreLabel.fontColor = ballColor
        scoreLabel.fontSize = wh.0/5.175
        gameHudLayer.addChild(scoreLabel)
        scoreLabel.position.y += wh.1/3
        
        bestScoreLabel.text = "BEST: \(player.bestScore)"
        bestScoreLabel.fontColor = ballColor
        bestScoreLabel.fontSize = wh.0/15
        gameHudLayer.addChild(bestScoreLabel)
        bestScoreLabel.position.y -= wh.1/2.1
        bestScoreLabel.position.x -= wh.0/3.5
    }
    
    //resets the HUDScore when a run is finished
    func resetHudScore()
    {
        score = 0
        scoreLabel.text = "\(score)"
        bestScoreLabel.text = "BEST: \(player.bestScore)"
        
        //revert back to original colors if user previously beat his score
        scoreLabel.fontColor = ballColor
        bestScoreLabel.fontColor = ballColor
    }
    
    //adds a "+1" and "+2" effect for the score
    func incrementEffects(amountInString: String, color: SKColor)
    {
        //choose text position and color
        let amountLabel = SKLabelNode.init(fontNamed: "Katahdin Round")
        amountLabel.text = amountInString
        amountLabel.fontColor = color
        amountLabel.fontSize = wh.0/15
        amountLabel.position = scoreLabel.position
        amountLabel.zPosition = scoreLabel.zPosition + 1
        
        //have node rise and fade out then remove from parent
        let nextPos: CGFloat = amountLabel.position.y + wh.0/5
        let rise = SKAction.moveTo(y: nextPos, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        let group = SKAction.group([rise, fadeOut])
        let delete = SKAction.run {
            amountLabel.removeFromParent()
        }
        let sequence = SKAction.sequence([group, delete])
        
        self.gameHudLayer.addChild(amountLabel)
        amountLabel.run(sequence)
    }
    
    //this function resets the players current run
    func restartGame()
    {
        //set game state to Loading to avoid any touches happening during anims.
        self.currentState = .Loading
        
        //move anything extra that spawns at the end of the game out HERE:
        let back = gameLayer.childNode(withName: "Back Button")
        back?.run(SKAction.fadeOut(withDuration: 0.2), completion: {
            back?.removeFromParent()
        })
        
        //move replay button out and then reset everything
        let replay = gameLayer.childNode(withName: "Replay Button")
        replay?.run(SKAction.fadeOut(withDuration: 0.2), completion: {
            replay?.removeFromParent()
            self.mainDot.removeFromParent()
            self.mainDot = Dot()
            self.beginGame()
            self.focusCamera()
        })
    }
    
    //actually add points to score
    func addPointsToScore(amount: Int)
    {
        score += amount
        scoreLabel.text = "\(score)"
        
        //increment simulatanouely when the user beats his own score
        if(score >= player.bestScore)
        {
            //make label pulsate
            let scaleUp = SKAction.scale(to: 1.25, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1, duration: 0.1)
            bestScoreLabel.run(SKAction.sequence([scaleUp, scaleDown]))
            bestScoreLabel.text = "BEST: \(score)"
        }
    }

    //spawns TEXT at POS with COLOR and rises a
    func displayText(text: String, pos: CGPoint, color: SKColor)
    {
        //choose text position and color
        let textLabel = SKLabelNode.init(fontNamed: "Katahdin Round")
        textLabel.text = text
        textLabel.fontColor = color
        textLabel.fontSize = wh.0/13.8
        textLabel.position = pos
        textLabel.zPosition = destDot.zPosition + 4
        
        //have node rise and fade out then remove from parent
        let nextPos: CGFloat = textLabel.position.y + wh.0/6.9
        let rise = SKAction.moveTo(y: nextPos, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        let group = SKAction.group([rise, fadeOut])
        let delete = SKAction.run {
            textLabel.removeFromParent()
        }
        let sequence = SKAction.sequence([group, delete])
        
        self.gameLayer.addChild(textLabel)
        textLabel.run(sequence)
    }
    
    //increment score depending on touch type
    func incrementScore(type: String)
    {
        //do regular increment and animations
        if(type == "Perfect")
        {
            print("Perfect touch increment")
            self.displayText(text: "Perfect", pos: destDot.position, color: perfectColor)
            self.addPointsToScore(amount: 2)
            self.incrementEffects(amountInString: "+2", color: perfectColor)
        }
        else if(type == "Regular")
        {
            print("Regular touch increment")
            self.displayText(text: "GOOD", pos: destDot.position, color: regularColor)
            self.addPointsToScore(amount: 1)
            self.incrementEffects(amountInString: "+1", color: regularColor)
        }
        else if(type == "Partial")
        {
            self.displayText(text: "BAD", pos: destDot.position, color: partialColor)
        }
    }

    //MARK: Destination Dot and related funcs
    func spawnNextDot()
    {
        //remove previously spawned dot with elegance
        let oldDestDot = self.destDot
        oldDestDot.removeAllChildren()
        oldDestDot.run(SKAction.fadeOut(withDuration: 0.3), completion: {
            oldDestDot.removeFromParent()
        })
        //get random location for next dot
        let randNum = Int(arc4random_uniform(7))
        
        //create dot and inner dot
        destDot = SKShapeNode.init(circleOfRadius: self.currentRadiusOfDestDot)
        destDot.strokeColor = destColor
        destDot.fillColor = destColor
        destDot.zPosition = 9
        destDot.position = CGPoint.init(x: self.mainDot.position.x + arrayOfPos[randNum].x,
                                        y: self.mainDot.position.y + arrayOfPos[randNum].y)
        destDot.name = "Dest Dot"
        
        let regularDot = SKShapeNode.init(circleOfRadius: self.currentRadiusOfDestDot/2)
        regularDot.zPosition = destDot.zPosition + 1
        regularDot.name = "Regular Dot"
        regularDot.strokeColor = destColor
        regularDot.fillColor = destColor
        
        let innerPerfectDot = SKShapeNode.init(circleOfRadius: self.currentRadiusOfDestDot/5)
        innerPerfectDot.zPosition = regularDot.zPosition + 1
        innerPerfectDot.name = "Inner Dot"
        innerPerfectDot.strokeColor = destColor
        innerPerfectDot.fillColor = destColor
        
        
        //add them to the scene
        destDot.addChild(regularDot)
        destDot.addChild(innerPerfectDot)
        self.gameLayer.addChild(destDot)
        
        //decrease dot size each spawn if not greater than minimum radius
        let minimumRadius = wh.0/26
        let decrementValue = minimumRadius/100
        self.currentRadiusOfDestDot = (self.currentRadiusOfDestDot - decrementValue < minimumRadius)
            ? self.currentRadiusOfDestDot : self.currentRadiusOfDestDot - decrementValue
        //print("New radius of dest dot is \(self.currentRadiusOfDestDot), decrementValue is \(decrementValue)")
    }

    
    func nextRotation()
    {
        //create new mainDot each rotation
        let tempDot = Dot(mainDot: self.mainDot)
        self.mainDot.removeFromParent()
        self.mainDot = tempDot
        gameLayer.addChild(self.mainDot)
        
        //have camera pan to new mainDot each rotation
        self.focusCamera()
        
        self.mainDot.speedUpRotation()
    }
    
    //focuses camera on the main dot
    func focusCamera()
    {
        //move camera to mainDot
        self.cameraNode.removeAllActions()
        self.cameraNode.run(SKAction.move(to: self.mainDot.position, duration: 0.2))
    }
    
    //sets a tuple containing 3 bools
    //Bool 1 Partial ,Bool 2 Regular Touch, Bool 3 Perfect Touch
    func checkCollision()
    {
        collisionBools.0 = self.mainDot.secDot.intersects(destDot)
        
        //bool 2 regular touch
        let regularDot = self.destDot.childNode(withName: "Regular Dot")!
        let secDotPos2 = regularDot.convert(self.mainDot.secDot.position,
                                          from: self.mainDot.secDot.parent!)
        collisionBools.1 = regularDot.frame.contains(secDotPos2)
        
        //bool 3 perfect touch
        let innerDot = self.destDot.childNode(withName: "Inner Dot")!
        let secDotPos3 = innerDot.convert(self.mainDot.secDot.position,
                                          from: self.mainDot.secDot.parent!)
        collisionBools.2 = innerDot.frame.contains(secDotPos3)
    }
    
    //MARK: Update and Touches
    //called every touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        //cop that touch position
        var touchLocation: CGPoint = CGPoint.init(x: 0, y: 0)
        for touch in touches
        {
            touchLocation = touch.location(in: self)
        }
        
        //prevents crashes if the system cant register touch events fast enough
        var arrOfNodes: [SKNode] = nodes(at: touchLocation)
        let node: SKNode = (arrOfNodes.isEmpty) ? SKNode() : arrOfNodes[0]
        
        if(currentState == .Menu)
        {
            if(node.name == "Play Button")
            {
                self.beginGame()
                self.loadInHud()
            }
            else if(node.name == "Mute Button")
            {
                self.muteSound()
            }
        }
        else if(currentState == .InGame)
        {
            //remove the tap anywhere label if its there
            if(score > 3)
            {
                if let tapLabel = gameHudLayer.childNode(withName: "Tap Label")
                {
                    print("Tap label exists, deleting.")
                    tapLabel.run(SKAction.fadeOut(withDuration: 0.8), completion: {
                            tapLabel.removeFromParent()
                    })
                }
            }
        
            //check if dot landed in proper location and end game accordingly
            self.checkCollision()
            if(collisionBools.0 == false && collisionBools.1 == false)
            {
                print("Game should be over")
                self.playSound(name: "Negative")
                self.setupGameOver()
            }
            else if(collisionBools.2 == true)
            {
                print("Perfect touch")
                self.incrementScore(type: "Perfect")
                self.playSound(name: "Positive")
                self.nextRotation()
                self.spawnNextDot()
            }
            else if(collisionBools.1 == true)
            {
                print("Regular Touch")
                self.incrementScore(type: "Regular")
                self.playSound(name: "Positive")
                self.nextRotation()
                self.spawnNextDot()
            }
            else if(collisionBools.0 == true)
            {
                print("Partial Touch")
                self.incrementScore(type: "Partial")
                self.playSound(name: "Negative")
                self.nextRotation()
                self.spawnNextDot()
            }
        }
        else if(currentState == .GameOver)
        {
            if(node.name == "Back Button")
            {
                let scene = GameScene(size: self.view!.frame.size)
                scene.scaleMode = .aspectFill
                scene.size = self.view!.frame.size
                self.view?.presentScene(scene)
            }
            else if(node.name == "Replay Button")
            {
                self.restartGame()
            }
        }
    }
    
    
    override func update(_ currentTime: TimeInterval)
    {
        // Called before each frame is rendered
    }
    
    // MARK: Player Data Manipulation
    //save game data only if highscore is beaten
    func saveGame()
    {
        if(player.bestScore <= score)
        {
            print("Saving data")
            player.bestScore = score
            player.firstPlay = false

            let path = saveFileLocation()
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(player, toFile: path.path)
            if(isSuccessfulSave)
            {
                print("Successful save")
            }
            else
            {
                print("Saving failed")
            }
        }
    }
    
    func loadGame() -> Player
    {

        let path = saveFileLocation()
        let optPlayer = (NSKeyedUnarchiver.unarchiveObject(withFile: path.path) as! Player?)
        if let localPlayer = optPlayer
        {
            return localPlayer
        }
        else
        {
            return Player()
        }
    }

    func saveFileLocation() -> URL
    {
        let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = DocumentsDirectory.appendingPathComponent("Double Dot")
        return archiveURL
    }
    //MARK: AD STUFF
    
    func createAndLoadInterstitial()
    {
        interstitial = GADInterstitial.init(adUnitID: “HIDDEN FOR CONFIDENTIALITY“)
        let request = GADRequest.init()
        interstitial.load(request)
    }
    
    func presentAd()
    {
        
        let viewController =  UIApplication.shared.keyWindow?.rootViewController
        if interstitial.isReady
        {
            interstitial.present(fromRootViewController: viewController!)
        }
        else
        {
            print("Ad wasn't ready")
        }
        
    }

    

}
