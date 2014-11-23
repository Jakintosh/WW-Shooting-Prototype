//
//  TutorialScene.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/22/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import SpriteKit

class TutorialScene: SKFuckScene {
    
    // MARK: - properties
    
    // properties
    var lastTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    var targetZoom: CGFloat = 0.0
    var currentZoom: CGFloat = 0.0
    var rotation: Double = 0.0
    var touchLocation: CGPoint?
    var touch: UITouch?
    
    // entities
    var whales = [Whale]()
    let char: Player       = Player()
    var sun: Sun           = Sun()
    let reticle: Reticle   = Reticle()
    let eHUD: EnergyHUD    = EnergyHUD()
    let bg: Background     = Background(sceneWidth: 320.0)
    let railing: Railing   = Railing(sceneWidth: 320.0)
    let water: Water       = Water(sceneWidth: 320.0)
    
    // systems
    let fadeSprite = SKSpriteNode(color: SKColor.whiteColor(), size: CGSize(width: 320, height: 568))
    let camCon: CameraController = CameraController()
    let particleEmitter = EnergyParticleEmitter(num: 500)
    //    let swipeUpGesture: UISwipeGestureRecognizer!
    
    // scene vars
    let areaWidth: CGFloat      = 700.0
    var currentAreaPos: CGFloat = 0.0
    var targetAreaPos: CGFloat  = 0.0
    var currentCameraY: CGFloat = 0.0
    var targetCameraY: CGFloat  = 0.0
    
    // MARK: - initializers
    override init(size: CGSize) {
        super.init(size: size)
        
        //        swipeUpGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        //        swipeUpGesture.numberOfTouchesRequired = 3
        //        swipeUpGesture.direction = .Up
        //        swipeUpGesture.cancelsTouchesInView = false
    }
    
    // MARK: - UIKit
    override func didMoveToView(view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.fadeSprite.alpha = 0.0
        //        view.addGestureRecognizer(swipeUpGesture)
        
        // reset resources
        game.screamManager.reset() // optional values
        game.screamManager.camCon = self.camCon
        game.energyManager.reset()
        game.whaleSpawnManager.reset()
        
        // setup camera
        camCon.zPosition = 0.0
        camCon.setCameraStartingPosition(CGPointMake(0.0, 0.0))
        camCon.disableDebug()
        camCon.connectGestureRecognizers(view)
        self.addChild(camCon)
        
        // setup spawn mgr
        game.whaleSpawnManager.baseNode        = self.water
        game.whaleSpawnManager.particleEmitter = self.particleEmitter
        game.whaleSpawnManager.camCon          = self.camCon
        
        // set positions
        railing.basePosition = CGPoint(x: 0, y: -frame.height/2)
        water.basePosition = CGPoint(x: 0, y: -frame.height/2)
        sun.position = CGPoint(x: 0, y: 130)
        sun.zPosition = -40
        
        let city = SKSpriteNode(imageNamed: "City")
        city.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        city.position = CGPoint(x: 0, y: 125)
        city.zPosition = -35
        
        // add character to railing
        char.zPosition = 1
        char.position.y = 7
        char.animationScale = 0.17
        railing.addChild(char)
        
        // add sun water and background
        water.addChild(sun)
        water.addChild(city)
        camCon.addCameraChild(bg, withZ: -500)
        camCon.addCameraChild(water, withZ: -450)
        
        // add character and railing
        camCon.addCameraChild(railing, withZ: 0)
        
        // add reticle
        camCon.addCameraChild(reticle, withZ: -10)
        camCon.addCameraChild(eHUD, withZ: -11)
        
        camCon.addHUDChild(fadeSprite, withZ: 1000)
    }
    
    //    override func willMoveFromView(view: SKView) {
    //        view.removeGestureRecognizer(swipeUpGesture)
    //    }
    //
    // MARK: - Logic
    override func update(currentTime: CFTimeInterval) {
        // time keeping
        deltaTime = Utilities2D.clamp(currentTime - lastTime, min: 0.0, max: 1.0)
        game.timeManager.update(deltaTime)
        lastTime = currentTime
        
        
        // update reticle/touch
        reticle.update(touchLocation)
        let sceneTouch = convertPoint(reticle.position, fromNode: camCon.rootNode)
        let reticlePos = convertPoint(reticle.targetPosition, fromNode: camCon.rootNode)
        eHUD.update(reticlePos)
        
        // update big entities
        game.whaleSpawnManager.update(sceneTouch, dt: deltaTime)
        char.update(deltaTime)
        
        
        // update camera position
        updateCameraPosition()
        updateCameraZoom()
        
        // update sun/sky
        sun.update()
        bg.update(game.timeManager.currentDecimalTime())
        
        // update particles
        let particleUpdate: (EnergyParticle)->Void = { particle in
            if let coordSys = particle.parent {
                let retPos = self.convertPoint(sceneTouch, toNode: coordSys)
                let distanceSq = Utilities2D.distanceSquaredFromPoint(particle.position, toPoint: retPos)
                if distanceSq < (30*30) {
                    particle.collect()
                }   }   }
        particleEmitter.update(deltaTime)
        if eHUD.currentState == .ZoomedIn { particleEmitter.updateParticles(particleUpdate) }
        
        fadeSprite.alpha = game.screamManager.getFade()
        
        // finally, update all of the camera changes
        camCon.update(deltaTime)
    }
    
