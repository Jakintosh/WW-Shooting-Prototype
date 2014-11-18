//
//  Whale.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/16/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class Whale : NHCNode {
    
    enum WhaleAngerState {
        case White, Yellow, Red
    }
    
    // components
    let animationNode   = NHCNode()
    let exposedNode     = NHCNode()
    let lockOnNode      = NHCNode()
    
    let animatorKey: String
    var animator: AnimatableEntity!
    
    var lockOnWell: EnergyWell!
    var exposedWells: [EnergyWell] = [EnergyWell]()
    
    // closures
    let onDeath: (pos: CGPoint) -> Void
    let screenShake: (intensity: CGFloat, duration: NSTimeInterval)->Void
    
    // properties
    var angerState: WhaleAngerState  = .White
    var isAlive: Bool    = true
    var isMirrored: Bool = false
    
    // initialization
    init(onDeath: (CGPoint) -> Void, ss: (CGFloat, NSTimeInterval)->Void, animatorKey: String) {
        self.onDeath = onDeath
        self.screenShake = ss
        self.animatorKey = animatorKey
        
        super.init()
        
        animator = game.animationManager.registerEntity(animatorKey, owner: self)
        
        setupAnimationNode()
        setupExposedNode()
        setupLockOnNode()
        
        addChild(animationNode)
        addChild(exposedNode)
        addChild(lockOnNode)
        
        exposedNode.hidden = true
        lockOnNode.hidden = true
    }
    func setupAnimationNode() {}
    func setupExposedNode() {}
    func setupLockOnNode() {}
    
    // MARK: Animation
    func setSpine(spineKey: String, animKey: String) {
        animationNode.removeAllChildren()
        
        game.animationManager.setSpineForEntity(spineKey, entityKey: animatorKey)
        animator.setupSpine(animKey, introPeriod: 0.1)
        
        if let spineNode = animator.animationSpine {
            animationNode.addChild(spineNode)
        }
    }
    
    // updates
    func update(scenePos: CGPoint, dt: CFTimeInterval) {
        updateAnimationNode(dt)
        if !exposedNode.hidden { updateExposedNode(scenePos, dt: dt) }
        if !lockOnNode.hidden  { updateLockOnNode(scenePos, dt: dt) }
    }
    func updateAnimationNode(dt: CFTimeInterval) {
        animator.update(dt)
    }
    func updateExposedNode(scenePos: CGPoint, dt: CFTimeInterval) {
        var numFinished = 0
        for well in exposedWells {
            if well.activated {
                well.update(scenePos, dt: dt)
                if well.lockedOn {
                    well.burst()
                    screenShake(intensity: 5, duration: 0.25)
                    numFinished++
                }
            } else {
                numFinished++
            }
        }
        if isAlive {
            if numFinished >= exposedWells.count {
                kill()
            }
        }
    }
    func updateLockOnNode(scenePos: CGPoint, dt: CFTimeInterval) {
        lockOnWell.update(scenePos, dt: dt)
        if lockOnWell.lockedOn {
            stun()
            screenShake(intensity: 10, duration: 0.33)
        }
    }
    
    // methods
    func mirror(m: Bool) {
        isMirrored = m
        if m { xScale = -1 } else { xScale = 1 }
    }
    func jump() {}
    func stun() {}
    func kill() {
//        self.onDeath(pos: self.position)
        runAction(SKAction.waitForDuration(1.0), completion: {
            self.remove()
        })
    }
    func remove() {
        isAlive = false
        self.animator.removeSpine()
        self.removeFromParent()
        self.removeAllChildren()
    }
}

class Orca : Whale {
    
    // properties
    var jumpAction: SKAction
    var explosionSound: SKAction
    
    struct Stored {
        static var instanceNum: Int = 0
    }
    
