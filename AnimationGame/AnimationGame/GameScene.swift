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
    let player = SKSpriteNode(imageNamed: "playerShip")
    let bulletSound = SKAction.playSoundFileNamed("sound_spark_Laser-Like_Synth_Laser_Noise_Blast_Oneshot_03.mp3", waitForCompletion: false)    //so it starts playing and following sequences happen without waiting.
    //This function loads everytime the scene loads up
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size //this will set the background to the scene size
        background.position = CGPoint(x: self.size.width/2 , y:self.size.height/2)  //this will get us to the center point of the scene
        background.zPosition = 0    //order in layer
        self.addChild(background)   //take the code above and make it!
        
        player.setScale(1)  //normal size, if bigger increase the number...each integer is twice as big as original
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)  //this will make the player spawn from 20 percent of the screen
        player.zPosition = 2
        self.addChild(player)
        
        
        
        
    }
    
    
    func fireBullet(){
        //spawn bullet
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        self.addChild(bullet)
        
        //moving bullet up
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1) //will take one second to move up the screen
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])  //this takes an array of acions in sequence.
        bullet.run(bulletSequence)
        
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //lets figure out where in the screen we are touching and how much distance we have dragged our finger
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in:self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x //finding the difference (how far we dragged our finger)
            player.position.x += amountDragged
            
        }
    }
}
