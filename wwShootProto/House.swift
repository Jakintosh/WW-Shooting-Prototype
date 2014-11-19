//
//  HouseFloor.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/17/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class NHCNode : SKNode {
    func getScenePosition() -> CGPoint {
        return scene!.childNodeWithName("/CamCon/Zoom_Node/Root_Node")!.convertPoint(position, fromNode: self)
    }
}

// MARK: -
class House : NHCNode {
    
    // MARK:   Properties
    var startingRoom: HouseRoom!
    
    // MARK:   Components
    var floors: [HouseFloor] = [HouseFloor]()
    
    // MARK:   Initializers
    override init() {
        super.init()
        setup()
    }
    
    func setup() {
        let attic           = SKSpriteNode(imageNamed: "Attic")
        let bathroom        = SKSpriteNode(imageNamed: "Bathroom")
        let kitchen         = SKSpriteNode(imageNamed: "Kitchen")
        let livingRoom      = SKSpriteNode(imageNamed: "LivingRoom")
        let mudRoom         = SKSpriteNode(imageNamed: "MudRoom")
        let office          = SKSpriteNode(imageNamed: "Office")
        let parentsRoom     = SKSpriteNode(imageNamed: "ParentsRoom")
        
        let counter         = SKSpriteNode(imageNamed: "islandCounter")
        let tvTable         = SKSpriteNode(imageNamed: "tvTable")
        
        let doorway1_1  = DoorwayStair(type: .Bottom)
        let doorway2_1  = DoorwayStair(type: .Bottom)
        let doorway2_2  = DoorwayStair(type: .Top)
        let doorway3_2  = DoorwayStair(type: .Top)
        
        doorway1_1.position = CGPoint(x: 820, y: 100)
        doorway2_1.position = CGPoint(x: 798, y: 405)
        doorway2_2.position = CGPoint(x: 1373, y: 405)
        doorway3_2.position = CGPoint(x: 1375, y: 718)
        
        let ladder = Ladder()
        ladder.position = CGPoint(x: 1262, y: 885)
        
        // initialize first floor
        let floor1      = HouseFloor(height: 355, floorY: 70, yPosition: 0)
        let path1_1     = floor1.addPath(left: 205, right: 1585)
        let room1_1     = floor1.addRoom(name: "bathroom", xPos: 0,    width: 295,  path: path1_1)
        let room1_2     = floor1.addRoom(name: "kitchen",  xPos: 295,  width: 1065, path: path1_1)
        let room1_3     = floor1.addRoom(name: "mudroom",  xPos: 1360, width: 325,  path: path1_1)
        let stair1_1    = path1_1.addStaircase(820, room: room1_2, dir: .Up, doorway: doorway1_1, ladder: nil)
        floors.append(floor1)
        
        // initialize second floor
        let floor2      = HouseFloor(height: 310, floorY: 25, yPosition: 355)
        let path2_1     = floor2.addPath(left: 70, right: 1400)
        let room2_1     = floor2.addRoom(name: "office",     xPos: 0,   width: 530, path: path2_1)
        let room2_2     = floor2.addRoom(name: "livingroom", xPos: 540, width: 925, path: path2_1)
        let stair2_1    = path2_1.addStaircase(800,  room: room2_2, dir: .Up, doorway: doorway2_1, ladder: nil)
        let stair2_2    = path2_1.addStaircase(1373, room: room2_2, dir: .Down, doorway: doorway2_2, ladder: nil)
        floors.append(floor2)
        
        // initialize third floor
        let floor3      = HouseFloor(height: 305, floorY: 30, yPosition: 665)
        let path3_1     = floor3.addPath(left: 840, right: 1400)
        let room3_1     = floor3.addRoom(name: "bedroom", xPos: 540,  width: 520, path: path3_1)
        let room3_2     = floor3.addRoom(name: "hallway", xPos: 1060, width: 405, path: path3_1)
        let stair3_1    = path3_1.addStaircase(1262, room: room3_2, dir: .Up, doorway: nil, ladder: ladder)
        let stair3_2    = path3_1.addStaircase(1375, room: room3_2, dir: .Down, doorway: doorway3_2, ladder: nil)
        floors.append(floor3)
        
        // initialize fourth floor
        let floor4      = HouseFloor(height: 300, floorY: 30, yPosition: 970)
        let path4_1     = floor4.addPath(left: 600, right: 1185)
        let room4_1     = floor4.addRoom(name: "daughter", xPos: 540,  width: 810, path: path4_1)
        let stair4_1    = path4_1.addStaircase(1185, room: room4_1, dir: .Down, doorway: nil, ladder: ladder)
        floors.append(floor4)
        
        // set up stair connections
        stair1_1.setDestination(stair2_2)
        stair2_2.setDestination(stair1_1)
        
        stair2_1.setDestination(stair3_2)
        stair3_2.setDestination(stair2_1)
        
        stair3_1.setDestination(stair4_1)
        stair4_1.setDestination(stair3_1)
        
        // set starting locations
        startingRoom = room4_1
        
        // set up the house sprite
        attic.anchorPoint       = CGPointZero
        bathroom.anchorPoint    = CGPointZero
        kitchen.anchorPoint     = CGPointZero
        livingRoom.anchorPoint  = CGPointZero
        mudRoom.anchorPoint     = CGPointZero
        office.anchorPoint      = CGPointZero
        parentsRoom.anchorPoint = CGPointZero
        
        bathroom.position    = CGPoint(x: 26,   y: 20)
        kitchen.position     = CGPoint(x: 295,  y: 25)
        mudRoom.position     = CGPoint(x: 1358, y: 19)
        office.position      = CGPoint(x: 0,    y: 335)
        livingRoom.position  = CGPoint(x: 540,  y: 335)
        parentsRoom.position = CGPoint(x: 540,  y: 645)
        attic.position       = CGPoint(x: 540,  y: 935)
        
        bathroom.zPosition    = -4
        kitchen.zPosition     = -4
        mudRoom.zPosition     = -4
        office.zPosition      = -3
        livingRoom.zPosition  = -3
        parentsRoom.zPosition = -2
        attic.zPosition       = -1
        
        name = "Root_House"
        
        // add children
        addChild(floor1)
        addChild(floor2)
        addChild(floor3)
        addChild(floor4)
        addChild(doorway1_1)
        addChild(doorway2_1)
        addChild(doorway2_2)
        addChild(doorway3_2)
        addChild(attic)
        addChild(bathroom)
        addChild(kitchen)
        addChild(livingRoom)
        addChild(mudRoom)
        addChild(office)
        addChild(parentsRoom)
        addChild(ladder)
        
        counter.position = CGPoint(x: 303, y: 60)
        tvTable.position = CGPoint(x: 479, y: 69)
        
        counter.zPosition = 10
        tvTable.zPosition = 10
        
        kitchen.addChild(counter)
        livingRoom.addChild(tvTable)
        
        addChild(game.interactionManager.debugLayer)
        
        floor1.hidden = true
        floor2.hidden = true
        floor3.hidden = true
        floor4.hidden = true
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
    }
    
}