    init(onDeath: (CGPoint) -> Void, ss: (CGFloat, NSTimeInterval)->Void) {
        // setup SKActions
        
        // .3333 into max jump, 4.1666, 0.5
        let animLength: NSTimeInterval = 5.0
        let horizontalMove = SKAction.sequence([
            SKAction.moveByX(100, y: 0, duration: 0.3333),
            SKAction.moveByX(300, y: 0, duration: 4.1666),
            SKAction.moveByX(150, y: 0, duration: 0.5000) ])
        horizontalMove.timingMode = .EaseInEaseOut
        let up = SKAction.moveByX(0, y: 550, duration: 1.0)
        let down = up.reversedAction()
        up.timingMode = .EaseInEaseOut
        down.timingMode = .EaseIn
        let verticalMovement = SKAction.sequence([up, SKAction.waitForDuration(3.0), down])
        let rotate = SKAction.sequence([
            SKAction.rotateByAngle(CGFloat(M_PI * -0.25), duration: 1.25),
            SKAction.rotateByAngle(CGFloat(M_PI * -0.16), duration: 2.50),
            SKAction.rotateByAngle(CGFloat(M_PI * -0.25), duration: 1.25)])
        
        jumpAction = SKAction.group([ horizontalMove, verticalMovement, rotate ])
        jumpAction.timingMode = .EaseInEaseOut
        explosionSound = SKAction.playSoundFileNamed("whale_explosion.caf", waitForCompletion: false)
        
        // set up key
        let key = "whale_orca\(Stored.instanceNum)"
        Stored.instanceNum++
        
        super.init(onDeath: onDeath, ss: ss, animatorKey: key)
    }
    override func setupAnimationNode() {
        animationNode.xScale = 0.5
        animationNode.yScale = 0.5
        setSpine("spine_whale_orca_default", animKey: "jump_normal")
    }
    override func setupExposedNode() {
        let well1 = EnergyWell(radius: 25.0, duration: 0.6)
        let well2 = EnergyWell(radius: 20.0, duration: 0.4)
        let well3 = EnergyWell(radius: 15.0, duration: 0.2)
        
        well1.position = CGPoint(x:  10.0, y:  20.0)
        well2.position = CGPoint(x: -45.0, y:   0.0)
        well3.position = CGPoint(x: -75.0, y: -40.0)
        
        exposedWells += [well1, well2, well3]
        
        exposedNode.addChild(well1)
        exposedNode.addChild(well2)
        exposedNode.addChild(well3)
        exposedNode.zPosition = 1
    }
    override func setupLockOnNode() {
        lockOnWell = EnergyWell(radius: 20.0, duration: 1.0)
        lockOnWell.position = CGPoint(x: 0, y: 0)
        
        lockOnNode.addChild(lockOnWell)
        lockOnNode.zPosition = 1
    }
    
    
    override func update(scenePos: CGPoint, dt: CFTimeInterval) {
        super.update(scenePos, dt: dt)
    }
    override func updateAnimationNode(dt: CFTimeInterval) {
        super.updateAnimationNode(dt)
        // spine.activateAnimations()
    }
    override func updateExposedNode(scenePos: CGPoint, dt: CFTimeInterval) {
        super.updateExposedNode(scenePos, dt: dt)
    }
    override func updateLockOnNode(scenePos: CGPoint, dt: CFTimeInterval) {
        super.updateLockOnNode(scenePos, dt: dt)
    }
    
    
    override func jump() {
        super.jump()
        runAction(jumpAction, completion: { self.kill() })
        lockOnNode.hidden = false
        animator.playAnimation("jump_normal", introPeriod: 0.1)
    }
    override func stun() {
        super.stun()
        lockOnNode.hidden = true
        exposedNode.hidden = false
    }
    override func kill() {
        super.kill()
        runAction(SKAction.waitForDuration(0.5), completion: {
            self.onDeath(pos: self.position)
            self.screenShake(intensity: 15, duration: 0.5)
            self.runAction(self.explosionSound)
        })
    }
}

class EnergyWell : NHCNode {
    
    enum EnergyWellActivation {
        case NoPower, HalfPower, FullPower
    }
    
    // components
    let well: SKShapeNode       = SKShapeNode()
    let fillMeter: SKShapeNode  = SKShapeNode()
    var fillPath: UIBezierPath  = UIBezierPath()
    
