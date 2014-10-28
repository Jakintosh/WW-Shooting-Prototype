//
//  HouseFloor.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/17/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class SKFuckNode : SKNode {/* this is the fucking worst*/}

// MARK: -
class House : SKFuckNode {
    
    // MARK:   Properties
    var startingRoom: HouseRoom
    
    var houseSprite: SKSpriteNode = SKSpriteNode(imageNamed: "house")
    
    // MARK:   Components
    var floors: [HouseFloor] = [HouseFloor]()
    
    // MARK:   Initializers
    override init() {
        
        // initialize first floor
        let floor1      = HouseFloor(height: 290, floorY: 40, yPosition: 0)
        let path1_1     = floor1.addPath(left: 180, right: 1575)
        let room1_1     = floor1.addRoom(name: "bathroom", xPos: 0,    width: 285,  path: path1_1)
        let room1_2     = floor1.addRoom(name: "kitchen",  xPos: 285,  width: 1070, path: path1_1)
        let room1_3     = floor1.addRoom(name: "mudroom",  xPos: 1355, width: 325,  path: path1_1)
        let stair1_1    = path1_1.addStaircase(815, room: room1_2, dir: .Up)
        floors.append(floor1)
        
        // initialize second floor
        let floor2      = HouseFloor(height: 275, floorY: 30, yPosition: 295)
        let path2_1     = floor2.addPath(left: 70, right: 1380)
        let room2_1     = floor2.addRoom(name: "office",     xPos: 0,   width: 520, path: path2_1)
        let room2_2     = floor2.addRoom(name: "livingroom", xPos: 520, width: 925, path: path2_1)
        let stair2_1    = path2_1.addStaircase(815,  room: room2_2, dir: .Up)
        let stair2_2    = path2_1.addStaircase(1350, room: room2_2, dir: .Down)
        floors.append(floor2)
        
        // initialize third floor
        let floor3      = HouseFloor(height: 255, floorY: 30, yPosition: 575)
        let path3_1     = floor3.addPath(left: 840, right: 1370)
        let room3_1     = floor3.addRoom(name: "bedroom", xPos: 520,  width: 520, path: path3_1)
        let room3_2     = floor3.addRoom(name: "hallway", xPos: 1040, width: 410, path: path3_1)
        let stair3_1    = path3_1.addStaircase(1225, room: room3_2, dir: .Up)
        let stair3_2    = path3_1.addStaircase(1335, room: room3_2, dir: .Down)
        floors.append(floor3)
        
        // initialize fourth floor
        let floor4      = HouseFloor(height: 300, floorY: 30, yPosition: 835)
        let path4_1     = floor4.addPath(left: 575, right: 1225)
        let room4_1     = floor4.addRoom(name: "daughter", xPos: 520,  width: 815, path: path4_1)
        let stair4_1    = path4_1.addStaircase(1225, room: room4_1, dir: .Down)
        floors.append(floor4)
        
        // set up stair connections
        stair1_1.setDestination(stair2_2)
        stair2_2.setDestination(stair1_1)
        
        stair2_1.setDestination(stair3_2)
        stair3_2.setDestination(stair2_1)
        
        stair3_1.setDestination(stair4_1)
        stair4_1.setDestination(stair3_1)
        
        // set starting locations
        startingRoom = room2_1
        
        // set up the house sprite
        houseSprite.zPosition = -1
        houseSprite.anchorPoint = CGPoint(x: 0, y: 0)
        houseSprite.position = CGPoint(x: -80, y: 0)
        houseSprite.xScale = 4.0
        houseSprite.yScale = 4.0
        
        super.init()
        
        // add children
        addChild(floor1)
        addChild(floor2)
        addChild(floor3)
        addChild(floor4)
        addChild(houseSprite)
        
        floor1.hidden = true
        floor2.hidden = true
        floor3.hidden = true
        floor4.hidden = true
        houseSprite.hidden = false
    }
    
    // MARK:   Methods
    func getNewLocation(point: CGPoint, fromRoom room: HouseRoom) -> CGPoint? {
        let xPos: CGFloat = Utilities2D.clamp(point.x, min: room.associatedPath.leftEndpoint, max: room.associatedPath.rightEndpoint)
        let yPos: CGFloat = room.associatedFloor.floorY + room.associatedFloor.yPosition
        let newPosition = CGPoint(x: xPos, y: yPos)
        return newPosition
    }
    
    func getStartingLocation() -> CGPoint? {
        if let startLoc = getNewLocation( CGPoint(x: CGRectGetMidX(startingRoom.roomFrame), y: CGRectGetMidY(startingRoom.roomFrame)), fromRoom: startingRoom) {
            return startLoc
        } else {
            println("could not find a starting point inside designated starting room")
            return nil
        }
    }
    
    func findRoomWithName(name: String) -> HouseRoom? {
        for floor in floors {
            for (_name, room) in floor.rooms {
                if name == _name {
                    return room
                }
            }
        }
        return nil
    }
    
    func toggleDebug() {
        for floor in floors {
            floor.hidden = !floor.hidden
        }
        houseSprite.hidden = !houseSprite.hidden
    }
    
}

// MARK: -
class HouseFloor : SKNode {
    
    // MARK:   Properties
    var height: CGFloat = 0
    var yPosition: CGFloat = 0
    var floorY: CGFloat = 25
    
