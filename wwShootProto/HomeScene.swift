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
    
    var lastTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    
    let dad: Dad
    let daughter: NHCNode = NHCNode()
    
    var debug: Bool = false
    let timeText: SKLabelNode = SKLabelNode()
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
        camCon.connectGestureRecognizers(view)
        
        // set up scene
        anchorPoint = CGPointMake(0.5, 0.5)
        backgroundColor = SKColor.blackColor()

        setup()
        
    }
    
    override func willMoveFromView(view: SKView) {
        view.removeGestureRecognizer(tripleTap!)
        camCon.disconnectGestureRecognizers(view)
    }
    
    func setup() {
        
        game.interactionManager.setActiveEntity("entity_dad")
        
        // set up camera
        camCon.disableDebug()
        addChild(camCon)
        
        // time hud
        timeText.position = CGPoint(x: -frame.size.width/2 + 20, y: frame.size.height/2 - 20)
        timeText.horizontalAlignmentMode = .Left
        timeText.verticalAlignmentMode = .Top
        timeText.fontSize = 16.0
        
        // set up dad
        var posStartLoc = house.getStartingLocation()
        if let startLoc = posStartLoc {
            dad.position = startLoc
        } else {
            dad.position = CGPointZero
            println("tried to set dad location with nil position")
        }
        
        // set up "daughter"
        daughter.position = CGPoint(x: 670, y: 970)
        let d_int = game.interactionManager.registerEntity("entity_daughter", owner: daughter)
        daughter.addChild(d_int.displayNode)
        
        // camera stuff
        camCon.addHUDChild(timeText, withZ: 0)
        camCon.addCameraChild(house, withZ: 0)
        camCon.addCameraChild(dad, withZ: 2)
        camCon.addCameraChild(daughter, withZ: 1)
        camCon.setCameraStartingPosition(x: 0, y: 0)
    }
    
    override func update(currentTime: NSTimeInterval) {
        // update time
        updateTime(currentTime)
        
        dad.update(deltaTime)
        game.interactionManager.update(deltaTime)
        
        timeText.text = game.timeManager.currentTimeString()
        
        // update camera
        if !debug {
            if dad.canMove {
                camCon.setCameraPosition(Utilities2D.addPoint(dad.position, toPoint: CGPoint(x: 0, y: 100)))
                camCon.setScale(1.0)
            }
        }
        camCon.update(deltaTime)
    }
    
    func updateTime(currentTime:NSTimeInterval) {
        game.timeManager.update(deltaTime)
        //println(game.timeManager.currentTimeString())
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
        
        if let targetPoint = house.getNewLocation(location, fromRoom: dad.currentRoom) {
            dad.moveToPoint(targetPoint)
        }
    }
    
    func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        house.toggleDebug()
        debug = !debug
        camCon.enableDebug()
    }
}