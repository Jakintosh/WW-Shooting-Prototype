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
    
    var hasSet = false
    
    override init() {
        super.init()
        
        let sun = SKSpriteNode(imageNamed: "sun")
        addChild(sun)
    }
    
    func update() {
        if !hasSet {
            let time = game.timeManager.currentDecimalTime()
            if time < 8.0 {
                hasSet = true
                return
            }
            let pixPerHour: CGFloat = (250/16)
            self.position.y = (250 + (pixPerHour*8)) - (game.timeManager.currentDecimalTime() * pixPerHour)
        }
    }
}