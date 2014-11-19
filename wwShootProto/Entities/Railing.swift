//
//  Railing.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/16/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class Railing : NHCCenteredParallaxSprite {
    
    init(sceneWidth: CGFloat) {
        super.init(texture: SKTexture(imageNamed: "balcony"), sceneWidth: sceneWidth, verticalMovement: 150.0)
        self.maxZoom = 1.5
    }
    
}