    //    func rotation() {
    //        let xData = game.motionManager.accelerometerData.acceleration.x
    //        let yData = game.motionManager.accelerometerData.acceleration.y
    //        let zData = game.motionManager.accelerometerData.acceleration.z
    //        var nextAngle = atan2(yData, xData)
    //        if (nextAngle < 0) { nextAngle += (M_PI * 2.0) }
    //        nextAngle = nextAngle + ((rotation - nextAngle) * 0.01)
    //        rotation = nextAngle
    //        camCon.setRotiation(CGFloat(nextAngle+(M_PI/2.0)))
    //    }
    
    func updateCameraZoom() {
        
        // camera panning
        if let u_touch = touch {
            targetZoom = 1.0
        } else {
            targetZoom = 0.0
        }
        
        currentZoom = Utilities2D.lerpFrom(currentZoom, toNum: targetZoom, atPosition: 0.1)
        
        railing.updateZoom(currentZoom)
        water.updateZoom(currentZoom)
        //        city.updateZoom(currentZoom)
    }
    
    func updateCameraPosition() {
        
        // camera panning
        if let u_touch = touch {
            
            // get X stuff
            let sceneX = u_touch.locationInNode(scene).x
            let limit = frame.width/6.0
            if sceneX > limit {
                let mod: CGFloat = (sceneX-limit)/limit * (sceneX-limit)/limit + 1
                targetAreaPos += mod * 2.0
            } else if sceneX < -limit {
                let mod: CGFloat = (sceneX+limit)/limit * (sceneX+limit)/limit + 1
                targetAreaPos -= mod * 2.0
            }
            
            // get Y stuff
            let sceneY = u_touch.locationInNode(scene).y
            targetCameraY = (sceneY + frame.height/2) * ( areaWidth / frame.width )
            
        } else {
            targetAreaPos = 0.0
            targetCameraY = 0.0
        }
        
        // clamp it within range
        targetAreaPos = Utilities2D.clamp(targetAreaPos, min: -areaWidth/2, max: areaWidth/2)
        
        // lerp movements
        currentAreaPos = Utilities2D.lerpFrom(currentAreaPos, toNum: targetAreaPos, atPosition: 0.1)
        currentCameraY = Utilities2D.lerpFrom(currentCameraY, toNum: targetCameraY, atPosition: 0.1)
        
        let normalizedX = currentAreaPos / (areaWidth/2.0)
        let normalizedY = currentCameraY / frame.height
        railing.updatePosition(normalizedX, modY: normalizedY)
        water.updatePosition(normalizedX, modY: normalizedY)
        bg.updatePosition(normalizedX, modY: normalizedY)
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
            targetAreaPos = water.convertPoint(touchLocation!, fromNode: camCon.rootNode).x
            
            char.currentState = .Aim
            eHUD.currentState = .ZoomedIn
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
        
        char.currentState = .Idle
        eHUD.currentState = .ZoomedOut
        
        if !game.whaleSpawnManager.isActive {
            game.whaleSpawnManager.isActive = true
            char.getUp()
            water.runAction(SKAction.customActionWithDuration(2.0, actionBlock: { (node, elapsedTime) in
                (node as Water).basePosition.y = (((elapsedTime/2.0)*(elapsedTime/2.0)) * -10.0) - self.frame.height/2.0
            }))
            railing.runAction(SKAction.customActionWithDuration(2.0, actionBlock: { (node, elapsedTime) in
                (node as Railing).basePosition.y = (((elapsedTime/2.0)*(elapsedTime/2.0)) * -15.0) - self.frame.height/2.0
            }))
        }
    }
    //
    //    func handleSwipe(gestureRecognizer: UISwipeGestureRecognizer) {
    //        transitionHome()
    //    }
}
