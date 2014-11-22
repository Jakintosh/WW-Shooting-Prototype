//
//  City.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/22/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class City : NHCCenteredParallaxSprite {
    
    init(sceneWidth: CGFloat) {
        super.init(texture: SKTexture(imageNamed: "City"), sceneWidth: sceneWidth, verticalMovement: 500.0)
        self.sprite.position = CGPoint(x: 0, y: 130)
        self.maxZoom = 1.0
    }
    
}