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
    case Idling, Walking, Interacting, Stairs
}

class Character : NHCNode {
    
    
    let SCALE_THING: CGFloat = 0.33333
    
    var timeSinceTouchDown: NSTimeInterval = 0
    
    // MARK: - Properties
    var state: CharacterState = .Idling
    var orientation: CharacterOrientation = .Right
    var movementSpeed: CGFloat = 100 // pixels per second
    var canMove: Bool = true
    
    let defaultAnimationKey: String = "idle" // BAD
    
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
        
        interactionNode.position = CGPoint(x: 0, y: 125)
        interactionNode.addChild(interactor.displayNode)
        
        interactor.setMirrored(false)
        
        addChild(animationNode)
        addChild(interactionNode)
    }
    
    // MARK: - Methods
    func update(dt: NSTimeInterval) {
        timeSinceTouchDown += dt
        animator.update(dt)
    }
    
    func idle() {  }
    func walk() {  }
    func interact() {  }
    func stopInteracting() {  }
    
    func moveToPoint(target: CGPoint, visible: Bool = true) {
        if state == .Idling || state == .Walking {
            
            let xDistance = target.x - self.position.x
            let distance = Utilities2D.distanceFromPoint(target, toPoint: self.position)
            
            if xDistance > 0 {
                setOrientation(.Right)
            } else {
                setOrientation(.Left)
            }
            
            let moveDuration = CGFloat(distance)/movementSpeed
            var disappearAction: SKAction
            var appearAction: SKAction
            if visible { disappearAction = SKAction.runBlock({}); appearAction = SKAction.runBlock({}) }
//            else { disappearAction = SKAction.runBlock({ self.animationNode.hidden = !self.animationNode.hidden }) }
            else { disappearAction = SKAction.fadeAlphaTo(0.0, duration: 0.5); appearAction = SKAction.fadeAlphaTo(1.0, duration: 0.5) }
            let moveAction = SKAction.moveTo(target, duration: NSTimeInterval(moveDuration))
            moveAction.timingMode = .EaseOut
            let idleThing = SKAction.runBlock( { self.idle() } )
            removeActionForKey("move")
            runAction(SKAction.sequence([ disappearAction, moveAction, appearAction, idleThing]), withKey: "move")
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
                    animationNode.xScale = -SCALE_THING
                    interactor.setMirrored(true)
                
                case .Right:
                    animationNode.xScale = SCALE_THING
                    interactor.setMirrored(false)
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
class Daughter : Character {
    
    init() {
        super.init(animatorKey: "entity_daughter", interactorKey: "entity_daughter")
        
        // additional spine setup
        animationNode.position = CGPoint(x: 0, y: -15)
        animationNode.xScale = SCALE_THING
        animationNode.yScale = SCALE_THING
        setSpine("spine_daughter_home_default")
    }
    
    override func update(dt: NSTimeInterval) {
        super.update(dt)
    }
}

class DadStairs : NHCNode {
    
    let stepSprite: SKSpriteNode = SKSpriteNode(imageNamed: "dad_stairs1")
    let transSprite: SKSpriteNode = SKSpriteNode(imageNamed: "dad_stairs2")
    
    let stairWidth: CGFloat = 31
    let stairHeight: CGFloat = 10
    
    let stairSize = CGPoint(x: CGFloat(31.0), y: CGFloat(10.0))
    
    init(housePosition: CGPoint) {
        super.init()
        
        // y offset = 65
        // stair offset = 10
        position = housePosition
        stepSprite.position = CGPointZero
        transSprite.position = stairSize
        
        addChild(stepSprite)
        addChild(transSprite)
    }
    
    func run() {
        let fadeInOut = SKAction.sequence([ SKAction.fadeAlphaTo(1.0, duration: 0.25), SKAction.fadeAlphaTo(0.0, duration: 0.25) ])
        let wait = SKAction.waitForDuration(0.5)
        
        let step: () -> () = {
            self.stepSprite.runAction(SKAction.sequence([fadeInOut, wait]), completion: {
                self.transSprite.runAction(SKAction.sequence([fadeInOut, wait]), completion: {
                    self.stepSprite.position = Utilities2D.addPoint(self.stairSize, toPoint: self.stepSprite.position)
                    self.transSprite.position = Utilities2D.addPoint(self.stairSize, toPoint: self.transSprite.position)
                })
            })
        }
        
        let end: () -> () = {
            self.removeAllActions()
            self.removeAllChildren()
            self.removeFromParent()
        }
        
        self.runAction( SKAction.sequence([ SKAction.runBlock(step),
                                            SKAction.waitForDuration(1.1),
                                            SKAction.runBlock(step),
                                            SKAction.waitForDuration(1.1),
                                            SKAction.runBlock(step),
                                            SKAction.waitForDuration(1.1),
                                            SKAction.runBlock(end)]) )
    }
    
}

// MARK: -
class Dad : Character {
    
    // MARK: - GARBAGE MAKE A REUSABLE ENTITY
    var currentFloor: HouseFloor
    var currentRoom: HouseRoom
    var currentPath: HousePath
    
    var canUseStairs: Bool = false
    
//    var button: Button?
    
    init(startingRoom room: HouseRoom) {
        currentFloor = room.associatedFloor
        currentRoom  = room
        currentPath  = room.associatedPath
        
        currentRoom.setActive()
        currentPath.setActive()
        
        super.init(animatorKey: "entity_dad", interactorKey: "entity_dad")
        
        // additional spine setup
        animationNode.position = CGPoint(x: 0, y: -15)
        animationNode.xScale = SCALE_THING
        animationNode.yScale = SCALE_THING
        setSpine("spine_dad_home_default")

//        button = Button(activeImageName: "button_default", defaultImageName: "button_default", action: { self.useStairs() })
//        button!.position = CGPoint(x: 110, y: 180)
//        button!.hidden = true
//        addChild(button!)
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
            
            case .Stairs:
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
    
    override func walk() {
        if state == .Idling {
            state = .Walking
            animator.setQueuedAnimation("walk", introPeriod: 0.1)
            animator.playAnimation("walk", introPeriod: 0.25)
        }
    }
    
    override func idle() {
        if state != .Interacting {
            state = .Idling
            animator.setQueuedAnimation("idle", introPeriod: 0.1)
            animator.playAnimation("idle", introPeriod: 0.25)
        }
    }
    
    override func interact() {
        state = .Interacting
        self.removeActionForKey("move") // THIS MIGHT BREAK IT
    }
    
    override func stopInteracting() {
        state = .Idling
        animator.setQueuedAnimation("idle", introPeriod: 0.25)
    }
    
    
    func touchDown(screenLoc: CGPoint) {
        if state != .Stairs && state != .Interacting {
            timeSinceTouchDown = 0
            
            if state != .Interacting {
                if screenLoc.x > 0 {
                    setOrientation(.Right)
                } else {
                    setOrientation(.Left)
                }
            }
            self.removeActionForKey("move")
            walk()
        }
    }
    
    func touchMove(screenLoc: CGPoint) {
        if state != .Interacting {
            if screenLoc.x > 0 {
                setOrientation(.Right)
            } else {
                setOrientation(.Left)
            }
        }
        
        if state != .Walking {
            var moveDistance = movementSpeed * CGFloat(0.016)
            if orientation == .Left { moveDistance *= -1 }
            let atEnd: Bool = currentPath.getNewX(position.x, movement: moveDistance).atEnd
            if !atEnd {
                walk()
            } else {
                idle()
            }
        }
    }
    
    func touchEnd(screenLoc: CGPoint) {
        if state != .Interacting && state != .Stairs {
            if timeSinceTouchDown < 0.5 {
                let worldPos = scene!.convertPoint(screenLoc, toNode: scene!.childNodeWithName("//Root_Node")!)
                let house: House = scene!.childNodeWithName("//Root_House")! as House
                if let newPos = house.getNewLocation(worldPos, fromRoom: currentRoom) {
                    moveToPoint(newPos)
                }
            } else {
                idle()
            }
        }
    }
    
    // deal with later
    func presentStairBox() {
        interactor.displayOption("Climb Stairs", completion: { self.useStairs() } , delay: 0.0)
//        button!.hidden = false
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
                moveToPoint(targetPoint, visible: false)
                state = .Stairs
            } else {
                println("tried to use stairs but stairs return null destniation point")
                return
            }
        } else {
            println("tried to use stairs but stairs not found")
            return
        }
        
        if let stairs = staircase {
            if let destination = stairs.destination {
                updateCurrentLocation(destination.room)
            }
        }
        
        dismissStairBox()
    }
    func dismissStairBox() {
        interactor.dismissOption(1, delay: 0.0)
    }
    
}