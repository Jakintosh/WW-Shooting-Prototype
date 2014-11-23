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
    func updateAwareness() {  }
    
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

//            let completion = SKAction.runBlock({ self.updateAwareness() })
            
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

// MARK: -
class Dad : Character {
    
    // MARK: - GARBAGE MAKE A REUSABLE ENTITY
    var currentFloor: HouseFloor
    var currentRoom: HouseRoom
    var currentPath: HousePath
    
    var canUseStairs: Bool = false
    
    var touches: [UITouch] = [UITouch]()
    
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
                updateAwareness()
                
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
    override func updateAwareness() {
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
    }
    
    override func walk() {
        if state == .Idling {
            state = .Walking
            animator.setQueuedAnimation("walk", introPeriod: 0.1)
            animator.playAnimation("walk", introPeriod: 0.25)
        }
    }
    
    override func idle() {
        if state == .Stairs {
            updateAwareness()
        }
        if state != .Interacting {
            state = .Idling
            animator.setQueuedAnimation("idle", introPeriod: 0.1)
            animator.playAnimation("idle", introPeriod: 0.25)
        }
    }
    
    override func interact() {
        idle()
        state = .Interacting
        self.removeActionForKey("move") // THIS MIGHT BREAK IT
        
    }
    
    override func stopInteracting() {
        state = .Idling
        animator.setQueuedAnimation("idle", introPeriod: 0.25)
    }
    
    func touchDown(touch: UITouch) {
        self.touches.removeAll(keepCapacity: false)
        self.touches.append(touch)
        let scenePos = self.touches.last!.locationInNode(self.parent!)
        let charPos = self.position
        if state != .Stairs && state != .Interacting {
            timeSinceTouchDown = 0
            
            if state != .Interacting {
                if scenePos.x > charPos.x {
                    setOrientation(.Right)
                } else {
                    setOrientation(.Left)
                }
            }
            self.removeActionForKey("move")
            walk()
        }
    }
    
    func touchMove() {
        if let touch = self.touches.last {
            let screenLoc = touch.locationInNode(scene)
            if state == .Stairs {
                return
            }
            
            var switched: Bool = false
            if state != .Interacting {
                let scenePos = self.touches.last!.locationInNode(self.parent!)
                let charPos = self.position
                self.removeActionForKey("move")
                if scenePos.x > charPos.x {
                    if orientation == .Left { switched = true }
                    setOrientation(.Right)
                } else {
                    if orientation == .Right { switched = true }
                    setOrientation(.Left)
                }
            }
            
            if state != .Walking {
                if switched {
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
        }
    }
    
    func touchEnd(touch: UITouch) {
        // remove the touch
//        for var i = 0; i < touches.count; i++ {
//            if touches[i] as UITouch == touch {
//                touches.removeAtIndex(i)
//                break
//            }
//        }
        self.touches.removeAll(keepCapacity: false)
        if state != .Stairs {
            // if no touches remain end it all
            if touches.isEmpty {
                idle()
            }
        }
//        let screenLoc = myTouch.locationInNode(scene)
//        if state != .Interacting && state != .Stairs {
////            if timeSinceTouchDown < 0.5 {
////                let worldPos = scene!.convertPoint(screenLoc, toNode: scene!.childNodeWithName("//Root_Node")!)
////                let house: House = scene!.childNodeWithName("//Root_House")! as House
////                if let newPos = house.getNewLocation(worldPos, fromRoom: currentRoom) {
////                    moveToPoint(newPos)
////                }
////            } else {
////                idle()
////            }
//            idle()
//            if myTouch === touch {
//                self.touch = nil
//            }
//        }
    }
    
    func doubleTap(screenLoc: CGPoint) {
        walk()
        let worldPos = scene!.convertPoint(screenLoc, toNode: scene!.childNodeWithName("//Root_Node")!)
        let house: House = scene!.childNodeWithName("//Root_House")! as House
        if let newPos = house.getNewLocation(worldPos, fromRoom: currentRoom) {
            moveToPoint(newPos)
        }
    }
    
    // deal with later
    func presentStairBox() {
        var text: String = "Use <ERROR>"
        for stair in currentPath.stairs {
            if stair.pointIsInRange(position) {
                if let door = stair.doorwayAnimation {
                    switch stair.direction
                    {
                    case .Up:
                        text = "Go Upstairs"
                        
                    case .Down:
                        text = "Go Downstairs"
                    }
                } else if let ladder = stair.ladder {
                    text = "Use Ladder"
                }
                break
            }
        }
        interactor.displayOption(text, completion: { self.useStairs() } , delay: 0.0)
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
                canUseStairs = false
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