    // properties
    var activationLevel: EnergyWellActivation = .NoPower
    var activated: Bool         = true
    var lockDuration: CGFloat   = 2.0
    var lockProgress: CGFloat   = 0.0
    var lockedOn: Bool          = false
    var lockOnRadius: CGFloat   = 10.0
    
    init(radius: CGFloat, duration: CGFloat) {
        super.init()
        
        lockOnRadius = radius
        lockDuration = duration
        
        // set up well
        setupWell()
        
        // set up fill meter
        setupFillMeter()
    }
    
    func setupWell() {
        let rad = lockOnRadius - 3.0
        let diameter = rad * 2.0
        well.path = CGPathCreateWithEllipseInRect(CGRectMake(-rad, -rad, diameter, diameter), nil)
        well.strokeColor = SKColor.orangeColor()
        well.fillColor = SKColor.clearColor()
        well.lineWidth = 3
        addChild(well)
    }
    
    func setupFillMeter() {
        fillMeter.strokeColor = SKColor.whiteColor()
        fillMeter.fillColor = SKColor.clearColor()
        fillMeter.lineWidth = 3
        fillPath.moveToPoint(CGPointMake(0, lockOnRadius))
        addChild(fillMeter)
    }
    
    func update( sceneTouch: CGPoint, dt: CFTimeInterval ) {
        if activated {
            if let u_scene = scene {
                let touchPos = u_scene.convertPoint(sceneTouch, toNode: self)
                let distance = Utilities2D.distanceFromPoint(CGPointZero, toPoint: touchPos)
                if distance < lockOnRadius {
                    activate(activation: .FullPower)
                } else if distance < lockOnRadius * 1.2 {
                    activate(activation: .HalfPower)
                } else {
                    activate(activation: .NoPower)
                }
                
                updateProgress(dt)
            }
        }
    }
    
    func updateProgress(dt: CFTimeInterval) {
        // update activity based on activation
        switch(activationLevel)
        {
            case .NoPower:
                lockProgress -= CGFloat(dt/2.0)
                
            case .HalfPower:
                lockProgress += CGFloat(dt/3.0)
                
            case .FullPower:
                lockProgress += CGFloat(dt)
        }
        
        // clamp results
        lockProgress = Utilities2D.clamp(lockProgress, min: 0.0, max: lockDuration)
        
        if lockProgress <= 0.0 {
            fillMeter.hidden = true
        } else {
            fillMeter.hidden = false
        }
        
        if lockProgress >= lockDuration {
            lockedOn = true
        }
        
        // draw circle
        var mod: CGFloat = lockProgress/lockDuration
        mod *= 2.0 * CGFloat(M_PI)
        mod = CGFloat(M_PI)/2.0 - mod
        fillPath.removeAllPoints()
        fillPath.addArcWithCenter(  CGPointMake(0.0, 0.0),
            radius: 25.0,
            startAngle: CGFloat(M_PI/2.0),
            endAngle: CGFloat(mod),
            clockwise: false )
        fillMeter.path = nil
        fillMeter.path = fillPath.CGPath
    }
    
    func activate(#activation: EnergyWellActivation) {
        switch (activation)
        {
            case .NoPower:
                activationLevel = .NoPower
                well.strokeColor = SKColor.orangeColor()
                well.fillColor = SKColor.clearColor()
            case .HalfPower:
                activationLevel = .HalfPower
                well.strokeColor = SKColor.greenColor()
                well.fillColor = SKColor(red: 0, green: 1, blue: 0, alpha: 0.5)
            case .FullPower:
                activationLevel = .FullPower
                well.strokeColor = SKColor.greenColor()
                well.fillColor = SKColor.greenColor()
        }
    }
    
    func burst() {
        activated = false
        activationLevel = .NoPower
        fillMeter.runAction(SKAction.fadeOutWithDuration(0.5))
        well.strokeColor = SKColor.grayColor()
        well.fillColor = SKColor.clearColor()
    }
    
}