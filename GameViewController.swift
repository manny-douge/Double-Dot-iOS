//
//  GameViewController.swift
//  Double Dot
//
//  Created by Emmanuel Douge on 11/2/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, UIAlertViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view as! SKView
        // Load the SKScene from 'GameScene.sks'
        let scene = GameScene(size: view.frame.size)
    
        // Set the scale mode to scale to fit the window
        print(view.frame.size)
        scene.scaleMode = .aspectFill
        scene.size = view.frame.size
                
        // Present the scene
        view.presentScene(scene)
        
        view.ignoresSiblingOrder = true
        
        view.showsFPS = false
        view.showsNodeCount = false
        
    }
    
    

    
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
