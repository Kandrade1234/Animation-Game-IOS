//
//  GameScene.swift
//  AnimationGame
//
//  Created by Kevin Andrade on 2/21/19.
//  Copyright © 2019 Kevin Andrade. All rights reserved.
//

import SpriteKit
import GameplayKit
var gameScore = 0//to get access in other scenes...its public

class GameScene: SKScene, SKPhysicsContactDelegate {
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    var levelNumber = 0
    var livesNumber = 3
    let livesLabel = SKLabelNode (fontNamed: "The Bold Font")
    enum gameState{
        case preGame        //before game
        case inGame         //during game
        case afterGame      //after game
    }
    var currentGameState = gameState.preGame
    
    struct PhysicsCategories{
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 //binary 1
        static let Bullet : UInt32 = 0b10 //binary 2
        static let Enemy : UInt32 = 0b100 //binary 4
    }
    
    let player = SKSpriteNode(imageNamed: "NyanCat")
    let bulletSound = SKAction.playSoundFileNamed("sound_spark_Laser-Like_Synth_Laser_Noise_Blast_Oneshot_03.mp3", waitForCompletion: false)    //so it starts playing and following sequences happen without waiting.
    let explosionSound = SKAction.playSoundFileNamed("ExplosionSFX.mp3", waitForCompletion: false)
    var backgroundMusic: SKAudioNode!
    let tapStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    let runKey = "RemoveKey"

    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        //return random() * (max-min) + min
        return CGFloat(arc4random_uniform(UInt32(max - min)) + UInt32(min))
    }
    
    
    var gameArea: CGRect
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 19.5/9.0
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
        gameScore = 0
        self.physicsWorld.contactDelegate = self //now we can use physic contacts in our scene
       
        //making two backgrounds to scrolling effect
        for i in 0...1{
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size //this will set the background to the scene size
            background.anchorPoint = CGPoint(x:0.5, y:0)
            background.position = CGPoint(x: self.size.width/2 , y:self.size.height*CGFloat(i))  //this will get us a  background under screen and another on screen
            background.zPosition = 0    //order in layer
            background.name = "Background"
            self.addChild(background)   //take the code above and make it!
        }
        player.setScale(0.2)  //normal size, if bigger increase the number...each integer is twice as big as original
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)  //this will make the player spawn at a certain percentage of screen
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false   //so gravity does not affect our player
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy    //contact with enemy
        self.addChild(player)
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.zRotation = .pi/2
        scoreLabel.position = CGPoint(x: self.size.width * 0.25, y: self.size.height  - scoreLabel.frame.size.height)
        scoreLabel.zPosition = 20
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontColor = SKColor.white
        livesLabel.fontSize = 70
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        livesLabel.zRotation = .pi/2
        livesLabel.position = CGPoint(x: self.size.width * 0.25, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 20
        self.addChild(livesLabel)
        let moveOnToScreenScore = SKAction.moveTo(y: self.size.height * 0.05, duration: 0.3)
        let moveOnToScreenLives = SKAction.moveTo(y: self.size.height * 0.80, duration: 0.3)
        
        scoreLabel.run(moveOnToScreenScore)
        livesLabel.run(moveOnToScreenLives)
        
        
        tapStartLabel.text = "Tap To Begin"
        tapStartLabel.fontSize = 100
        tapStartLabel.fontColor = SKColor.white
        tapStartLabel.zPosition = 1
        tapStartLabel.position =  CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.48)
        tapStartLabel.zRotation = .pi/2
        tapStartLabel.alpha = 0 //transparent 0 is seethrough, 1 normal
        self.addChild(tapStartLabel)
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapStartLabel.run(fadeInAction)
        
        
       
    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 400.00
    
    //runs once per game frame
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        }
        else{
            deltaFrameTime = currentTime - lastUpdateTime   //the difference of time
            lastUpdateTime = currentTime
        }
        let amountToMoveBG = amountToMovePerSecond * CGFloat(deltaFrameTime)    //how much to move each background
        self.enumerateChildNodes(withName: "Background"){
            background, stop in
            if self.currentGameState == gameState.inGame{
                background.position.y -= amountToMoveBG
            }
            if background.position.y < -self.size.height{
                background.position.y += self.size.height * 2
            }
        }
    }
    
    func startGame(){
        if let musicURL = Bundle.main.url(forResource: "NyanCatSong", withExtension: "mp3"){
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
        //label that deletes
        currentGameState = gameState.inGame
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapStartLabel.run(deleteSequence)
        
        //moves ship on screen
        let moveShipOnToScreen = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOnToScreen, startLevelAction])
        player.run(startGameSequence)
    }
    func loseALife(){
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let changeColor = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 0)
        let returnColor = SKAction.colorize(with: UIColor.white, colorBlendFactor: 1, duration: 0)
        let scaleSequence = SKAction.sequence([changeColor, scaleUp, scaleDown, returnColor])
        livesLabel.run(scaleSequence)
        if livesNumber == 0{
            runGameOver()
        }
    }
    func addScore(){
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50{
            startNewLevel()
        }
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
            runGameOver()
            
        }
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy {
            //if bullet hit enemy body1 == bullet, body2 == enemy
            if body2.node != nil{
                if body2.node!.position.y > self.size.height{
                    return
                }
                else {
                    addScore()
                    spawnExplosion(spawnPosition:body2.node!.position)//passes position to spawn explotion node
                }
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
    func runGameOver(){
        currentGameState = gameState.afterGame
        backgroundMusic.run(SKAction.stop())
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)   //waits for 1 second
        let changeSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSequence)
    }
    
    func changeScene(){
        let sceneToMove = GameOverScene(size: self.size)    //changing to gameOverScene
        sceneToMove.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMove, transition: myTransition)  //changing to another scene with a fade effect
        
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
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil{   //if running then stop it (if spawningenemies does not equal nothing then stop it)
            self.removeAction(forKey: "spawningEnemies")
        }
        var levelDuration = TimeInterval()
        
        switch levelNumber{
            case 1: levelDuration = 1.5
            case 2: do {
                levelDuration = 1.0
                self.amountToMovePerSecond = 700.00
            }
            case 3: do{
                levelDuration = 0.5
                self.amountToMovePerSecond = 900.00

            }
            case 4: do{
                levelDuration = 0.2
                self.amountToMovePerSecond = 1200.00
            }
            default:
                levelDuration = 0.5
                print("No level info")
        }
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let SpawnSequence = SKAction.sequence([ waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(SpawnSequence)
        self.run(spawnForever, withKey:"spawningEnemies")
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
        bullet.name = "Bullet"
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
        enemy.name = "Enemy"
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
        let loseALifeAction = SKAction.run(loseALife)   //if enemy passes by screen then you loose a life
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
        }
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)  //rotation function to see how much to rotate
        enemy.zRotation = amountToRotate
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeAction(forKey: runKey)
        if currentGameState == gameState.preGame{
            startGame()
        }
        else if currentGameState == gameState.inGame{
            fireBulletDuration()
        }
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
            if currentGameState == gameState.inGame{
                player.position.x += amountDragged
            }
            if player.position.x > gameArea.maxX - player.size.width/2 - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2 - player.size.width/2
            }
            if player.position.x < gameArea.minX + player.size.width/2 + player.size.width/2 {
                player.position.x = gameArea.minX + player.size.width/2 + player.size.width/2
            }
        }
    }
    
}
