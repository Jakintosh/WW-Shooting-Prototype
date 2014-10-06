//
//  Whale.swift
//  wwShootProto
//
//  Created by Jak Tiano on 9/21/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class CanisterManager {
    
    let dailyQuota: Int
    let energyPerCanister: Int
    var numFullCanisters: Int
    var currentEnergy: Int
    
    
    init() {
        dailyQuota = 8
        energyPerCanister = 500
        numFullCanisters = 0
        currentEnergy = 0
    }
    
    func addEnergy() {
        
        currentEnergy++
        
        if currentEnergy >= energyPerCanister {
            currentEnergy -= energyPerCanister
            numFullCanisters++
        }
    }
    
    func getPercentage() -> Float {
        let percentage = Float(currentEnergy)/Float(energyPerCanister)
        if percentage < 0       { return 0 }
        else if percentage > 1  { return 1 }
        else                    { return percentage }
    }
    
}

class ParticleManager {
    
    let camCon: CameraController
    let canMan: CanisterManager
    
    let canisterLabel: SKLabelNode = SKLabelNode(fontNamed: "HelveticaNeue")
    let canisterBG: SKShapeNode = SKShapeNode(rect: CGRectMake(-140, -16, 280, 32))
    let canisterMeter: SKShapeNode = SKShapeNode(rect: CGRectMake(0, -14, 272, 28))
    
    var particles: [EnergyParticle] = [EnergyParticle]()
    var availableParticles: [Int] = [Int]()
    var numParticles: Int = 0
    
    let innerRange: Double = 20
    let outerRange: Double = 120
    let suckSpeed: Double = 0.5
    
    var queueSize: Int = 0
    var spawnPos: CGPoint = CGPointZero
    var particleSpawn: (EnergyParticle) -> () = {EnergyParticle in}
    
    let maxQueuePerTick: Int = 20
    let spewSpeed: Double = 1000
    
    init(cc: CameraController, numParticles: Int) {
        self.numParticles = numParticles
        self.camCon = cc
        self.canMan = CanisterManager()
        for i in 0..<numParticles {
            let newParticle = EnergyParticle(root: camCon.rootNode, index: i, emitter: self)
            availableParticles += [i]
            particles += [newParticle]
        }
        
        canisterBG.position = CGPointMake(0, 248)
        canisterBG.fillColor = SKColor.blackColor()
        canisterBG.strokeColor = SKColor.clearColor()
        canisterMeter.position = CGPointMake(-138, 248)
        canisterMeter.fillColor = SKColor.greenColor()
        canisterMeter.strokeColor = SKColor.clearColor()
        canisterLabel.position = CGPointMake(-140, 228)
        canisterLabel.text = "\(canMan.numFullCanisters)/\(canMan.dailyQuota)"
        canisterLabel.fontSize = 18.0
        canisterLabel.horizontalAlignmentMode = .Left
        canisterLabel.verticalAlignmentMode = .Top
        camCon.addHUDChild(canisterLabel, withZ: 100)
        camCon.addHUDChild(canisterBG, withZ: 50)
        camCon.addHUDChild(canisterMeter, withZ: 51)
        
    }
    
    func addToQueue(position: CGPoint, completion: (EnergyParticle) -> (), num: Int = 1) {
        queueSize = num
        spawnPos = position
        particleSpawn = completion
    }
    
    func spawnParticle(position: CGPoint) -> EnergyParticle? {
        if availableParticles.count > 0 {
            var selected: EnergyParticle = particles[availableParticles.removeAtIndex(0)]
            selected.addMe(position)
            return selected
        }
        return nil
    }
    
    func removeParticle(index: Int) {
        self.availableParticles.append(index)
        self.particles[index].killMe()
    }
    
    func takeParticle(index: Int) {
        var par = particles[index]
        let completion: ()->() = {
            self.removeParticle(index)
            self.canMan.addEnergy()
        }
        par.particle.runAction(SKAction.sequence([SKAction.moveTo(par.root.convertPoint(CGPointMake(0, -par.particle.scene!.frame.height/2), fromNode: par.particle.scene!), duration: 0.25), SKAction.runBlock(completion)]))
    }
    
