//
//  MainMenu.swift
//  AnimationGame
//
//  Created by Kevin Andrade on 2/27/19.
//  Copyright © 2019 Kevin Andrade. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene{
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let titleLabel = SKLabelNode(fontNamed: "The Bold Font")
        
        
        titleLabel.text = "Nyan Cat"
        titleLabel.fontSize = 200
        titleLabel.fontColor = SKColor.white
        titleLabel.zRotation = .pi/2
        titleLabel.position = CGPoint(x: self.size.width * 0.45, y: self.size.height * 0.5)
        titleLabel.zPosition = 1
        self.addChild(titleLabel)
 
        
        let titleLabel3 = SKLabelNode(fontNamed: "The Bold Font")
        titleLabel3.text = "Home Defender"
        titleLabel3.fontSize = 100
        titleLabel3.fontColor = SKColor.white
        titleLabel3.zRotation = .pi/2
        titleLabel3.position = CGPoint(x: self.size.width * 0.55, y: self.size.height * 0.5)
        titleLabel3.zPosition = 1
        self.addChild(titleLabel3)
        
        
        let startGameLabel = SKLabelNode(fontNamed: "The Bold Font")
        startGameLabel.text = "Start Game"
        startGameLabel.fontSize = 50
        startGameLabel.fontColor = SKColor.white
        startGameLabel.zPosition = 1
        startGameLabel.zRotation = .pi/2
        startGameLabel.position = CGPoint(x: self.size.width * 0.75, y: self.size.height * 0.5)
        startGameLabel.name = "startButton"
        self.addChild(startGameLabel)
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let nodeTapped = atPoint(pointOfTouch)
            if nodeTapped.name == "startButton"{
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
        }
    }
    
}
