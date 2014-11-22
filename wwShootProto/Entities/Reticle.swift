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
    
    enum ReticleState {
        case ZoomedIn, ZoomedOut
    }
    
    // parts
    let reticle: SKSpriteNode
//    let bigReticle: SKSpriteNode
    
    // properties
    var targetPosition: CGPoint = CGPointZero
    var currentState: ReticleState = .ZoomedOut {
        didSet {
            switch (self.currentState)
            {
                case .ZoomedIn:
                    break
                    
                case .ZoomedOut:
                    break
            }
        }
    }
    
    override init() {
        
        reticle = SKSpriteNode(imageNamed: "reticle")
//        bigReticle = SKSpriteNode(imageNamed: "ui_full")
        
        super.init()
        
        // setup reticle
        reticle.zPosition = 1
//        bigReticle.alpha = 0.6
        
        addChild(reticle)
//        addChild(bigReticle)
        
        self.hidden = true
    }
    
    func update(touchLocation: CGPoint?) {
        if let u_touchLocation = touchLocation {
//            self.reticle.hidden = false
//            self.bigReticle.hidden = true
//            self.hidden = false
            self.position = u_touchLocation
            self.position.y += 50
            self.targetPosition = self.position
        } else {
            self.hidden = true
            self.position = CGPoint(x: -9999, y: -9999)
        }
//        else {
////            self.hidden = true
////            self.position = CGPoint(x: -9999, y: -9999)
//            self.reticle.hidden = true
//            self.bigReticle.hidden = false
//            self.position = CGPoint(x: 0, y: 125)
//        }
    }
    
}