//
//  ParticleManager.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/16/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class EnergyParticleEmitter : NHCNode {
    
    var particles: [EnergyParticle] = [EnergyParticle]()
    var availableParticles: [Int]   = [Int]()
    var numParticles: Int           = 0
    
    let innerRange: Double  = 20
    let outerRange: Double  = 120
    let suckSpeed: Double   = 0.5
    
    var queue: [(num: Int, pos: CGPoint, root: SKNode)] = []
    
    let maxQueuePerTick: Int = 20
    let spewSpeed: Double    = 1000
    
    init(cc: CameraController, numParticles: Int) {
        self.numParticles = numParticles
        
        super.init()
        
        for i in 0..<numParticles {
            let newParticle = EnergyParticle(index: i, emitter: self)
            availableParticles += [i]
            particles += [newParticle]
        }
    }
    
    func addToQueue(position: CGPoint, root: SKNode, num: Int = 1) {
        queue.append((num: num, pos: position, root: root))
    }
    
    func spawnParticle(position: CGPoint, root: SKNode) -> EnergyParticle? {
        if availableParticles.count > 0 {
            var selected: EnergyParticle = particles[availableParticles.removeAtIndex(0)]
            selected.addMe(position, root: root)
            return selected
        }
        return nil
    }
    
    func removeParticle(index: Int) {
        self.availableParticles.append(index)
        self.particles[index].killMe()
    }
    
    func update(dt: CFTimeInterval) {
        if let currentQueue = queue.last {
            var queueSize: Int = currentQueue.num
            let queuePos: CGPoint = currentQueue.pos
            let queueRoot: SKNode = currentQueue.root
            if queueSize > 0 {
                var cycles = Int(dt * spewSpeed)
                if queueSize < cycles {
                    cycles = queueSize
                }
                queueSize -= cycles
                for _ in 0..<cycles {
    //                var particle = spawnParticle(spawnPos)
    //                if let part = particle {
    //                    particleSpawn(part)
    //                }
                }
            }
            queue.removeLast()
            addToQueue(queuePos, root: queueRoot, num: queueSize)
        }
    }
    
//    func takeParticle(index: Int) {
//        var par = particles[index]
//        let completion: ()->() = {
//            self.removeParticle(index)
//        }
//        par.particle.runAction(SKAction.sequence([SKAction.moveTo(par.root.convertPoint(CGPointMake(0, -par.particle.scene!.frame.height/2), fromNode: par.particle.scene!), duration: 0.25), SKAction.runBlock(completion)]))
//    }
//    
//    func updateSuction(#touchPos: CGPoint?, dt: CFTimeInterval) {
//        if queueSize > 0 {
//            var cycles = Int(dt * spewSpeed)
//            if queueSize - cycles < 0 { cycles = queueSize }
//            queueSize -= cycles
//            for _ in 0..<cycles {
//                var particle = spawnParticle(spawnPos)
//                if let part = particle {
//                    particleSpawn(part)
//                }
//            }
//        }
//            
//        else if let pos = touchPos {
//            if numParticles > availableParticles.count {
//                let inSq = innerRange * innerRange
//                let outSq = outerRange * outerRange
//                let leSuckSpeed = suckSpeed * (dt*4)
//                for particle in particles {
//                    if particle.active {
//                        
//                        let a: Double = Double(pos.x - particle.particle.position.x)
//                        let b: Double = Double(pos.y - particle.particle.position.y)
//                        let dist = (a*a) + (b*b)
//                        
//                        var strength: Double = 0
//                        
//                        if dist > inSq && dist < outSq {
//                            strength = 1 - Double((dist - inSq) / (outSq-inSq))
//                        } else if dist <= inSq {
//                            takeParticle(particle.index)
//                        }
//                        
//                        let dx: Double = Double(pos.x - particle.particle.position.x) * leSuckSpeed * strength
//                        let dy: Double = Double(pos.y - particle.particle.position.y) * leSuckSpeed * strength
//                        
//                        particle.particle.position.x += CGFloat(dx)
//                        particle.particle.position.y += CGFloat(dy)
//                    }
//                }
//            }
//        }
//    }
}

class EnergyParticle : NHCNode {
    
    // components
    let particle: SKSpriteNode
    
    // properties
    let index: Int
    var active: Bool = false
    let emitter: EnergyParticleEmitter
    
    init(index: Int, emitter: EnergyParticleEmitter) {
        self.index = index
        self.emitter = emitter
        
        particle = SKSpriteNode(imageNamed: "bokeh")
        particle.zPosition = 1
        particle.color = SKColor.greenColor()
        particle.colorBlendFactor = 1.0
        particle.blendMode = .Add
        
        super.init()
        
        addChild(particle)
        
        defaultProperties()
    }
    
    func defaultProperties() {
        particle.xScale = 0.15
        particle.yScale = 0.15
        particle.alpha = 0.5
    }
    
    func addMe(pos: CGPoint, root: SKNode) {
        particle.position = pos
        (root.parent?.parent as CameraController).addCameraChild(particle, withZ: 101)
        defaultProperties()
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