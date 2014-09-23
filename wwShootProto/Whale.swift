//
//  Whale.swift
//  wwShootProto
//
//  Created by Jak Tiano on 9/21/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class EnergyWell {
    
    enum EnergyWellActivation {
        case NoPower, HalfPower, FullPower
    }
    
    let well: SKShapeNode
    let fillMeter: SKShapeNode
    let lockOn: Float = 7
    var filled: Bool = true
    var lockFill: Float = 0
    var fillPath: UIBezierPath = UIBezierPath()
    var activationLevel: EnergyWellActivation = .NoPower
    
    init() {
        well = SKShapeNode(circleOfRadius: 20)
        well.strokeColor = SKColor.orangeColor()
        well.fillColor = SKColor.clearColor()
        well.lineWidth = 6
        
        fillMeter = SKShapeNode()
        fillMeter.strokeColor = SKColor.whiteColor()
        fillMeter.fillColor = SKColor.clearColor()
        fillMeter.lineWidth = 3
        
        fillPath.moveToPoint(CGPointMake(0, 25))
    }
    
    func updateProgress() {
        
        if filled {
            
            switch(activationLevel) {
                
            case .NoPower:
                lockFill -= 0.05
                
            case .HalfPower:
                lockFill += 0
                
            case .FullPower:
                lockFill += 0.05
                
            }
            
            if lockFill < 0 { lockFill = 0 }
            if lockFill > lockOn { lockFill = lockOn; burst() }
            
            var mod: Float = lockFill/lockOn
            mod *= Float(2*M_PI)
            mod = Float(M_PI/2) - mod
            
            fillPath.removeAllPoints()
            fillPath.addArcWithCenter(CGPointMake(CGFloat(0), CGFloat(0)),
                radius: CGFloat(25),
                startAngle: CGFloat(M_PI/2),
                endAngle: CGFloat(mod),
                clockwise: false)
            
            fillMeter.path = nil
            fillMeter.path = fillPath.CGPath
        }
    }
    
    func activate(#activation: EnergyWellActivation) {
        if filled {
            switch (activation) {
            case .NoPower:
                activationLevel = .NoPower
                well.strokeColor = SKColor.orangeColor()
                well.fillColor = SKColor.clearColor()
            case .HalfPower:
                activationLevel = .HalfPower
                well.strokeColor = SKColor.greenColor()
                well.fillColor = SKColor.clearColor()
            case .FullPower:
                activationLevel = .FullPower
                well.strokeColor = SKColor.greenColor()
                well.fillColor = SKColor.greenColor()
            }
        }
    }
    
    func setPosition(#pos: CGPoint) {
        well.position = pos
        fillMeter.position = pos
    }
    
    func burst() {
        var emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(imageNamed: "bokeh")
        emitter.particleColor = SKColor.greenColor()
        emitter.particleBirthRate = 400
        emitter.particleLifetime = 9999999
        emitter.particleScale = 0.1
        emitter.particleScaleSpeed = 0.2
        emitter.particleScaleRange = 0.2
        emitter.particleAlpha = 0.5
        emitter.xAcceleration = -200
        emitter.yAcceleration = -200
        emitter.targetNode = well.scene!
        emitter.numParticlesToEmit = 100
        emitter.emissionAngleRange = 360
        emitter.particleSpeed = 300
        emitter.particleSpeedRange = 100
        emitter.particleBlendMode = SKBlendMode.Add
        well.addChild(emitter)
        
        filled = false
        activationLevel = .NoPower
        well.strokeColor = SKColor.grayColor()
        well.fillColor = SKColor.clearColor()
    }
    
}

class Whale : SKSpriteNode {
    
    var weakSpots = [EnergyWell]()
    var moveSpeed: Float = 7
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        addWeakPoint(position: CGPointMake(-20, 50))
    }
    convenience override init() {
        self.init(texture: SKTexture(imageNamed: "whale"), color: SKColor.whiteColor(), size: SKTexture(imageNamed: "whale").size())
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(#touchPos: CGPoint?) {
        if let theScene = scene {
            if let u_touchPos = touchPos {
                let touchInWhaleSpace = theScene.convertPoint(u_touchPos, toNode: self)
                for ws in weakSpots {
                    let a = touchInWhaleSpace.x - ws.well.position.x
                    let b = touchInWhaleSpace.y - ws.well.position.y
                    let distSq = (a*a)+(b*b)
    //                println("input touch = \(touchPos) and converted touch = \(touchInWhaleSpace)")
                    if distSq < (20*20) {
                        ws.activate(activation: .FullPower)
                    } else if distSq < (40*40) {
                        ws.activate(activation: .HalfPower)
                    } else {
                        ws.activate(activation: .NoPower)
                    }
                }
            }
        }
        for ws in weakSpots {
            ws.updateProgress()
        }
    }
    
    func addWeakPoint(position pos: CGPoint) {
        let newWeakPoint = EnergyWell()
        newWeakPoint.setPosition(pos: pos)
        newWeakPoint.well.zPosition = zPosition + 1
        newWeakPoint.fillMeter.zPosition = zPosition + 1
        addChild(newWeakPoint.fillMeter)
        addChild(newWeakPoint.well)
        
        weakSpots += [newWeakPoint]
    }
    
    func move() {
        if let theScene = scene {
            let rotate = SKAction.rotateByAngle(-CGFloat(M_PI_2), duration: NSTimeInterval(moveSpeed))
            let moveX = SKAction.moveByX(theScene.size.width - 2*size.width, y: 0, duration: NSTimeInterval(moveSpeed))
            let moveUp = SKAction.moveByX(0, y: 500, duration: NSTimeInterval(moveSpeed)/2)
            let moveDown = moveUp.reversedAction()
            moveUp.timingMode = .EaseOut
            moveDown.timingMode = .EaseIn
            
            let die = SKAction.runBlock({ () -> Void in
                (self.scene! as GameScene).removeWhale(whale: self)
                self.removeFromParent()
                self.removeAllActions()
                self.removeAllChildren()
            })
            
            runAction(SKAction.group([rotate, moveX, SKAction.sequence([moveUp, moveDown, die])]))
        }
    }
    
    func disengage() {
        for ws in weakSpots {
            ws.activate(activation: .NoPower)
        }
    }

}