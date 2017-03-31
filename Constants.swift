//
//  Constants.swift
//  Double Dot
//
//  Created by Emmanuel Douge on 11/2/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

//COLOR CONSTANTS
let ballColor: SKColor = SKColor.orange
let ringColor: SKColor = UIColor(red:0.93, green:0.46, blue:0.09, alpha:1.0)
let bgColor: SKColor = UIColor(red:0.93, green:0.94, blue:0.88, alpha:1.0)
let destColor:SKColor = UIColor(red:0.07, green:0.54, blue:0.71, alpha:1.0)
let partialColor:SKColor = SKColor.gray
let regularColor:SKColor = SKColor.red
let perfectColor:SKColor = UIColor(red:0.07, green:0.54, blue:0.71, alpha:1.0)


//easil access scene wh with UIScreen.main.bounds
extension CGRect
{
    var wh: (w: CGFloat, h:CGFloat)
    {
        return (size.width,size.height)
    }
}

//inifinite rotate
func rotateForever(speed: Float) -> SKAction
{
    let conv: CGFloat = CGFloat(speed)
    return SKAction.repeatForever(SKAction.rotate(byAngle: conv, duration: 5))
}

func fadeInAndOut(speed: Double) -> SKAction
{
    let fadeIn = SKAction.fadeIn(withDuration: speed)
    let fadeOut = SKAction.fadeOut(withDuration: speed)
    let sequence = SKAction.sequence([fadeIn, fadeOut])
    return SKAction.repeatForever(sequence)
}

enum GameState {
    case Loading
    case Menu
    case InGame
    case GameOver
}