    func updateSuction(#touchPos: CGPoint?, dt: CFTimeInterval) {
        if queueSize > 0 {
            var cycles = Int(dt * spewSpeed)
            if queueSize - cycles < 0 { cycles = queueSize }
            queueSize -= cycles
            for _ in 0..<cycles {
                var particle = spawnParticle(spawnPos)
                if let part = particle {
                    particleSpawn(part)
                }
            }
        }
            
        else if let pos = touchPos {
            if numParticles > availableParticles.count {
                let inSq = innerRange * innerRange
                let outSq = outerRange * outerRange
                let leSuckSpeed = suckSpeed * (dt*4)
                for particle in particles {
                    if particle.active {
                        
                        let a: Double = Double(pos.x - particle.particle.position.x)
                        let b: Double = Double(pos.y - particle.particle.position.y)
                        let dist = (a*a) + (b*b)
                        
                        var strength: Double = 0
                        
                        if dist > inSq && dist < outSq {
                            strength = 1 - Double((dist - inSq) / (outSq-inSq))
                        } else if dist <= inSq {
                            takeParticle(particle.index)
                        }
                        
                        let dx: Double = Double(pos.x - particle.particle.position.x) * leSuckSpeed * strength
                        let dy: Double = Double(pos.y - particle.particle.position.y) * leSuckSpeed * strength
                        
                        particle.particle.position.x += CGFloat(dx)
                        particle.particle.position.y += CGFloat(dy)
                        
                    }
                }
            }
        }
        canisterMeter.xScale = CGFloat(canMan.getPercentage())
        canisterLabel.text = "\(canMan.numFullCanisters)/\(canMan.dailyQuota)"
    }
    
}

class EnergyParticle {
    
    let particle: SKSpriteNode
    let root: SKNode
    var active: Bool = false
    let index: Int
    let emitter: ParticleManager
    
    init(root: SKNode, index: Int, emitter: ParticleManager ) {
        self.index = index
        self.root = root
        self.emitter = emitter
        particle = SKSpriteNode(imageNamed: "bokeh")
        particle.zPosition = 50
        particle.color = SKColor.greenColor()
        particle.colorBlendFactor = 1.0
        particle.blendMode = SKBlendMode.Add
        defaultProperties()
    }
    
    func defaultProperties() {
        particle.xScale = 0.15
        particle.yScale = 0.15
        particle.alpha = 0.5
    }
    
    func addMe(pos: CGPoint) {
        particle.position = pos
//        root.addChild(particle)
        (root.parent?.parent as CameraController).addCameraChild(particle, withZ: 101)
        defaultProperties()
//        active = true
    }
    
    func killMe() {
        particle.removeFromParent()
        particle.removeAllChildren()
        particle.removeAllActions()
        active = false
    }
    
    func setMovement(#start: CGPoint, end: CGPoint, duration: Float) {
        particle.position = start
        
        let move = SKAction.moveTo(end, duration: NSTimeInterval(duration))
        move.timingFunction = { (dt: Float) -> (Float) in
            return 1 - ((1 - dt) * (1 - dt) * (1 - dt))
        }
        
        let thing: CGFloat = CGFloat(arc4random_uniform(10))/10.0
        let durations = thing + 6
        
        let other = SKAction.runBlock { () -> Void in
            self.active = true
        }
        
        let rotateFade = SKAction.sequence([ SKAction.group([ SKAction.rotateByAngle(thing*4, duration: NSTimeInterval(durations)),
                                                              SKAction.moveByX(thing*10, y: thing*10 - (120 * ((thing/2) + 0.5)), duration: NSTimeInterval(durations)),
                                                              SKAction.sequence( [SKAction.waitForDuration(NSTimeInterval(durations - thing*2 - 0.2)), SKAction.runBlock({self.active = false}), SKAction.fadeOutWithDuration(NSTimeInterval(thing*2 + 0.2))]),
                                                              SKAction.scaleBy(thing - 0.5, duration: NSTimeInterval(durations))]),
                                             SKAction.runBlock({self.emitter.removeParticle(self.index)})])
        
        particle.runAction(SKAction.sequence([move, other, rotateFade]))
    }
    
}

class EnergyWell {
    
    enum EnergyWellActivation {
        case NoPower, HalfPower, FullPower
    }
    
    var particles: [EnergyParticle] = [EnergyParticle]()
    var particleMan: ParticleManager
    
    let well: SKShapeNode
    let fillMeter: SKShapeNode
    let lockOn: Float = 2
    var filled: Bool = true
    var lockFill: Float = 0
    var fillPath: UIBezierPath = UIBezierPath()
    var activationLevel: EnergyWellActivation = .NoPower
    
    let numParticlesInBurst: Int = 275
    let maxBurstDistance: UInt32 = 175
    
    init(partMan: ParticleManager) {
        well = SKShapeNode()
        well.path = CGPathCreateWithEllipseInRect(CGRectMake(-20, -20, 40, 40), nil)
        well.strokeColor = SKColor.orangeColor()
        well.fillColor = SKColor.clearColor()
        well.lineWidth = 6
        
        fillMeter = SKShapeNode()
        fillMeter.strokeColor = SKColor.whiteColor()
        fillMeter.fillColor = SKColor.clearColor()
        fillMeter.lineWidth = 3
        
        fillPath.moveToPoint(CGPointMake(0, 25))
        
        particleMan = partMan
    }
    