    // MARK:   Componenents
    var rooms: [String : HouseRoom] = [String : HouseRoom]()
    var paths: [HousePath] = [HousePath]()
    
    // MARK:   Initializers
    convenience init(height: CGFloat, floorY: CGFloat, yPosition: CGFloat) {
        self.init()
        
        self.height = height
        self.floorY = floorY
        self.yPosition = yPosition
    }
    
    // MARK:   Methods
    func addPath(#left: CGFloat, right: CGFloat) -> HousePath {
        let path = HousePath(left: left, right: right, y: floorY + yPosition)
        addChild(path.visualPath)
        paths.append(path)
        return path
    }
    
    func addRoom(#name: String, xPos: CGFloat, width: CGFloat, path: HousePath) -> HouseRoom {
        let room = HouseRoom(frame: CGRectMake(xPos, yPosition, width, height), onFloor: self, withPath: path)
        addChild(room.visualFrame)
        rooms[name] = room
        return room
    }
    
}

// MARK: -
class HouseRoom {
    
    // MARK:   Properties
    let associatedFloor: HouseFloor
    let associatedPath: HousePath
    
    // MARK:   Components
    
    // bounds
    var roomFrame: CGRect         = CGRectZero
    var visualFrame: SKShapeNode  = SKShapeNode()
    
    // MARK:   Initializers
    init(frame: CGRect, onFloor floor: HouseFloor, withPath path: HousePath) {
        
        // set associated house components
        associatedFloor = floor
        associatedPath = path
        
        // initialize bounds
        setFrame(frame)
        visualFrame.fillColor = SKColor.clearColor()
        visualFrame.strokeColor = SKColor.redColor()
        visualFrame.lineWidth = 4.0
    }
    
    // MARK:   Methods
    func setFrame(frame: CGRect) {
        roomFrame = frame
        visualFrame.path = CGPathCreateWithRect(roomFrame, nil)
    }
    
    func setActive() {
        visualFrame.strokeColor = SKColor.whiteColor()
    }
    
    func setInactive() {
        visualFrame.strokeColor = SKColor.redColor()
    }
}

// MARK: -
class HousePath {
    
    // MARK:   Properties
    let yPosition: CGFloat
    let leftEndpoint: CGFloat
    let rightEndpoint: CGFloat
    
    var stairs: [HousePathStaircase] = [HousePathStaircase]()
    
    let visualPath: SKShapeNode = SKShapeNode()
    
    // MARK:   Initializers
    init(left: CGFloat, right: CGFloat, y: CGFloat) {
        leftEndpoint = left
        rightEndpoint = right
        yPosition = y
        
        var tempPath: CGMutablePathRef = CGPathCreateMutable()
        CGPathMoveToPoint(tempPath, nil, leftEndpoint, yPosition)
        CGPathAddLineToPoint(tempPath, nil, rightEndpoint, yPosition)
        visualPath.path = tempPath
        visualPath.strokeColor = SKColor.whiteColor()
        visualPath.fillColor = SKColor.clearColor()
        visualPath.lineWidth = 4.0
    }
    
    // MARK:   Methods
    func addStaircase(xPos: CGFloat, room: HouseRoom, dir: HousePathStaircaseDirection) -> HousePathStaircase {
        let newStairs = HousePathStaircase(pos: CGPoint(x: xPos, y: yPosition), dir: dir, room: room, path: self)
        stairs.append(newStairs)
        visualPath.addChild(newStairs.visualCircle)
        return newStairs
    }
    
    func setActive() {
        visualPath.strokeColor = SKColor.greenColor()
    }
    
    func setInactive() {
        visualPath.strokeColor = SKColor.whiteColor()
    }
}

// MARK: -

enum HousePathStaircaseDirection {
    case Up, Down
}

class HousePathStaircase {
    
    // MARK: - Properties
    let position: CGPoint
    var destination: HousePathStaircase? = nil
    let direction: HousePathStaircaseDirection
    let useRadius: CGFloat = 50
    
    let visualCircle: SKShapeNode = SKShapeNode()
    let room: HouseRoom
    let path: HousePath
    
    // MARK: - Initializers
    init(pos: CGPoint, dir: HousePathStaircaseDirection, room: HouseRoom, path: HousePath) {
        position = pos
        direction = dir
        self.room = room
        self.path = path
        
        visualCircle.path = CGPathCreateWithEllipseInRect(CGRectMake(pos.x - useRadius, pos.y - useRadius, useRadius*2, useRadius*2), nil)
        visualCircle.strokeColor = SKColor.redColor()
        visualCircle.fillColor = SKColor.clearColor()
        visualCircle.lineWidth = 4.0
    }
    
    // MARK: - Methods
    func setDestination(dest: HousePathStaircase) {
        destination = dest
    }
    
    func pointIsInRange(point: CGPoint) -> Bool {
        let isInRange: Bool = Utilities2D.distanceSquaredFromPoint(position, toPoint: point) < (useRadius * useRadius)
        if isInRange { visualCircle.strokeColor = SKColor.greenColor() }
        else { visualCircle.strokeColor = SKColor.redColor() }
        return isInRange
    }
    
    func useStaircase() -> CGPoint? {
        return destination?.position
    }
    
    func setActive() {
        visualCircle.strokeColor = SKColor.greenColor()
    }
    
    func setInactive() {
        visualCircle.strokeColor = SKColor.redColor()
    }
}