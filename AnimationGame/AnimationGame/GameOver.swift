//
//  GameOver.swift
//  AnimationGame
//
//  Created by Kevin Andrade on 2/27/19.
//  Copyright © 2019 Kevin Andrade. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene{
    
    let restartLabel = SKLabelNode(fontNamed: "The Bold Font")

    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size //this will set the background to the scene size
        background.position = CGPoint(x: self.size.width/2 , y:self.size.height/2)  //this will get us to the center point of the scene
        background.zPosition = 0    //order in layer
        self.addChild(background)   //take the code above and make it!
        
        let gameOverLabel = SKLabelNode(fontNamed: "The Bold Font")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 150
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        gameOverLabel.zRotation = .pi/2
        gameOverLabel.position = CGPoint(x: self.size.width * 0.3, y: self.size.height * 0.3)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 75
        scoreLabel.fontColor = SKColor.white
        scoreLabel.zRotation = .pi/2
        scoreLabel.position = CGPoint(x: self.size.width * 0.45, y: self.size.height * 0.5)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()   //to save information even after app closes
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        if gameScore > highScoreNumber{
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
            
        }
        let highScoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        highScoreLabel.text = "High Score: \(highScoreNumber)"
        highScoreLabel.fontSize = 75
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.zPosition = 1
        highScoreLabel.zRotation = .pi/2
        highScoreLabel.position = CGPoint(x: self.size.width * 0.55, y: self.size.height * 0.5)
        self.addChild(highScoreLabel)
        
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 50
        restartLabel.fontColor = SKColor.white
        restartLabel.zPosition = 1
        restartLabel.zRotation = .pi/2
        restartLabel.position = CGPoint(x: self.size.width * 0.65, y: self.size.height * 0.5)
        self.addChild(restartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self) //taking coordinates of where we touched
            if restartLabel.contains(pointOfTouch){ //if we touched where restartLabel is
                let sceneToMoveTo = GameScene(size: self.size)  //back to game scene
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
        }
    }
}
