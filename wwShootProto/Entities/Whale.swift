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
    
    var lockOnWell: EnergyWell!
    var exposedWells: [EnergyWell] = [EnergyWell]()
    
    // properties
    var angerState: WhaleAngerState = .White
    
    // initialization
    override init() {
        super.init()
        
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
    
    // updates
    func update(scenePos: CGPoint, dt: CFTimeInterval) {
        updateAnimationNode()
        if !exposedNode.hidden { updateExposedNode(scenePos, dt: dt) }
        if !lockOnNode.hidden  { updateLockOnNode(scenePos, dt: dt) }
    }
    func updateAnimationNode() {}
    func updateExposedNode(scenePos: CGPoint, dt: CFTimeInterval) {
        var numFinished = 0
        for well in exposedWells {
            if well.activated {
                well.update(scenePos, dt: dt)
                if well.lockedOn {
                    well.burst()
                    numFinished++
                }
            } else {
                numFinished++
            }
        }
        if numFinished >= exposedWells.count {
            kill()
        }
    }
    func updateLockOnNode(scenePos: CGPoint, dt: CFTimeInterval) {
        lockOnWell.update(scenePos, dt: dt)
        if lockOnWell.lockedOn {
            stun()
        }
    }
    
    // methods
    func jump() {}
    func stun() {}
    func kill() {}
}

class Orca : Whale {
    
    // properties
    var jumpAction: SKAction
    var explosionSound: SKAction
    
    override init() {
        jumpAction = SKAction.moveByX(0.0, y: 400, duration: 4.0)
        jumpAction.timingMode = .EaseOut
        
        explosionSound = SKAction.playSoundFileNamed("whale_explosion.caf", waitForCompletion: false)
        
        super.init()
    }
    override func setupAnimationNode() {
        let sprite = SKSpriteNode(imageNamed: "whale")
        animationNode.addChild(sprite)
    }
    override func setupExposedNode() {
        let well1 = EnergyWell(radius: 25.0, duration: 0.6)
        let well2 = EnergyWell(radius: 20.0, duration: 0.4)
        let well3 = EnergyWell(radius: 15.0, duration: 0.2)
        
        well1.position = CGPoint(x:  30.0, y:  70.0)
        well2.position = CGPoint(x: -25.0, y:  50.0)
        well3.position = CGPoint(x: -55.0, y:  10.0)
        
        exposedWells += [well1, well2, well3]
        
        exposedNode.addChild(well1)
        exposedNode.addChild(well2)
        exposedNode.addChild(well3)
        exposedNode.zPosition = 1
    }
    override func setupLockOnNode() {
        lockOnWell = EnergyWell(radius: 20.0, duration: 2.0)
        lockOnWell.position = CGPoint(x: -20, y: 50)
        
        lockOnNode.addChild(lockOnWell)
        lockOnNode.zPosition = 1
    }
    
    
    override func update(scenePos: CGPoint, dt: CFTimeInterval) {
        super.update(scenePos, dt: dt)
    }
    override func updateAnimationNode() {
        // spine.activateAnimations()
    }
    override func updateExposedNode(scenePos: CGPoint, dt: CFTimeInterval) {
        super.updateExposedNode(scenePos, dt: dt)
    }
    override func updateLockOnNode(scenePos: CGPoint, dt: CFTimeInterval) {
        super.updateLockOnNode(scenePos, dt: dt)
    }
    
    
    override func jump() {
        runAction(jumpAction)
        lockOnNode.hidden = false
    }
    override func stun() {
        lockOnNode.hidden = true
        exposedNode.hidden = false
    }
    override func kill() {
        runAction(SKAction.waitForDuration(0.5), completion: {
            self.runAction(self.explosionSound)
            self.removeFromParent()
            self.removeAllChildren()
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
            let touchPos = scene!.convertPoint(sceneTouch, toNode: self)
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