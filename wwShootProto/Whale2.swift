//
//  Whale.swift
//  wwShootProto
//
//  Created by Jak Tiano on 9/21/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class ParticleManager2 {
    
    let camCon: CameraController
    
    var particles: [EnergyParticle2] = [EnergyParticle2]()
    var availableParticles: [Int] = [Int]()
    var numParticles: Int = 0
    
    let innerRange: Double = 20
    let outerRange: Double = 120
    let suckSpeed: Double = 0.5
    
    var queueSize: Int = 0
    var spawnPos: CGPoint = CGPointZero
    var particleSpawn: (EnergyParticle2) -> () = {EnergyParticle in}
    
    let maxQueuePerTick: Int = 20
    let spewSpeed: Double = 1000
    
    init(cc: CameraController, numParticles: Int) {
        self.numParticles = numParticles
        self.camCon = cc
        for i in 0..<numParticles {
            let newParticle = EnergyParticle2(root: camCon.rootNode, index: i, emitter: self)
            availableParticles += [i]
            particles += [newParticle]
        }
        
    }
    
    func addToQueue(position: CGPoint, completion: (EnergyParticle2) -> (), num: Int = 1) {
        queueSize = num
        spawnPos = position
        particleSpawn = completion
    }
    
    func spawnParticle(position: CGPoint) -> EnergyParticle2? {
        if availableParticles.count > 0 {
            var selected: EnergyParticle2 = particles[availableParticles.removeAtIndex(0)]
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
    }
    
}

class EnergyParticle2 {
    
    let particle: SKSpriteNode
    let root: SKNode
    var active: Bool = false
    let index: Int
    let emitter: ParticleManager2
    
    init(root: SKNode, index: Int, emitter: ParticleManager2 ) {
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

class EnergyWell2 {
    
    enum EnergyWellActivation {
        case NoPower, HalfPower, FullPower
    }
//    
//    var particles: [EnergyParticle] = [EnergyParticle]()
//    var particleMan: ParticleManager
    
    let well: SKShapeNode
    let fillMeter: SKShapeNode
    let lockOn: Float = 2
    var filled: Bool = true
    var lockFill: Float = 0
    var lockedOn: Bool = false
    var fillPath: UIBezierPath = UIBezierPath()
    var activationLevel: EnergyWellActivation = .NoPower
    
//    let numParticlesInBurst: Int = 275
//    let maxBurstDistance: UInt32 = 175
    
    init() {
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
    }
    
    func updateProgress(dt: CFTimeInterval) {
        if filled {
            switch(activationLevel)
            {
                case .NoPower:
                    lockFill -= Float(dt/2.0)
                    
                case .HalfPower:
                    lockFill += Float(dt/3.0)
                    
                case .FullPower:
                    lockFill += Float(dt)
            }
            
            if lockFill < 0 { lockFill = 0.00; fillMeter.alpha = 0.0 }
            else { fillMeter.alpha = 1.0 }
            if lockFill > lockOn {
                lockFill = lockOn
                lockedOn = true
                filled = false
            }
            
            var mod: Float = lockFill/lockOn
            mod *= Float(2*M_PI)
            mod = Float(M_PI/2) - mod
            
            fillPath.removeAllPoints()
            fillPath.addArcWithCenter(  CGPointMake(0.0, 0.0),
                                        radius: 25.0,
                                        startAngle: CGFloat(M_PI/2.0),
                                        endAngle: CGFloat(mod),
                                        clockwise: false )
            
            fillMeter.path = nil
            fillMeter.path = fillPath.CGPath
        }
    }
    
    func activate(#activation: EnergyWellActivation) {
        if filled {
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
    }
    
    func setPosition(#pos: CGPoint) {
        well.position = pos
        fillMeter.position = pos
    }
    
    func burst() {
        fillMeter.runAction(SKAction.fadeOutWithDuration(0.5))
        filled = false
        activationLevel = .NoPower
        well.strokeColor = SKColor.grayColor()
        well.fillColor = SKColor.clearColor()
    }
    
}

class Whale2 : SKSpriteNode {
    
    let explosionSound = SKAction.playSoundFileNamed("whale_explosion.caf", waitForCompletion: false)
    
    var weakSpots = [EnergyWell2]()
    var moveSpeed: Float = 7
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override convenience init() {
        let whaleTexture = SKTexture(imageNamed: "whale")
        self.init(texture: whaleTexture, color: SKColor.whiteColor(), size: whaleTexture.size())
        addWeakPoint(position: CGPointMake(-20, 50))
    }
    
    func update(#touchPos: CGPoint?, dt: CFTimeInterval) {
        if let theScene = self.scene {
            if let u_touchPos = touchPos {
                let touchInWhaleSpace = theScene.convertPoint(u_touchPos, toNode: self)
                for ws in weakSpots {
                    if ws.lockedOn {
                        explode()
                        ws.lockedOn = false
                    }
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
        
        for ws in weakSpots {
            ws.updateProgress(dt)
        }
    }
    
    func addWeakPoint(position pos: CGPoint) {
        let newWeakPoint = EnergyWell2()
        newWeakPoint.setPosition(pos: pos)
        newWeakPoint.well.zPosition = zPosition + 1
        newWeakPoint.fillMeter.zPosition = zPosition + 1
        addChild(newWeakPoint.fillMeter)
        addChild(newWeakPoint.well)
        
        weakSpots += [newWeakPoint]
    }
    
    func move(direction dir: CGFloat) {
        zRotation = 0.3 * dir
        let rotateAction = SKAction.rotateByAngle((-0.3 * dir), duration: 3.0)
        let moveUpAction = SKAction.moveByX(0, y: 400, duration: 3.0)
        let floatAction = SKAction.moveByX(0, y: -10, duration: 2.0)
        floatAction.timingMode = .EaseInEaseOut
        let hoverAction = SKAction.repeatActionForever(SKAction.sequence([floatAction, floatAction.reversedAction()]))
        rotateAction.timingMode = .EaseOut
        moveUpAction.timingMode = .EaseOut
        xScale = dir
        runAction(SKAction.sequence([SKAction.group([rotateAction, moveUpAction]), hoverAction]))
    }
    
    func explode() {
        let growFade = SKAction.group([ SKAction.scaleXTo(10.0 * xScale, y: 10.0, duration: 0.5), SKAction.fadeAlphaTo(0.0, duration: 0.5) ])
        let remove = SKAction.runBlock({
            self.removeFromParent()
            self.removeAllChildren()
            self.removeAllActions()
        })
        runAction(SKAction.sequence([explosionSound,growFade,remove]))
        (scene! as GameScene).camCon.shake(25, duration: 1.5)
    }
    
    func disengage() {
        for ws in weakSpots {
            ws.activate(activation: .NoPower)
        }
    }

}