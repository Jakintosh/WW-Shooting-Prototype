//
//  HomeScene.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/12/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class SKFuckScene : SKScene {/* why even */}

class HomeScene : SKFuckScene {
    
    let camCon: CameraController = CameraController()
    let house: House = House()
    let interactionManager: InteractionManager = InteractionManager(fileName: "testDayOne")
    
    var lastTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    
    let dad: Dad
    
    var debug: Bool = false
    let tripleTap: UITapGestureRecognizer? = nil
    
    override init(size: CGSize) {
        dad = Dad(startingRoom: house.startingRoom)
        super.init(size: size)
        
        tripleTap = UITapGestureRecognizer(target: self, action: "handleTap:")
        tripleTap!.numberOfTouchesRequired = 3
        tripleTap!.numberOfTapsRequired = 1
    }
    
    override func didMoveToView(view: SKView) {
        
        view.addGestureRecognizer(tripleTap!)
        
        // set up scene
        anchorPoint = CGPointMake(0.5, 0.5)
        backgroundColor = SKColor.blackColor()
        
        // set up camera
        camCon.connectGestureRecognizers(view)
        camCon.disableDebug()
        addChild(camCon)
        
        // set up dad
        var posStartLoc = house.getStartingLocation()
        if let startLoc = posStartLoc {
                dad.position = startLoc
        } else {
            dad.position = CGPointZero
            println("tried to set dad location with nil position")
        }
        dad.xScale = 0.85
        dad.yScale = 0.85
        
        camCon.addCameraChild(house, withZ: 0)
        camCon.addCameraChild(dad, withZ: 1)
        camCon.setCameraStartingPosition(x: 0, y: 0)
    }
    
    override func willMoveFromView(view: SKView) {
        view.removeGestureRecognizer(tripleTap!)
        camCon.disconnectGestureRecognizers(view)
    }
    
    override func update(currentTime: NSTimeInterval) {
        // update time
        updateTime(currentTime)
        
        dad.update(deltaTime)
        
        // update camera
        if !debug {
            camCon.setCameraPosition(Utilities2D.addPoint(dad.position, toPoint: CGPoint(x: 0, y: 100)))
            camCon.setScale(1.0)
        }
        camCon.update(deltaTime)
    }
    
    func updateTime(currentTime:NSTimeInterval) {
        deltaTime = currentTime - lastTime
        if deltaTime > 1.0 { deltaTime = 1.0 }
        lastTime = currentTime
    }
    
    // MARK: - Touches
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch: UITouch = touches.anyObject() as UITouch
        let location = touch.locationInNode(camCon.rootNode)

//        dad.handleTouches(touches)
        dad.walk()
        
        if let targetPoint = house.newPositionForPoint(location, fromRoom: dad.currentRoom) {
            dad.moveToPoint(targetPoint)
        }
    }
    
    func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        house.toggleDebug()
        debug = !debug
        camCon.enableDebug()
    }
}