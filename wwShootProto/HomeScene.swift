//
//  HomeScene.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/12/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class HomeScene : SKScene {
    
    let camCon: CameraController = CameraController()
    
    let d_room: SKSpriteNode = SKSpriteNode(imageNamed: "daughter_room")
    let dad: SKSpriteNode = SKSpriteNode(imageNamed: "main")
    
    // initializers
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    override func didMoveToView(view: SKView) {
        anchorPoint = CGPointMake(0.5, 0.5)
        backgroundColor = SKColor.blackColor()
        addChild(camCon)
        
        // set up daughter's room
        camCon.addCameraChild(d_room, withZ: 0)
        
        // set up dad
        dad.anchorPoint = CGPoint(x: 0.5, y: 0.1)
        dad.position = CGPoint(x: 0, y: -120)
        camCon.addCameraChild(dad, withZ: 1)
    }
    
    override func update(currentTime: NSTimeInterval) {

    }
    
}