//
//  GameScene.swift
//  AnimationGame
//
//  Created by Kevin Andrade on 2/21/19.
//  Copyright © 2019 Kevin Andrade. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    struct PhysicsCategories{
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 //binary 1
        static let Bullet : UInt32 = 0b10 //binary 2
        static let Enemy : UInt32 = 0b100 //binary 4
    }
    
    let player = SKSpriteNode(imageNamed: "NyanCat")
    let bulletSound = SKAction.playSoundFileNamed("sound_spark_Laser-Like_Synth_Laser_Noise_Blast_Oneshot_03.mp3", waitForCompletion: false)    //so it starts playing and following sequences happen without waiting.
    let explosionSound = SKAction.playSoundFileNamed("ExplosionSFX.mp3", waitForCompletion: false)
    let backgroundSound = SKAction.playSoundFileNamed("NyanCatSong.mp3", waitForCompletion: false)
    
    
    let runKey = "RemoveKey"

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
        self.physicsWorld.contactDelegate = self //now we can use physic contacts in our scene
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size //this will set the background to the scene size
        background.position = CGPoint(x: self.size.width/2 , y:self.size.height/2)  //this will get us to the center point of the scene
        background.zPosition = 0    //order in layer
        self.addChild(background)   //take the code above and make it!
        
        player.setScale(0.2)  //normal size, if bigger increase the number...each integer is twice as big as original
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)  //this will make the player spawn from 20 percent of the screen
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false   //so gravity does not affect our player
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy    //contact with enemy
        self.addChild(player)
        
        startNewLevel()
        let bgSongSequence = SKAction.sequence([backgroundSound])
        self.run(bgSongSequence)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {    //contact carries two bodys....body A and body B
       /*
            Player = 1
            Bullet = 2
            Enemy = 4
        */
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{   //ordering the bitmasks so we know which is less than the other
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{
            //if player hit enemy
            
            if body1.node != nil{
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            if body2.node != nil{
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
        }
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy {
            //if bullet hit enemy body1 == bullet, body2 == enemy
            if body2.node != nil{
                if body2.node!.position.y > self.size.height{
                    return
                }
                else {
                    spawnExplosion(spawnPosition:body2.node!.position)//passes position to spawn explotion node
                }
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
        }
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        let scaleIn = SKAction.scale(to: 0.3, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    
    
    
    func startNewLevel(){
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: 1.5)
        let SpawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(SpawnSequence)
        self.run(spawnForever)
    }
    
    func fireBulletDuration(){
        let spawn = SKAction.run(fireBullet)
        let waitToSpawn = SKAction.wait(forDuration: 0.3)
        let SpawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(SpawnSequence)
        self.run(spawnForever, withKey:runKey)
        
    }
    func fireBullet(){
        //spawn bullet
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(0.2)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy    //hitting enemy contact
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
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet //if contact with player or bullet let us know
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
        self.removeAction(forKey: runKey)
        fireBulletDuration()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeAction(forKey: runKey)
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
