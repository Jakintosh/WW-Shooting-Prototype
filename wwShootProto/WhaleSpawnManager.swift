//
//  WhaleSpawnManager.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/18/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class WhaleSpawnManager {
    
    
    enum HeatLevel {
        case Low, Mid, High, End
    }
    class WhaleSpawnLayer {
        
        class WhaleSpawnPoint {
            var ID: Int
            var point: CGPoint
            var isOccupied: Bool
            var mirror: Int
            
            init(pos: CGPoint, id: Int, m: Int = 0) {
                ID = id
                point = pos
                isOccupied = false
                mirror = m
            }
            
            func occupy() {
                isOccupied = true
            }
            
            func abandon() {
                isOccupied = false
            }
        }
        
        var node: NHCNode
        var spawnPoints: [WhaleSpawnPoint] = [WhaleSpawnPoint]()
        
        init(spawns: [CGPoint]) {
            node = NHCNode()
            var id = 0
            for point in spawns {
                spawnPoints += [WhaleSpawnPoint(pos: point, id: id++)]
            }
        }
        
        func getSpawnPoint() -> (pos: CGPoint, i: Int, m: Int) {
            var availableSpawns = [WhaleSpawnPoint]()
            for point in spawnPoints {
                if !point.isOccupied {
                    availableSpawns.append(point)
                }
            }
            let index = arc4random_uniform(UInt32(availableSpawns.count))
            availableSpawns[Int(index)].occupy()
            let selectedSpawn = availableSpawns[Int(index)]
            spawnPoints[selectedSpawn.ID].occupy()
            return (selectedSpawn.point, selectedSpawn.ID, selectedSpawn.mirror)
        }
        
        func pointsAvailable() -> Bool {
            for point in spawnPoints {
                if !point.isOccupied {
                    return true
                }
            }
            return false
        }
        
        func clearSpawnPoint(id: Int) {
            for i in 0..<spawnPoints.count {
                if spawnPoints[i].ID == id {
                    spawnPoints[i].abandon()
                }
            }
        }
    }
    
    struct WhaleAnimation {
        var spine: SGG_Spine
        var owner: SKNode?
        
        func isAvailable() -> Bool {
            if owner == nil {
                return true
            } else {
                return false
            }
        }
    }
    
    // properties
    var isActive: Bool = false
    var heatLevel: HeatLevel
    var timeUntilEval: NSTimeInterval = 0.0
    var instances: Int = 0
    
    let backLayer: WhaleSpawnLayer  = WhaleSpawnLayer(spawns:  [CGPoint(x: -250.0, y: -250.0), CGPoint(x: 0.0, y: -250.0), CGPoint(x: 250.0, y: -250.0)])
    let midLayer:  WhaleSpawnLayer  = WhaleSpawnLayer(spawns:  [CGPoint(x: -200.0, y: -250.0), CGPoint(x: 200.0, y: -250.0)])
    let frontLayer: WhaleSpawnLayer = WhaleSpawnLayer(spawns:  [CGPoint(x: -200.0, y: -250.0), CGPoint(x: 200.0, y: -250.0)])
    
    var nextSpawnLocation: (pos: CGPoint, i: Int, m: Int)!
    var nextSpawnLayer: WhaleSpawnLayer!
    
    // components
    var activeWhales: [Whale] = [Whale]()
    var orcaAnimations: [WhaleAnimation] = [WhaleAnimation]()
    
    var particleEmitter: EnergyParticleEmitter!
    var camCon: CameraController!
    var baseNode: NHCNode! {
        didSet {
            backLayer.node.removeFromParent()
            midLayer.node.removeFromParent()
            frontLayer.node.removeFromParent()
            
            self.baseNode.addChild(backLayer.node)
            self.baseNode.addChild(midLayer.node)
            self.baseNode.addChild(frontLayer.node)
        }
    }
    
    init() {
        heatLevel = .Mid
        
        midLayer.spawnPoints[0].mirror = 1
        midLayer.spawnPoints[1].mirror = 2
        frontLayer.spawnPoints[0].mirror = 1
        frontLayer.spawnPoints[1].mirror = 2
        
        backLayer.node.zPosition  = -25
        midLayer.node.zPosition   = -15
        frontLayer.node.zPosition = -5
        
        backLayer.node.name  = "back"
        midLayer.node.name   = "mid"
        frontLayer.node.name = "front"
        
        let frontWater = SKSpriteNode(imageNamed: "WaterLayer_002")
        let midWater   = SKSpriteNode(imageNamed: "WaterLayer_003")
        let backWater  = SKSpriteNode(imageNamed: "WaterLayer_004")
        
        frontWater.zPosition = -5
        midWater.zPosition   = -15
        backWater.zPosition  = -25
        
        frontWater.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        midWater.anchorPoint   = CGPoint(x: 0.5, y: 0.0)
        backWater.anchorPoint  = CGPoint(x: 0.5, y: 0.0)
        
        frontWater.position = CGPoint(x: 0, y: 44)
        midWater.position   = CGPoint(x: 0, y: 80)
        backWater.position  = CGPoint(x: 0, y: 110)
        
        frontLayer.node.addChild(backWater)
        frontLayer.node.addChild(midWater)
        frontLayer.node.addChild(frontWater)
        
        backLayer.node.xScale = 0.6
        backLayer.node.yScale = 0.6
        midLayer.node.xScale = 0.85
        midLayer.node.yScale = 0.85
        
        setNextSpawnPoint()
    }
    
    func reset() {
        isActive = false
    }
    
    func loadWhaleAnimations() {
        // preload the orca animations
        for i in 0..<5 {
            if let spine = game.animationManager.getSpine(spineKey: "spine_whale_orca_\(i)") {
                orcaAnimations += [WhaleAnimation(spine: spine, owner: nil)]
            }
        }
    }
    
    func update(screenPos: CGPoint, dt: CFTimeInterval) {
        if isActive {
            timeUntilEval -= dt
            if timeUntilEval <= 0 {
                timeUntilEval = getUpdateTime()
                
                // add new whales (if necessary)
                if activeWhales.count < getMaxWhales() {
                    createWhale()
                }
                
                // see if any whales should jump
                var numWhalesJumping = 0
                for whale in activeWhales {
                    if whale.whaleState != .Submerged { numWhalesJumping++ }
                }
                if numWhalesJumping < getMaxJumping() {
                    whaleJump()
                }
            }
            
            var whaleScreamTime: CGFloat = 0.0
            for whale in activeWhales {
                whale.update(screenPos, dt: dt)
                if whale.isScreaming { whaleScreamTime += CGFloat(0.2) } // this is hardcoded ( 10(sec) * 0.02 (.98 inv) = 0.2)
            }
            game.screamManager.update(dt, totalScreams: whaleScreamTime)
        }
    }
    
    // must keep track of the current whales in play
    func createWhale() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            let spawnLayer = self.getRandomSpawnLayer()
            let newIndex = self.instances++
            let onDeath: (pos: CGPoint, root: SKNode) -> Void = { (pos, root) in
                self.particleEmitter.addToQueue(200, pos: pos, root: root)
                self.destroyWhale(newIndex)
            }
            let ss: (CGFloat, NSTimeInterval)->Void = { (intensity, duration) in self.camCon.shake(intensity, duration: duration) }
            let newOrca = Orca(onDeath: onDeath, ss: ss, mgrInd: newIndex)
            if self.connectAnimationForOrca(newOrca) {
                newOrca.zPosition = -1
                if arc4random_uniform(2) == 0 { newOrca.mirror(true) }
                self.activeWhales += [newOrca]
            } else {
                println("whale creation failed due to lack of animations")
            }