class IntroHouse : House {
    
    override func setup() {
        
        let hallway = SKSpriteNode(color: SKColor.whiteColor(), size: CGSizeMake(2000, 355))
        let hallwayEnter = SKSpriteNode(imageNamed: "Hallway_enter")
        let hallwayBuffer0 = SKSpriteNode(imageNamed: "Hallway_buffer")
        let hallwayBuffer1 = SKSpriteNode(imageNamed: "Hallway_buffer")
        let hallwayBuffer2 = SKSpriteNode(imageNamed: "Hallway_buffer")
        let hallwayBuffer3 = SKSpriteNode(imageNamed: "Hallway_buffer")
        let hallwayBuffer4 = SKSpriteNode(imageNamed: "Hallway_buffer")
        let hallwayBuffer5 = SKSpriteNode(imageNamed: "Hallway_buffer")
        let hallwayBuffer6 = SKSpriteNode(imageNamed: "Hallway_buffer")
        let hallwayBuffer7 = SKSpriteNode(imageNamed: "Hallway_buffer")
        
        // initialize first floor
        let floor1      = HouseFloor(height: 355, floorY: 50, yPosition: 0)
        let path1_1     = floor1.addPath(left: 75, right: 1925)
        let room1_1     = floor1.addRoom(name: "hallway_start", xPos: 0,    width: 300,  path: path1_1)
        let room1_2     = floor1.addRoom(name: "hallway",       xPos: 300,    width: 1700,  path: path1_1)
        floors.append(floor1)
        
        // set starting locations
        startingRoom = room1_1
        
        // set up the house sprite
        name = "Root_House"
        hallwayEnter.position = CGPointZero
        hallwayEnter.anchorPoint = CGPointZero
        hallwayBuffer0.position = CGPoint(x: 534, y: 0)
        hallwayBuffer0.anchorPoint = CGPointZero
        hallwayBuffer1.position = CGPoint(x: 534 + 186, y: 0)
        hallwayBuffer1.anchorPoint = CGPointZero
        hallwayBuffer2.position = CGPoint(x: 534 + (186 * 2), y: 0)
        hallwayBuffer2.anchorPoint = CGPointZero
        hallwayBuffer3.position = CGPoint(x: 534 + (186 * 3), y: 0)
        hallwayBuffer3.anchorPoint = CGPointZero
        hallwayBuffer4.position = CGPoint(x: 534 + (186 * 4), y: 0)
        hallwayBuffer4.anchorPoint = CGPointZero
        hallwayBuffer5.position = CGPoint(x: 534 + (186 * 5), y: 0)
        hallwayBuffer5.anchorPoint = CGPointZero
        hallwayBuffer6.position = CGPoint(x: 534 + (186 * 6), y: 0)
        hallwayBuffer6.anchorPoint = CGPointZero
        hallwayBuffer7.position = CGPoint(x: 534 + (186 * 7), y: 0)
        hallwayBuffer7.anchorPoint = CGPointZero
        
        // add children
//        addChild(floor1)
        addChild(hallwayEnter)
        addChild(hallwayBuffer0)
        addChild(hallwayBuffer1)
        addChild(hallwayBuffer2)
        addChild(hallwayBuffer3)
        addChild(hallwayBuffer4)
        addChild(hallwayBuffer5)
        addChild(hallwayBuffer6)
        addChild(hallwayBuffer7)
        
        floor1.hidden = true
    }
    
}

