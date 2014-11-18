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
    let bg: Background     = Background(sceneWidth: 320.0)
    let railing: Railing   = Railing(sceneWidth: 320.0)
    let water: Water       = Water(sceneWidth: 320.0)
    
    // systems
    let camCon: CameraController = CameraController()
    let swipeUpGesture: UISwipeGestureRecognizer!
    let particleEmitter = EnergyParticleEmitter(num: 500)
    
    // scene vars
    let areaWidth: CGFloat = 700.0
    var currentAreaPos: CGFloat = 0.0
    var targetAreaPos: CGFloat = 0.0
    
    // MARK: - initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        swipeUpGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        swipeUpGesture.numberOfTouchesRequired = 3
        swipeUpGesture.direction = .Up
        swipeUpGesture.cancelsTouchesInView = false
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        swipeUpGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        swipeUpGesture.numberOfTouchesRequired = 3
        swipeUpGesture.direction = .Up
        swipeUpGesture.cancelsTouchesInView = false
    }
    
    // MARK: - UIKit
    override func didMoveToView(view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.addGestureRecognizer(swipeUpGesture)
        
        // setup camera
        camCon.zPosition = 0.0
        camCon.setCameraStartingPosition(CGPointMake(0.0, 0.0))
        camCon.disableDebug()
        camCon.connectGestureRecognizers(view)
        self.addChild(camCon)

        // set positions
        railing.position = CGPoint(x: 0, y: -frame.height/2)
        water.position = CGPoint(x: 0, y: -frame.height/2)
        
        // add character to railing
        char.zPosition = 1
        railing.addChild(char)
        
        // add sun water and background
        camCon.addCameraChild(bg, withZ: -500)
        camCon.addCameraChild(sun, withZ: -490)
        camCon.addCameraChild(water, withZ: -480)
        
        // add character and railing
        camCon.addCameraChild(railing, withZ: 0)
        
        // add reticle
        camCon.addCameraChild(reticle, withZ: 100)
        
        // run actions
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock({self.addWhale(position: CGPoint(x: -250, y: -225), mirrored: false)}), SKAction.waitForDuration(10)])))
    }
    
    override func willMoveFromView(view: SKView) {
        view.removeGestureRecognizer(swipeUpGesture)
    }
    
    // MARK: - Logic
    override func update(currentTime: CFTimeInterval) {
        // time keeping
        deltaTime = Utilities2D.clamp(currentTime - lastTime, min: 0.0, max: 1.0)
        game.timeManager.update(deltaTime)
        lastTime = currentTime
        
        // update reticle
        reticle.update(touchLocation)
        let sceneTouch = convertPoint(reticle.position, fromNode: camCon.rootNode)
        for whale in whales {
            whale.update(sceneTouch, dt: deltaTime)
        }
        
        // update sun position
        sun.update()
        
        // update sky shader
        bg.update(game.timeManager.currentDecimalTime())
        
        // update camera position
        updateCameraPosition()
        updateCameraZoom()
        
        // update particles
        let particleUpdate: (EnergyParticle)->Void = { particle in
            if let coordSys = particle.parent {
                let retPos = self.convertPoint(sceneTouch, toNode: coordSys)
                let distanceSq = Utilities2D.distanceSquaredFromPoint(particle.position, toPoint: retPos)
                if distanceSq < (30*30) {
                    particle.remove()
        }   }   }
        particleEmitter.update(deltaTime)
        if !reticle.hidden { particleEmitter.updateParticles(particleUpdate) }
        
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
        
    }
    
    func updateCameraPosition() {
        
        // camera panning
        if let u_touch = touch {
            let sceneX = u_touch.locationInNode(scene).x
            let limit = frame.width/6.0
            if sceneX > limit {
                let mod: CGFloat = (sceneX-limit)/limit * (sceneX-limit)/limit + 1
                targetAreaPos += mod * 2.0
            } else if sceneX < -limit {
                let mod: CGFloat = (sceneX+limit)/limit * (sceneX+limit)/limit + 1
                targetAreaPos -= mod * 2.0
            }
        } else {
            targetAreaPos = 0.0
        }
        
        // clamp it within range
        targetAreaPos = Utilities2D.clamp(targetAreaPos, min: -areaWidth/2, max: areaWidth/2)
        currentAreaPos = Utilities2D.lerpFrom(currentAreaPos, toNum: targetAreaPos, atPosition: 0.1)
        
        let normalized = currentAreaPos/(areaWidth/2.0)
        railing.updatePosition(normalized)
        water.updatePosition(normalized)
        bg.updatePosition(normalized)
        
//      camCon.setCameraPosition(CGPoint(x:areaPos, y:0.0))
    }
    
    func addWhale(position pos: CGPoint, mirrored: Bool) {
        
        let orca = true
        
        if orca {
            let onDeath: (pos: CGPoint) -> Void = { pos in self.particleEmitter.addToQueue(200, pos: pos, root: self.water) }
            let ss: (CGFloat, NSTimeInterval)->Void = { (intensity, duration) in self.camCon.shake(intensity, duration: duration) }
            
            let newWhale = Orca(onDeath: onDeath, ss)
            newWhale.zPosition = 1
            water.addChild(newWhale)
            whales += [newWhale]
            
            newWhale.position = pos
            newWhale.mirror(mirrored)
            newWhale.jump()
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
            targetAreaPos = water.convertPoint(touchLocation!, fromNode: camCon.rootNode).x
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
//            whale.disengage()
        }
    }
    
    func handleSwipe(gestureRecognizer: UISwipeGestureRecognizer) {
//        transitionHome()
        camCon.shake(20.0, duration: 2.0)
    }
}
