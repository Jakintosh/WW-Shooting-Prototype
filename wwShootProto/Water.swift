//
//  Water.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/16/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class Water : NHCCenteredParallaxSprite {
    
    init(sceneWidth: CGFloat) {
        super.init(texture: SKTexture(imageNamed: "water"), sceneWidth: sceneWidth)
        self.maxZoom = 1.2
    }
    
}