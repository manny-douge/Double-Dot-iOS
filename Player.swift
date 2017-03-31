//
//  Player.swift
//  Double Dot
//
//  Created by Emmanuel Douge on 11/10/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

import Foundation

class Player : NSObject, NSCoding
{
    var bestScore: Int = 0
    var firstPlay: Bool = true
    
    //writing data
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(bestScore, forKey: "bestScore")
        aCoder.encode(firstPlay, forKey: "firstPlay")
    }
    
    //reading data
    required convenience init(coder decoder: NSCoder)
    {
        self.init()
        bestScore = Int(decoder.decodeCInt(forKey: "bestScore"))
        firstPlay = decoder.decodeBool(forKey: "firstPlay")
    }
}
