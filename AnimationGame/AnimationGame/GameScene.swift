//
//  GameScene.swift
//  AnimationGame
//
//  Created by Kevin Andrade on 2/21/19.
//  Copyright © 2019 Kevin Andrade. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //This function loads everytime the scene loads up
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size //this will set the background to the scene size
        background.position = CGPoint(x: self.size.width/2 , y:self.size.height/2)  //this will get us to the center point of the scene
        background.zPosition = 0    //order in layer
        self.addChild(background)   //take the code above and make it!
        
        let player = SKSpriteNode(imageNamed: "playerShip")
        player.setScale(1)  //normal size, if bigger increase the number...each integer is twice as big as original
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)  //this will make the player spawn from 20 percent of the screen
        player.zPosition = 2
        self.addChild(player)
        
        
        
        
    }
}
