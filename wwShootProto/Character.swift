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
    
    var sprite: SKSpriteNode
    
    // MARK: - Initalizers
    init(imgName: String) {
        sprite = SKSpriteNode(imageNamed: imgName)
        
        super.init()
        
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        addChild(sprite)
    }
    
    // MARK: - Methods
    func moveToPoint(target: CGPoint) {
        let xDistance = target.x - self.position.x
        let distance = Utilities2D.distanceFromPoint(target, toPoint: self.position)
        
        if xDistance > 0 {
            setOrientation(.Right)
        } else {
            setOrientation(.Left)
        }
        
        let moveDuration = Float(distance)/movementSpeed
        let moveAction = SKAction.moveTo(target, duration: NSTimeInterval(moveDuration))
        moveAction.timingMode = .EaseOut
        removeActionForKey("move")
        runAction(moveAction, withKey: "move")
    }
    
    func setOrientation(newOrientation: CharacterOrientation) {
        if orientation != newOrientation {
            switch(newOrientation) {
                case .Left:
                    sprite.xScale = -1
                    
                default:
                    sprite.xScale = 1
            }
            orientation = newOrientation
        }
    }
    
}

// MARK: -

class Dad : Character {
    
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
        
        super.init(imgName: "main")
        sprite.position = CGPoint(x: 0, y: -15)
        button = Button(activeImageName: "button_default", defaultImageName: "button_default", action: { self.useStairs() })
        button!.position = CGPoint(x: 110, y: 180)
        button!.hidden = true
        addChild(button!)
    }
    
    func update(dt: NSTimeInterval) {
        
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
        
        moveToPoint(targetPoint)
        
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