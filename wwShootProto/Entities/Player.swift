//
//  Player.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/16/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class Player : NHCNode {
    
    let animationNode = NHCNode()
    
    override init() {
        super.init()
        
        setupAnimationNode()
        addChild(animationNode)
    }
    
    func setupAnimationNode() {
        let char = SKSpriteNode(imageNamed: "idle01")
        char.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        char.xScale = 2.5
        char.yScale = 2.5
        animationNode.addChild(char)
    }
    
}