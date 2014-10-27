//
//  Character.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/19/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

enum CharacterOrientation {
    case Left, Right, Forward, Backward
}

class Character : SKFuckNode {
    
    // MARK: - Properties
    var orientation: CharacterOrientation = .Right
    var movementSpeed: Float = 100 // pixels per second
    
    let entityKey: String
    var animationEntity: AnimatableEntity
    let animationNode: SKNode = SKNode()
    
    // MARK: - Initalizers
    init(animationEntityKey: String) {
        entityKey = animationEntityKey
        animationEntity = game.animationManager.registerEntity(entityKey)
        
        super.init()
        
        addChild(animationNode)
    }
    
    // MARK: - Methods
    func update(dt: NSTimeInterval) {
        animationEntity.update(dt)
    }
    
    func moveToPoint(target: CGPoint, visible: Bool = true) {
        let xDistance = target.x - self.position.x
        let distance = Utilities2D.distanceFromPoint(target, toPoint: self.position)
        
        if xDistance > 0 {
            setOrientation(.Right)
        } else {
            setOrientation(.Left)
        }
        
        let moveDuration = Float(distance)/movementSpeed
        var disappearAction: SKAction
//        if visible { disappearAction = SKAction.runBlock({}) }
//        else { disappearAction = SKAction.runBlock({ self.animationEntity.animationSpine?.hidden = !self.animationEntity.animationSpine?.hidden }) }
        let moveAction = SKAction.moveTo(target, duration: NSTimeInterval(moveDuration))
        moveAction.timingMode = .EaseOut
        removeActionForKey("move")
        runAction(SKAction.sequence([ /*disappearAction,*/ moveAction, /*disappearAction*/]), withKey: "move")
    }
    
    func setOrientation(newOrientation: CharacterOrientation) {
//        if orientation != newOrientation {
//            switch(newOrientation) {
//                case .Left:
//                    spine.xScale = -1
//                
//                default:
//                    spine.xScale = 1
//            }
//            orientation = newOrientation
//        }
    }
    
}

// MARK: -
class Dad : Character {
    
    // MARK: - GARBAGE
    var currentFloor: HouseFloor
    var currentRoom: HouseRoom
    var currentPath: HousePath
    
    var canUseStairs: Bool = false
    
    var button: Button?
    
    init(startingRoom room: HouseRoom) {
        currentFloor = room.associatedFloor
        currentRoom  = room
        currentPath  = room.associatedPath
        
        currentRoom.setActive()
        currentPath.setActive()
        
        super.init(animationEntityKey: "entity_dad")
        
        // additional spine setup
        animationNode.position = CGPoint(x: 0, y: -15)
        setSpine("spine_dad_home_default")

        button = Button(activeImageName: "button_default", defaultImageName: "button_default", action: { self.useStairs() })
        button!.position = CGPoint(x: 110, y: 180)
        button!.hidden = true
        addChild(button!)
    }
    
    // update garbage
    override func update(dt: NSTimeInterval) {
        
        if actionForKey("move") != nil {
            var isNearStairs = false
            for stair in currentPath.stairs {
                if stair.pointIsInRange(position) {
                    isNearStairs = true
                    break
                }
            }
            
            if canUseStairs && !isNearStairs {
                canUseStairs = false
                dismissStairBox()
            } else if !canUseStairs && isNearStairs {
                canUseStairs = true
                presentStairBox()
            }
            
            for (_,room) in currentFloor.rooms {
                if room.roomFrame.contains(position) {
                    updateCurrentLocation(room)
                }
            }
        }
        
        super.update(dt)
    }
    func updateCurrentLocation(room: HouseRoom) {
        if currentRoom !== room {
            currentRoom.setInactive()
            currentPath.setInactive()
            
            currentRoom  = room
            currentFloor = room.associatedFloor
            currentPath  = room.associatedPath
            
            currentRoom.setActive()
            currentPath.setActive()
        }
    }
    
    // MARK: Animation
    func setSpine(spineKey: String) {
        animationNode.removeAllChildren()
        
        game.animationManager.setSpineForEntity(spineKey, entityKey: entityKey)
        animationEntity.setupSpine("idle", introPeriod: 0.1)
        
        if let spineNode = animationEntity.animationSpine {
            animationNode.addChild(spineNode)
        }
    }
    
    func walk() {
        animationEntity.playAnimation("walk", introPeriod: 0.1)
    }
    
    
    // deal with later
    func presentStairBox() {
        button!.hidden = false
    }
    func useStairs() {
        
        var staircase: HousePathStaircase? = nil
        for stair in currentPath.stairs {
            if stair.pointIsInRange(position) {
                staircase = stair
                stair.setInactive()
                break
            }
        }
        var targetPoint: CGPoint
        if let stairs = staircase {
            if let stairDestination = stairs.useStaircase() {
                targetPoint = stairDestination
            } else {
                println("tried to use stairs but stairs return null destniation point")
                return
            }
        } else {
            println("tried to use stairs but stairs not found")
            return
        }
        
        moveToPoint(targetPoint, visible: false)
        
        if let stairs = staircase {
            if let destination = stairs.destination {
                updateCurrentLocation(destination.room)
            }
        }
        
        dismissStairBox()
    }
    func dismissStairBox() {
        button!.hidden = true
    }
    
}