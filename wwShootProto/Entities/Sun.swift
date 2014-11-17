//
//  Sun.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/16/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class Sun : NHCNode {
    
    override init() {
        super.init()
        
        let sun = SKSpriteNode(imageNamed: "sun")
        addChild(sun)
    }
    
    func update() {
        self.position.y = (game.timeManager.currentDecimalTime() * -150.0) + 2700
    }
    
}