//            dispatch_async(dispatch_get_main_queue(), {
//                println("built a whale on a different thread and returned to the main thread")
//            });
        });
    }
    func destroyWhale(whaleID: Int) {
        for i in 0..<activeWhales.count {
            if activeWhales[i].managerIndex == whaleID {
                disconnectAnimationForOrca(activeWhales[i] as Orca)
                activeWhales[i].onSubmerge()
                activeWhales.removeAtIndex(i)
                break
            }
        }
    }
    func whaleJump() {
        for whale in activeWhales {
            if whale.whaleState == .Submerged {
                
                if nextSpawnLayer != nil && nextSpawnLocation != nil {
                    whale.position = nextSpawnLocation.pos
                    switch(nextSpawnLocation.m)
                    {
                    case 0:
                        if arc4random_uniform(2) == 0 { whale.mirror(true) }
                        else { whale.mirror(false) }
                    case 2:
                        whale.mirror(true)
                    default:
                        whale.mirror(false)
                    }
                    
                    nextSpawnLayer.node.addChild(whale)
                    let thisLayer = nextSpawnLayer
                    let index = nextSpawnLocation.i
                    whale.onSubmerge = {
                        thisLayer.clearSpawnPoint(index)
                    }
                    whale.jump()
                    nextSpawnLocation = nil
                    nextSpawnLayer = nil
                    setNextSpawnPoint()
                } else {
                    if var spawnLayer = getRandomSpawnLayer() {
                        let info = spawnLayer.getSpawnPoint()
                        whale.position = info.pos
                        switch(info.m)
                        {
                            case 0:
                                if arc4random_uniform(2) == 0 { whale.mirror(true) }
                                else { whale.mirror(false) }
                            case 2:
                                whale.mirror(true)
                            default:
                                whale.mirror(false)
                        }
                        
                        spawnLayer.node.addChild(whale)
                        whale.onSubmerge = {
                            spawnLayer.clearSpawnPoint(info.i)
                        }
                        whale.jump()
                    } else {
                        println("no layers are available to spawn in!")
                    }
                }
                break
            }
        }
    }
    func getRandomSpawnLayer() -> WhaleSpawnLayer? {
        var spawnLayer: WhaleSpawnLayer?
        var eligibleLayers = [WhaleSpawnLayer]()
        
        if backLayer.pointsAvailable()  { eligibleLayers.append(backLayer)  }
        if midLayer.pointsAvailable()   { eligibleLayers.append(midLayer)   }
        if frontLayer.pointsAvailable() { eligibleLayers.append(frontLayer) }
        
        if !eligibleLayers.isEmpty {
            let rand = arc4random_uniform(UInt32(eligibleLayers.count))
            spawnLayer = eligibleLayers[Int(rand)]
        }
        return spawnLayer
    }
    func setNextSpawnPoint() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            self.nextSpawnLayer = self.getRandomSpawnLayer()
            self.nextSpawnLocation = self.nextSpawnLayer.getSpawnPoint()
