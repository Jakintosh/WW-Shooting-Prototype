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
    
    struct EmitterQueue {
        var queueSize: Int
        let pos: CGPoint
        let root: SKNode
        
        mutating func setQueueSize(newSize: Int) {
            queueSize = newSize
        }
        
        func isEmpty() -> Bool {
            if queueSize <= 0 {
                return true
            } else {
                return false
            }
        }
    }
    
    // properties
    let numParticles: Int
    let spewSpeed: CGFloat        = 1000.0
    let burstDistance: CGFloat    = 180.0
    let burstTime: NSTimeInterval = 0.5
    let particleLifetime: NSTimeInterval = 7.0
    let updateSegmentSize: Int
    let updateSegments: Int       = 4
    var currentUpdateSegment: Int = 0
    
    // components
    var particles: [EnergyParticle] = [EnergyParticle]()
    var availableParticles: [Int]   = [Int]()
    var queue: [EmitterQueue]       = [EmitterQueue]()
    
    init(num: Int) {
        numParticles = num - (num % updateSegments)
        updateSegmentSize = numParticles / updateSegments
        super.init()
        
        let removeClosure: (Int) -> Void = { i in
            self.removeParticle(i)
        }
        
        for i in 0..<numParticles {
            let part = EnergyParticle(i: i, remove: removeClosure)
            availableParticles.append(i)
            particles.append(part)
        }
    }
    
    func update(dt: CFTimeInterval) {
        
        // if there is something on the queue, spawn things
        if !queue.isEmpty {
            if var q = queue.last {
                
                if q.queueSize > 0 {
                    var cycles = Int(CGFloat(dt) * spewSpeed)
                    if cycles > q.queueSize {
                        cycles = q.queueSize
                    }
                    q.setQueueSize(q.queueSize - cycles)
                    for _ in 0..<cycles {
                        spawnParticle(q.pos, root: q.root)
                    }
                    
                    queue.removeLast()
                    addToQueue(q.queueSize, pos: q.pos, root: q.root)
                }
                
                if q.isEmpty() {
                    queue.removeLast()
                }
            }
        }
    }
    
    func updateParticles(function: (EnergyParticle)->Void) {
        if availableParticles.count < numParticles {
            currentUpdateSegment++
            currentUpdateSegment = currentUpdateSegment%updateSegments
            let start = updateSegmentSize * currentUpdateSegment
            let end = start + updateSegmentSize
            for i in start..<end {
                particles[i].update(function)
            }
        }
    }
    
    func addToQueue(num: Int, pos: CGPoint, root: SKNode) {
        queue.append(EmitterQueue(queueSize: num, pos: pos, root: root))
    }
    
    func spawnParticle(pos: CGPoint, root: SKNode) {
        if availableParticles.count > 0 {
            let i: Int = availableParticles.removeAtIndex(0)
            let part = particles[i]
            part.spawn(pos, root: root)
            moveParticle(part)
        }
    }
    
    func moveParticle(p: EnergyParticle) {
        let angle: CGFloat = (CGFloat(arc4random() % 100) / 100.0) * CGFloat(2.0 * M_PI)
        let distMod = (CGFloat(arc4random() % 100) / 100.0)
        let distance: CGFloat = (distMod * distMod) * burstDistance
        let x = cos(angle) * distance + p.position.x
        let y = sin(angle) * distance + p.position.y
        let s: CGFloat = (CGFloat(arc4random() % 100) / 100.0)
        
        let move = SKAction.moveTo(CGPoint(x: x, y: y), duration: burstTime)
        move.timingMode = .EaseOut
        
        let scale = SKAction.scaleBy(s, duration: particleLifetime)
        
        p.runAction( SKAction.group([move, scale]) )
        p.runAction( SKAction.waitForDuration(particleLifetime), completion: { p.remove() } )
    }
    
    func removeParticle(i: Int) {
        availableParticles.append(i)
    }
}

class EnergyParticle : NHCNode {
    
    // properties
    let index: Int
    var active: Bool = false
    
    let removeClosure: (i: Int) -> Void
    let removeAction: SKAction
    let collectAction: SKAction
    
    // components
    let sprite: SKSpriteNode = SKSpriteNode(imageNamed: "particle")
    
    init(i: Int, remove: (Int) -> Void) {
        
        let rotate = CGFloat((i % 2) - 1) * CGFloat(M_PI_2)
        removeClosure = remove
        removeAction = SKAction.group( [SKAction.scaleTo(0.0, duration: 0.25),
                                        SKAction.fadeAlphaTo(0.0, duration: 0.25)] )
        
        collectAction = SKAction.group( [SKAction.scaleBy(2.5, duration: 0.25),
                                         SKAction.fadeAlphaTo(0.0, duration: 0.25)] )
        
        index = i
        super.init()
        
        reset()
        
        sprite.zPosition = 1
        sprite.color = SKColor.greenColor()
        sprite.colorBlendFactor = 1.0
        sprite.blendMode = .Add
        self.addChild(sprite)
    }
    
    func reset() {
        let rand: CGFloat = (CGFloat(arc4random() % 50) / 100.0) - 0.25
        self.xScale    = 1.0 + rand
        self.yScale    = 1.0 + rand
        self.alpha     = 1.0
        self.zRotation = 0.0
    }
    
    func update(function: (EnergyParticle)->Void) {
        if active {
            function(self)
        }
    }
    
    func spawn(pos: CGPoint, root: SKNode) {
        self.active   = true
        self.position = pos
        root.addChild(self)
    }
    
    func collect() {
//        SoundManager.sharedManager().playSound("energy_collect.wav")
        self.active = false
        self.removeAllActions()
        runAction(collectAction, completion: {
            game.energyManager.addEnergy(0.02)
            self.removeClosure(i: self.index)
            self.removeFromParent()
            self.reset()
        })
    }
    
    func remove() {
        self.active = false
        self.removeAllActions()
        runAction(removeAction, completion: {
            self.removeClosure(i: self.index)
            self.removeFromParent()
            self.reset()
        })
    }
}