class Ladder : NHCNode {
    
    let ladderSprite = SKSpriteNode(imageNamed: "ladder")
    let climb1 = SKSpriteNode(imageNamed: "dad_ladder1")
    let climb2 = SKSpriteNode(imageNamed: "dad_ladder2")
    
    override init() {
        super.init()
        
        climb1.zPosition = 1
        climb2.zPosition = 1
        
        climb1.position = CGPoint(x: 0, y: -63)
        climb2.position = CGPoint(x: 0, y:  12)
        
        addChild(ladderSprite)
    }
    
    func ascend() {
        runAction( SKAction.sequence( [ SKAction.runBlock( { self.show(self.climb1) } ),
                                        SKAction.waitForDuration(1.75),
                                        SKAction.runBlock( { self.show(self.climb2) } ) ]))
    }
    
    func descend() {
        runAction( SKAction.sequence( [ SKAction.runBlock( { self.show(self.climb2) } ),
                                        SKAction.waitForDuration(1.75),
                                        SKAction.runBlock( { self.show(self.climb1) } ) ]))
    }
    
    func show(sprite: SKSpriteNode) {
        addChild(sprite)
        sprite.alpha = 0.0
        sprite.runAction(SKAction.sequence([ SKAction.fadeAlphaTo(1.0, duration: 1.0), SKAction.fadeAlphaTo(0.0, duration: 1.0) ]), completion: { sprite.removeFromParent() })
    }
    
}

enum DoorwayPosition {
    case Top, Bottom
}

class DoorwayStair : NHCNode {
    
    var type: DoorwayPosition
    let departSprites: [SKSpriteNode]
    let arriveSprites: [SKSpriteNode]
    
