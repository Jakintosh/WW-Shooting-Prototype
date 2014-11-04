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
    case Left, Right
}

enum CharacterState {
    case Idling, Walking, Interacting
}

class Character : NHCNode {
    
    // MARK: - Properties
    var state: CharacterState = .Idling
    var orientation: CharacterOrientation = .Right
    var movementSpeed: CGFloat = 100 // pixels per second
    var canMove: Bool = true
    
    // subsystem comonents
    let animatorKey: String
    var animator: AnimatableEntity!
    
    let interactorKey: String
    var interactor: InteractiveEntity!
    
    // subsystem nodes
    let animationNode: SKNode = SKNode()
    let interactionNode: SKNode = SKNode()
    
    // MARK: - Initalizers
    init(animatorKey: String, interactorKey: String) {
        self.animatorKey = animatorKey
        self.interactorKey = interactorKey
        
        super.init()
        
        animator = game.animationManager.registerEntity(animatorKey, owner: self)
        interactor = game.interactionManager.registerEntity(interactorKey, owner: self)
        
        interactionNode.position = CGPoint(x: 0, y: 150)
        interactionNode.addChild(interactor.displayNode)
        
        addChild(animationNode)
        addChild(interactionNode)
    }
    
    // MARK: - Methods
    func update(dt: NSTimeInterval) {
        animator.update(dt)
    }
    
    func moveToPoint(target: CGPoint, visible: Bool = true) {
        if canMove {
            let xDistance = target.x - self.position.x
            let distance = Utilities2D.distanceFromPoint(target, toPoint: self.position)
            
            if xDistance > 0 {
                setOrientation(.Right)
            } else {
                setOrientation(.Left)
            }
            
            let moveDuration = CGFloat(distance)/movementSpeed
            var disappearAction: SKAction
            if visible { disappearAction = SKAction.runBlock({}) }
            else { disappearAction = SKAction.runBlock({ self.animationNode.hidden = !self.animationNode.hidden }) }
            let moveAction = SKAction.moveTo(target, duration: NSTimeInterval(moveDuration))
            moveAction.timingMode = .EaseOut
            removeActionForKey("move")
            runAction(SKAction.sequence([ /*disappearAction,*/ moveAction, /*disappearAction*/]), withKey: "move")
        }
    }
    
    func facePoint(point: CGPoint) {
        if point.x > position.x {
            setOrientation(.Right)
        } else {
            setOrientation(.Left)
        }
    }
    
    func setOrientation(newOrientation: CharacterOrientation) {
        if orientation != newOrientation {
            switch(newOrientation) {
                case .Left:
                    animationNode.xScale = -0.7
                
                case .Right:
                    animationNode.xScale = 0.7
            }
            orientation = newOrientation
        }
    }
    
    // MARK: Animation
    func setSpine(spineKey: String) {
        animationNode.removeAllChildren()
        
        game.animationManager.setSpineForEntity(spineKey, entityKey: animatorKey)
        animator.setupSpine("idle", introPeriod: 0.1)
        
        if let spineNode = animator.animationSpine {
            animationNode.addChild(spineNode)
        }
    }
    
}

// MARK: -
class Dad : Character {
    
    // MARK: - GARBAGE MAKE A REUSABLE ENTITY
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
        
        super.init(animatorKey: "entity_dad", interactorKey: "entity_dad")
        
        // additional spine setup
        animationNode.position = CGPoint(x: 0, y: -15)
        animationNode.xScale = 0.7
        animationNode.yScale = 0.7
        setSpine("spine_dad_home_default")

        button = Button(activeImageName: "button_default", defaultImageName: "button_default", action: { self.useStairs() })
        button!.position = CGPoint(x: 110, y: 180)
        button!.hidden = true
        addChild(button!)
    }
    
    // update garbage
    override func update(dt: NSTimeInterval) {
        
        switch (state)
        {
            case .Idling:
                break
                
            case .Walking:
                // update movement
                var moveDistance = movementSpeed * CGFloat(dt)
                if orientation == .Left { moveDistance *= -1 }
                
                let moveData = currentPath.getNewX(position.x, movement: moveDistance)
                position.x = moveData.newX
                if moveData.atEnd {
                    idle()
                }
                
                // update house awareness
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
                
            case .Interacting:
                break
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

    
    func walk() {
        if state == .Idling {
            state = .Walking
            animator.setQueuedAnimation("walk", introPeriod: 0.1)
            animator.playAnimation("walk", introPeriod: 0.25)
        }
    }
    
    func idle() {
        if state != .Interacting {
            state = .Idling
            animator.setQueuedAnimation("idle", introPeriod: 0.1)
            animator.playAnimation("idle", introPeriod: 0.25)
        }
    }
    
    func interact() {
        state = .Interacting
    }
    
    func stopInteracting() {
        state = .Idling
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