    func updateProgress(dt: CFTimeInterval) {
        
        if filled {
            
            switch(activationLevel) {
                
            case .NoPower:
                lockFill -= Float(dt/2.0)
                
            case .HalfPower:
                lockFill += Float(dt/3.0)
                
            case .FullPower:
                lockFill += Float(dt)
                
            }
            
            if lockFill < 0 { lockFill = 0.00; fillMeter.alpha = 0.0 }
            else { fillMeter.alpha = 1.0 }
            if lockFill > lockOn { lockFill = lockOn; /*burst()*/ whatTheFuck() }
            
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
                well.fillColor = SKColor(red: 0, green: 1, blue: 0, alpha: 0.5)
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
        
        whatTheFuck()
        
        fillMeter.runAction(SKAction.fadeOutWithDuration(0.5))
        filled = false
        activationLevel = .NoPower
        well.strokeColor = SKColor.grayColor()
        well.fillColor = SKColor.clearColor()
    }
    
    func whatTheFuck() {
        let start = well.parent!.convertPoint(well.position, toNode: well.parent!.parent!)
        let closureThing: (EnergyParticle) -> () = { (particle: EnergyParticle) -> () in
            let distance = Float(arc4random_uniform(self.maxBurstDistance))
            let angle = Float(arc4random_uniform(360)) * Float(M_PI / 180)
            let end = CGPointMake(CGFloat(cos(angle)*distance) + start.x, CGFloat(sin(angle)*distance) + start.y)
            let duration = CGFloat(arc4random_uniform(2))/10.0
            particle.setMovement(start: start, end: end, duration: Float(duration + 0.9))
        }
        particleMan.addToQueue(start, completion: closureThing, num: 2)
    }
    
}

class Whale : SKSpriteNode {
    
    var weakSpots = [EnergyWell]()
    var moveSpeed: Float = 7
    
    var particleMan: ParticleManager?
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(partMan: ParticleManager) {
        self.init(texture: SKTexture(imageNamed: "whale"), color: SKColor.whiteColor(), size: SKTexture(imageNamed: "whale").size())
        particleMan = partMan
        addWeakPoint(position: CGPointMake(-20, 50))
    }
    
    func update(#touchPos: CGPoint?, dt: CFTimeInterval) {
        if let theScene = self.parent {
            if let u_touchPos = touchPos {
                let touchInWhaleSpace = theScene.convertPoint(u_touchPos, toNode: self)
                for ws in weakSpots {
                    let a = touchInWhaleSpace.x - ws.well.position.x
                    let b = touchInWhaleSpace.y - ws.well.position.y
                    let distSq = (a*a)+(b*b)
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
        
//        particleMan?.updateSuction(touchPos: touchPos, dt: dt)
        
        for ws in weakSpots {
            ws.updateProgress(dt)
        }
    }
    
    func addWeakPoint(position pos: CGPoint) {
        let newWeakPoint = EnergyWell(partMan: particleMan!)
        newWeakPoint.setPosition(pos: pos)
        newWeakPoint.well.zPosition = zPosition + 1
        newWeakPoint.fillMeter.zPosition = zPosition + 1
        addChild(newWeakPoint.fillMeter)
        addChild(newWeakPoint.well)
        
        weakSpots += [newWeakPoint]
    }
    
    func move(type: Int, direction dir: CGFloat) {
        xScale = dir
        
        if let theScene = scene {
            
            switch(type) {
            
            case 0:
                let rotate = SKAction.rotateByAngle(-CGFloat(M_PI_2) * dir, duration: NSTimeInterval(moveSpeed))
                let moveX = SKAction.moveByX(dir * 400, y: 0, duration: NSTimeInterval(moveSpeed))
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

                
            case 1:
                let rotate = SKAction.rotateByAngle(-CGFloat(M_PI_2) * dir, duration: NSTimeInterval(moveSpeed))
                let moveX = SKAction.moveByX(dir * 400, y: 0, duration: NSTimeInterval(moveSpeed))
                let moveUp = SKAction.moveByX(0, y: 500, duration: NSTimeInterval(moveSpeed)/2)
                let moveDown = moveUp.reversedAction()
                moveUp.timingFunction = { (dt: Float) -> (Float) in
                    return 1 - ((1 - dt) * (1 - dt) * (1 - dt))
                }
                moveDown.timingFunction = { (dt: Float) -> (Float) in
                    return (dt * dt * dt)
                }
                
                let die = SKAction.runBlock({ () -> Void in
                    (self.scene! as GameScene).removeWhale(whale: self)
                    self.removeFromParent()
                    self.removeAllActions()
                    self.removeAllChildren()
                })
                
                runAction(SKAction.group([rotate, moveX, SKAction.sequence([moveUp, moveDown, die])]))

                
            default:
                let rotate = SKAction.rotateByAngle(-CGFloat(M_PI_2) * dir, duration: NSTimeInterval(moveSpeed))
                let moveX = SKAction.moveByX(dir * 400, y: 0, duration: NSTimeInterval(moveSpeed))
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
    }
    
    func disengage() {
        for ws in weakSpots {
            ws.activate(activation: .NoPower)
        }
    }

}