    init(type: DoorwayPosition) {
        
        self.type = type
        
        switch type
        {
            case .Top:
                departSprites = [SKSpriteNode(imageNamed: "dad_stairs_down_depart1"), SKSpriteNode(imageNamed: "dad_stairs_down_depart2"), SKSpriteNode(imageNamed: "dad_stairs_down_depart3")]
                arriveSprites = [SKSpriteNode(imageNamed: "dad_stairs_down_arrive0"), SKSpriteNode(imageNamed: "dad_stairs_down_arrive1"), SKSpriteNode(imageNamed: "dad_stairs_down_arrive2")]
                
            case .Bottom:
                departSprites = [SKSpriteNode(imageNamed: "dad_stairs_up_depart1"), SKSpriteNode(imageNamed: "dad_stairs_up_depart2"), SKSpriteNode(imageNamed: "dad_stairs_up_depart3")]
                arriveSprites = [SKSpriteNode(imageNamed: "dad_stairs_up_arrive1"), SKSpriteNode(imageNamed: "dad_stairs_up_arrive2"), SKSpriteNode(imageNamed: "dad_stairs_up_arrive3")]
        }
        
        super.init()
        
//        let defaultSprite = SKSpriteNode(imageNamed: "dad_stairs0")
//        defaultSprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
//        addChild(defaultSprite)
        
        for sprite in departSprites {
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        }
        for sprite in arriveSprites {
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        }
    }
    
    func arrive(wait: NSTimeInterval) {
        runAction( SKAction.sequence( [ SKAction.waitForDuration(wait),
                                        SKAction.runBlock( { self.show(self.arriveSprites[0]) } ),
                                        SKAction.waitForDuration(0.75),
                                        SKAction.runBlock( { self.show(self.arriveSprites[1]) } ),
                                        SKAction.waitForDuration(0.75),
                                        SKAction.runBlock( { self.show(self.arriveSprites[2]) } ) ]))
    }
    
    func depart() {
        runAction( SKAction.sequence( [ SKAction.runBlock( { self.show(self.departSprites[0]) } ),
                                        SKAction.waitForDuration(0.75),
                                        SKAction.runBlock( { self.show(self.departSprites[1]) } ),
                                        SKAction.waitForDuration(0.75),
                                        SKAction.runBlock( { self.show(self.departSprites[2]) } ) ]))
    }
    
    func show(sprite: SKSpriteNode) {
        addChild(sprite)
        sprite.alpha = 0.0
        sprite.runAction(SKAction.sequence([ SKAction.fadeAlphaTo(1.0, duration: 0.5), SKAction.fadeAlphaTo(0.0, duration: 0.5) ]), completion: { sprite.removeFromParent() })
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
    func addStaircase(xPos: CGFloat, room: HouseRoom, dir: HousePathStaircaseDirection, doorway: DoorwayStair?, ladder: Ladder?) -> HousePathStaircase {
        let newStairs = HousePathStaircase(pos: CGPoint(x: xPos, y: yPosition), dir: dir, room: room, path: self, doorway: doorway, ladder: ladder)
        stairs.append(newStairs)
        visualPath.addChild(newStairs.visualCircle)
        return newStairs
    }
    
    func getNewX(currentX: CGFloat, movement: CGFloat) -> ( newX: CGFloat , atEnd: Bool ) {
        let newX = Utilities2D.clamp(currentX + movement, min: leftEndpoint, max: rightEndpoint)
        var atEnd = false
        if newX == leftEndpoint || newX == rightEndpoint {
            atEnd = true
        }
        return (newX, atEnd)
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
    
    let doorwayAnimation: DoorwayStair?
    let ladder: Ladder?
    
    let visualCircle: SKShapeNode = SKShapeNode()
    let room: HouseRoom
    let path: HousePath
    
    // MARK: - Initializers
    init(pos: CGPoint, dir: HousePathStaircaseDirection, room: HouseRoom, path: HousePath, doorway: DoorwayStair?, ladder: Ladder?) {
        position = pos
        direction = dir
        doorwayAnimation = doorway
        self.ladder = ladder
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
        if let door = doorwayAnimation {
            door.depart()
            if let dest = destination {
                if let door2 = dest.doorwayAnimation {
                    door2.arrive(4.5)
                }
            }
        }
        if let lad = ladder {
            switch direction {
            case .Up:
                lad.ascend()
                
            case .Down:
                lad.descend()
            }
        }
        return destination?.position
    }
    
    func setActive() {
        visualCircle.strokeColor = SKColor.greenColor()
    }
    
    func setInactive() {
        visualCircle.strokeColor = SKColor.redColor()
    }
}