//
//  Dot.swift
//  Double Dot
//
//  Created by Emmanuel Douge on 11/3/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Dot : SKNode
{
    //larger ring radius
    var ringRadius: CGFloat = 80
    
    public var mainDot = SKShapeNode(circleOfRadius: 0)
    public var ring: SKShapeNode = SKShapeNode()
    public var secDot: SKShapeNode = SKShapeNode(circleOfRadius: 0)
    public var rotateSpeed: Float = 8
    public var secRotateSpeed: Float = 0
    public var incrementValue: Float = 0.20

    //need init to carry on the spinning chain of newDot = Dot(mainDotPos:,Ring:
    //,secondaryDot:)
    override init()
    {
        super.init()
        let dimen: (CGFloat, CGFloat) = UIScreen.main.bounds.wh
        
        //init speeds to scale with device
        self.rotateSpeed = Float(dimen.0/51.75)
        self.secRotateSpeed = 20.0
        self.zPosition = 10
        
        //setup maindot
        self.mainDot = SKShapeNode(circleOfRadius: dimen.0/28)
        self.mainDot.strokeColor = ballColor
        self.mainDot.fillColor = ballColor
        self.mainDot.name = "mainDot"
        self.addChild(self.mainDot)
        self.mainDot.zPosition = 11
        
        //setup ring
//        print("Dimen divided \(dimen.0/5.175) then dimen \(dimen)")
        self.ring = SKShapeNode.init(circleOfRadius: dimen.0/5.175)
        self.ring.strokeColor = ringColor
        self.ring.lineWidth = dimen.0/207
        self.ring.position = CGPoint.init(x: self.ring.position.x,
                                        y: self.ring.position.y + dimen.0/5.175)
        self.mainDot.addChild(self.ring)
        self.ring.zPosition = 7
        
        //setup secondaryDot
        self.secDot = SKShapeNode(circleOfRadius: dimen.0/28)
        self.secDot.strokeColor = ballColor
        self.secDot.fillColor = ballColor
        self.secDot.position = CGPoint.init(x: self.ring.position.x,
                                                        y: self.ring.position.y)
        ring.addChild(secDot)
        self.secDot.zPosition = 11
        
        //begin initialRotation
        self.beginInitialRotation()
    }
    
    init(mainDot: Dot)
    {
        super.init()
        
        self.zPosition = mainDot.zPosition
        let dimen: (CGFloat, CGFloat) = UIScreen.main.bounds.wh
        
        //position of new mainDot is the origin of the mainDot node
        self.position = mainDot.scene!.convert(mainDot.secDot.position,
                                                from: mainDot.secDot.parent!)
        
        //set up main dot
        self.mainDot = SKShapeNode(circleOfRadius: dimen.0/28)
        self.mainDot.zPosition = mainDot.mainDot.zPosition
        self.mainDot.strokeColor = mainDot.mainDot.strokeColor
        self.mainDot.fillColor = mainDot.mainDot.fillColor
        self.mainDot.name = "mainDot"
        self.addChild(self.mainDot)
        
        //ring position remains the same as previous except converted 
        //to this nodes coord system
        self.ring = SKShapeNode.init(circleOfRadius: dimen.0/5.175)
        self.ring.zPosition = mainDot.ring.zPosition
        self.ring.strokeColor = mainDot.ring.strokeColor
        self.ring.lineWidth = mainDot.ring.lineWidth
        self.ring.position = self.convert(mainDot.ring.position,
                                                from: mainDot.ring.parent!)
        self.mainDot.addChild(self.ring)
        
        //set up secondary dot to take mainDot.mainDots old position
        self.secDot = SKShapeNode(circleOfRadius: dimen.0/28)
        self.secDot.zPosition = mainDot.secDot.zPosition
        self.secDot.strokeColor = mainDot.secDot.strokeColor
        self.secDot.fillColor = mainDot.secDot.fillColor
        self.secDot.position = CGPoint.init(x: self.ring.position.x,
                                                y: self.ring.position.y)
        self.ring.addChild(self.secDot)
        
        //propagate rotation speed
        self.rotateSpeed = mainDot.rotateSpeed
        self.nextRotation()
        
        //inherit secDotRot speed
        self.secRotateSpeed = mainDot.secRotateSpeed
        self.secDotRotate()
    }
    
    //mini double dot
    init(miniDotName: String)
    {
        let dimen: (CGFloat, CGFloat) = UIScreen.main.bounds.wh
        
        super.init()
        //self.zPosition = 12
        
        //setup ring
        //        print("Dimen divided \(dimen.0/5.175) then dimen \(dimen)")
        self.ring = SKShapeNode.init(circleOfRadius: dimen.0/5.175)
        self.ring.strokeColor = ringColor
        self.ring.lineWidth = dimen.0/138
//        self.ring.position = CGPoint.init(x: self.ring.position.x,
//                                          y: self.ring.position.y + dimen.0/5.175)
        self.addChild(self.ring)
        self.ring.zPosition = 7
        
        //setup maindot
        self.mainDot = SKShapeNode(circleOfRadius: dimen.0/28)
        self.mainDot.zPosition = 11
        self.mainDot.strokeColor = ballColor
        self.mainDot.fillColor = ballColor
        self.mainDot.name = "Mini Dot"
        self.ring.addChild(self.mainDot)
        self.mainDot.position.y -= dimen.0/5.175
        
        
        
        //setup secondaryDot
        self.secDot = SKShapeNode(circleOfRadius: dimen.0/28)
        self.secDot.strokeColor = ballColor
        self.secDot.fillColor = ballColor
        self.secDot.position.y += dimen.0/5.175
        ring.addChild(secDot)
        self.secDot.zPosition = 11
        
        //begin initialRotation
        self.spinForLogo()
    }
    
    func beginInitialRotation()
    {
        //begins initial rotation

        //print("Beginning initialRotation")
        self.mainDot.run(rotateForever(speed: rotateSpeed))
    }
    
    func secDotRotate()
    {
        //makes secdot spin to decrease the chance of the nodes square frame
        //giving an advantage when landing on destDots
        self.secDot.run(rotateForever(speed: secRotateSpeed))
    }
    
    func spinForLogo()
    {
        //begins initial rotation
        //print("Beginning initialRotation")
        self.ring.run(rotateForever(speed: rotateSpeed))
    }
    
    //rotates the mainDot node in the opposite direction each call
    func nextRotation()
    {
        //if positive
        rotateSpeed = (rotateSpeed > 0) ? 0 - rotateSpeed : abs(rotateSpeed)
        self.mainDot.run(rotateForever(speed: rotateSpeed))
    }
    
    //slightly speeds up rotation
    func speedUpRotation()
    {
        print("Curr. rot. speed \(rotateSpeed).Inc'ing by \(incrementValue)")
        self.removeAllActions()
        rotateSpeed += (rotateSpeed > 0) ? incrementValue : -incrementValue
        self.run(rotateForever(speed: rotateSpeed))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
