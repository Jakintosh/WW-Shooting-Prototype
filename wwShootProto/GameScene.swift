//
//  GameScene.swift
//  wwShootProto
//
//  Created by Jak Tiano on 9/21/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - properties
    
    // properties
    var lastTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    var rotation: Double = 0.0
    
    // components?
    let reticle = SKShapeNode(circleOfRadius: 20)
    let bg: NHCSky
    var whales = [Whale]()
    var touchLocation: CGPoint?
    var touch: UITouch?
    var char: SKSpriteNode
    var sun: SKSpriteNode!
    
    let timeText = SKLabelNode(fontNamed: "HelveticaNeue-Light")
    
    let homeButton = Button(activeImageName: "button_default", defaultImageName: "button_default", action: {})
    let homeText = SKLabelNode(text: "Punch Out")
    
    // garbage
    var moveType: Int = 1
    
    // systems
    var partcleManager: ParticleManager?
    let camCon: CameraController = CameraController()
    let swipeUpGesture: UISwipeGestureRecognizer?
    
    // scene vars
    let areaWidth: Float = 700
    var areaPos: Float = 0
    
    // MARK: - initializers
    required init?(coder aDecoder: NSCoder) {
        char = SKSpriteNode(imageNamed: "idle01")
        bg = NHCSky(color: SKColor.blueColor(), size: CGSize(width: 700, height: 568))
        super.init(coder: aDecoder)
        
        swipeUpGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        swipeUpGesture!.numberOfTouchesRequired = 3
        swipeUpGesture!.direction = .Up
        swipeUpGesture!.cancelsTouchesInView = false
    }
    
    override init(size: CGSize) {
        char = SKSpriteNode(imageNamed: "idle01")
        bg = NHCSky(color: SKColor.blueColor(), size: CGSize(width: 700, height: 568))
        super.init(size: size)
        
        swipeUpGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        swipeUpGesture?.numberOfTouchesRequired = 3
        swipeUpGesture?.direction = .Up
        swipeUpGesture?.cancelsTouchesInView = false
    }
    
    // MARK: - UIKit
    override func didMoveToView(view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.addGestureRecognizer(swipeUpGesture!)
        
        areaPos = areaWidth/2
        
        camCon.zPosition = 0.0
        camCon.setCameraStartingPosition(CGPointMake(CGFloat(areaPos), frame.height/2))
        camCon.disableDebug()
        camCon.connectGestureRecognizers(view)
        self.addChild(camCon)
        
        bg.texture = SKTexture(imageNamed: "Sky")
        bg.position = CGPoint(x: 350, y: 284)
        camCon.addCameraChild(bg, withZ: -5000)
        
        timeText.fontSize = 18.0
        timeText.verticalAlignmentMode = .Top
        timeText.horizontalAlignmentMode = .Right
        timeText.position = CGPoint(x: 138, y: 228)
        camCon.addHUDChild(timeText, withZ: 10)
        
        partcleManager = ParticleManager(cc: camCon, numParticles: 750)
        
        // setup reticle
        reticle.fillColor = SKColor.clearColor()
        reticle.strokeColor = SKColor.redColor()
        reticle.lineWidth = 3
        camCon.addCameraChild(reticle, withZ: 200)
        reticle.hidden = true

        let water = SKSpriteNode(imageNamed: "Water")
        water.anchorPoint = CGPointMake(0.5, 0.0)
        water.position = CGPoint(x: 350, y: 0)
        camCon.addCameraChild(water, withZ: -1)
        
        sun = SKSpriteNode(imageNamed: "Sun")
        sun.position = CGPoint(x: 200, y: 400)
        camCon.addCameraChild(sun, withZ: -100)
        
        let railing = SKSpriteNode(imageNamed: "Balcony")
        railing.anchorPoint = CGPointMake(0.5, 0)
        railing.position = CGPoint(x: 0, y: -frame.height/2)
        railing.name = "rail"
        camCon.addHUDChild(railing, withZ: 0)
        
        char.anchorPoint = CGPoint(x: 0.5, y: 0)
        char.xScale = 2.0
        char.yScale = 2.0
        char.position = CGPoint(x: 0, y: -frame.height/2 - 10)
        camCon.addHUDChild(char, withZ: 1)
        
        homeText.fontSize = 16.0
        homeText.verticalAlignmentMode = .Center
        homeText.horizontalAlignmentMode = .Center
        homeText.zPosition = 1
        homeButton.addChild(homeText)
        
        homeButton.completionAction = {  self.transitionHome() }
        homeButton.hidden = true
        homeButton.position = Utilities2D.addPoint(CGPoint(x: 75, y: 100), toPoint: char.position)
        camCon.addHUDChild(homeButton, withZ: 2)
        
        // run actions
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock({self.addWhale(position: nil)}), SKAction.waitForDuration(10)])))
    }
    
    override func willMoveFromView(view: SKView) {
        view.removeGestureRecognizer(swipeUpGesture!)
    }
    
    // MARK: - Logic
    override func update(currentTime: CFTimeInterval) {
        
        // time keeping
        deltaTime = Utilities2D.clamp(currentTime - lastTime, min: 0.0, max: 1.0)
        game.timeManager.update(deltaTime)
        lastTime = currentTime
        timeText.text = "\(game.timeManager.currentTimeString())"
        
        if game.timeManager.currentHour() >= 17 {
            quittinTime()
        }
        
        // update reticle
        var retPos: CGPoint? = nil
        if let u_touchLocation = touchLocation {
            reticle.hidden = false
            reticle.position = u_touchLocation
            reticle.position.y += 100
            retPos = reticle.position
            for whale in whales {
                whale.update(touchPos: reticle.position, dt: deltaTime)
            }
        } else {
            reticle.hidden = true
            for whale in whales {
                whale.update(touchPos: nil, dt: deltaTime)
            }
        }
        
        sun.position.y = (game.timeManager.currentDecimalTime() * -150.0) + 2700
        println(sun.position.y)
        
        // update camera position
        updateCameraPosition()
        
        // update sky shader
        bg.updateShader(game.timeManager.currentDecimalTime())
        
        // why is the particle system updated like this
        partcleManager?.updateSuction(touchPos: retPos, dt: deltaTime)
        
//        let xData = game.motionManager.accelerometerData.acceleration.x
//        let yData = game.motionManager.accelerometerData.acceleration.y
//        let zData = game.motionManager.accelerometerData.acceleration.z
//        var nextAngle = atan2(yData, xData)
//        if (nextAngle < 0) { nextAngle += (M_PI * 2.0) }
//        nextAngle = nextAngle + ((rotation - nextAngle) * 0.01)
//        rotation = nextAngle
//        camCon.setRotiation(CGFloat(nextAngle+(M_PI/2.0)))
        
        // finally, update all of the camera changes
        camCon.update(deltaTime)
    }
    
    func updateCameraPosition() {
        // camera panning
        if let u_touch = touch {
            touchLocation = u_touch.locationInNode(camCon.rootNode)
            
            let sceneX = u_touch.locationInNode(scene).x
            let limit = frame.width/6
            if sceneX > limit {
                let mod: Float = Float((sceneX-limit)/limit) * Float((sceneX-limit)/limit) + 1
                areaPos += mod
            } else if sceneX < -limit {
                let mod: Float = Float((sceneX+limit)/limit) * Float((sceneX+limit)/limit) + 1
                areaPos -= mod
            }
        }
        if areaPos > areaWidth - Float(frame.width/2) {
            areaPos = areaWidth - Float(frame.width/2)
        }
        if areaPos < Float(frame.width/2) {
            areaPos = Float(frame.width/2)
        }
        camCon.setCameraPosition(CGPoint(x: Double(areaPos), y: Double(frame.height/2)))
    }
    
    func quittinTime() {
        if homeButton.hidden {
            homeButton.hidden = false
        }
    }
    
    func addWhale(position pos: CGPoint?) {
        let newWhale = Whale(partMan: partcleManager!)
        camCon.addCameraChild(newWhale, withZ: 0)
        whales += [newWhale]
        
        if let whalePos = pos {
            newWhale.position = whalePos
        } else {
            newWhale.position.y = frame.size.height/2 - 400
            if arc4random_uniform(2) != 0 {
                newWhale.position.x = CGFloat(areaWidth/2 - 200)
                newWhale.move(moveType, direction: 1)
            } else {
                newWhale.position.x = CGFloat(areaWidth/2 + 200)
                newWhale.move(moveType, direction: -1)
            }
        }
    }
    
    func removeWhale(#whale: Whale) {
        for i in 0..<whales.count {
            if whales[i] === whale {
                whales.removeAtIndex(i)
                return
            }
        }
    }
    
    func transitionHome() {
        
        let transitionDuration = 1.0
        var transition: SKTransition = SKTransition.fadeWithDuration(transitionDuration)
        transition.pausesIncomingScene = false
        transition.pausesOutgoingScene = false
        let homeScene = HomeScene(size: CGSize(width: frame.height, height: frame.width))
        view?.presentScene(homeScene, transition: transition)
        homeScene.runAction(SKAction.sequence([SKAction.waitForDuration(transitionDuration/2.0), SKAction.runBlock({ NSNotificationCenter.defaultCenter().postNotificationName("NHCSWillTransitionToHome", object: nil) })]))
    }
    
    // MARK: - Touch
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            touchLocation = touch.locationInNode(camCon.rootNode)
            self.touch = touch as? UITouch
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            touchLocation = touch.locationInNode(camCon.rootNode)
            self.touch = touch as? UITouch
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        touchLocation = nil
        touch = nil
        
        for whale in whales {
            whale.disengage()
        }
    }
    
    func handleSwipe(gestureRecognizer: UISwipeGestureRecognizer) {
        transitionHome()
//        camCon.shake(20.0, duration: 2.0)
    }
}
