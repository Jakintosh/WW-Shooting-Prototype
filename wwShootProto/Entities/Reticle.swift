//
//  Reticle.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/16/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class Reticle : NHCNode {
    
    override init() {
        super.init()
        
        // setup reticle
        let reticleA = SKShapeNode()
        let pathA = CGPathCreateMutable()
        CGPathMoveToPoint(pathA, nil, -10, -10)
        CGPathAddLineToPoint(pathA, nil, 10, 10)
        
        reticleA.path = pathA
        reticleA.strokeColor = SKColor.redColor()
        reticleA.fillColor = SKColor.clearColor()
        self.addChild(reticleA)
        
        let reticleB = SKShapeNode()
        let pathB = CGPathCreateMutable()
        CGPathMoveToPoint(pathB, nil, -10, 10)
        CGPathAddLineToPoint(pathB, nil, 10, -10)
        
        reticleB.path = pathB
        reticleB.strokeColor = SKColor.redColor()
        reticleB.fillColor = SKColor.clearColor()
        self.addChild(reticleB)
        
        self.hidden = true
    }
    
    func update(touchLocation: CGPoint?) {
        if let u_touchLocation = touchLocation {
            self.hidden = false
            self.position = u_touchLocation
            self.position.y += 100
        } else {
            self.hidden = true
            self.position = CGPoint(x: -9999, y: -9999)
        }
    }
    
}