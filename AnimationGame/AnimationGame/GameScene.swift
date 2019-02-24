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
    let player = SKSpriteNode(imageNamed: "NyanCat")
    let bulletSound = SKAction.playSoundFileNamed("sound_spark_Laser-Like_Synth_Laser_Noise_Blast_Oneshot_03.mp3", waitForCompletion: false)    //so it starts playing and following sequences happen without waiting.
    let backgroundSound = SKAction.playSoundFileNamed("NyanCatSong.mp3", waitForCompletion: false)
    
    
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        //return random() * (max-min) + min
        return CGFloat(arc4random_uniform(UInt32(max - min)) + UInt32(min))
    }
    
    
    var gameArea: CGRect
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //This function loads everytime the scene loads up
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size //this will set the background to the scene size
        background.position = CGPoint(x: self.size.width/2 , y:self.size.height/2)  //this will get us to the center point of the scene
        background.zPosition = 0    //order in layer
        self.addChild(background)   //take the code above and make it!
        
        player.setScale(0.2)  //normal size, if bigger increase the number...each integer is twice as big as original
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)  //this will make the player spawn from 20 percent of the screen
        player.zPosition = 2
        self.addChild(player)
        
        startNewLevel()
        let bgSongSequence = SKAction.sequence([backgroundSound])
        player.run(bgSongSequence)
        
    }
    
    func startNewLevel(){
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: 1.5)
        let SpawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(SpawnSequence)
        self.run(spawnForever)
    }
    
    
    func fireBullet(){
        //spawn bullet
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(0.2)
        bullet.position = player.position
        bullet.zPosition = 1
        self.addChild(bullet)
        
        //moving bullet up
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1) //will take one second to move up the screen
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])  //this takes an array of acions in sequence.
        bullet.run(bulletSequence)
        
    
    }
    
    func spawnEnemy(){
        
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX + player.size.width/2, max: gameArea.maxX - player.size.width/2)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2) //gettting 20 percent of top of screen (beyond visible screen
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)   //this is getting the bottom of the height and then 20 percent lower
        
        let enemy = SKSpriteNode(imageNamed: "TacNayn")
        enemy.setScale(0.5)
        enemy.position = startPoint
        enemy.zPosition = 2
        self.addChild(enemy)
        let moveEnemy = SKAction.move(to: endPoint, duration: 3) // seconds
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        enemy.run(enemySequence)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)  //rotation function to see how much to rotate
        enemy.zRotation = amountToRotate
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
            
            if player.position.x > gameArea.maxX - player.size.width/2 - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2 - player.size.width/2
            }
            if player.position.x < gameArea.minX + player.size.width/2 + player.size.width/2 {
                player.position.x = gameArea.minX + player.size.width/2 + player.size.width/2
            }
        }
    }
}