//            dispatch_async(dispatch_get_main_queue(), {
//                println("found a spawn point on a different thread and returned to main thread")
//            });
        });
    }
    func getMaxWhales() -> Int {
        switch( heatLevel )
        {
            case .Low:
                return 2
                
            case .Mid:
                return 3
                
            case .High:
                return 4
                
            case .End:
                return 5
        }
    }
    func getUpdateTime() -> NSTimeInterval {
        switch( heatLevel )
        {
        case .Low:
            return 7.0
            
        case .Mid:
            return 6.0
            
        case .High:
            return 5.0
            
        case .End:
            return 4.0
        }
    }
    func getMaxJumping() -> Int {
        switch( heatLevel )
        {
        case .Low:
            return 1
            
        case .Mid:
            return 2
            
        case .High:
            return 3
            
        case .End:
            return 4
        }
    }
    func connectAnimationForOrca(whale: Orca) -> Bool {
        for i in 0..<orcaAnimations.count {
            var anim = orcaAnimations[i]
            if orcaAnimations[i].isAvailable() {
                orcaAnimations[i].owner = whale
                whale.setSpine(orcaAnimations[i].spine, animKey: "jump_white")
                return true
            }
        }
        return false
    }
    func disconnectAnimationForOrca(whale: Orca) {
        for i in 0..<orcaAnimations.count {
            if orcaAnimations[i].owner == whale {
                orcaAnimations[i].owner = nil
                whale.animator.removeSpine()
                orcaAnimations[i].spine.hidden = false
            }
        }
    }
    
    // must spawn new whales to keep challenge mapped to heat level
    
    
    // must increase heat level appropriately
    
}