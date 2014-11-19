//
//  NHCCenteredParallaxNode.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/16/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class NHCCenteredParallaxNode : NHCNode {
    
    // properties
    var normalizedPosition: CGFloat = 0.0
    var horizontalMovementRange: CGFloat
    var verticalMovementRange: CGFloat
    var basePosition: CGPoint = CGPointZero {
        didSet {
            self.position = self.basePosition
        }
    }
    
    init(rangeH: CGFloat, rangeV: CGFloat) {
        horizontalMovementRange = rangeH
        verticalMovementRange = rangeV
        super.init()
    }
    
    func updatePosition(modX: CGFloat, modY: CGFloat) {
        // mod = -1.0 -> 1.0
        position.x = basePosition.x + ( -modX * (horizontalMovementRange/2.0) )
        position.y = basePosition.y + ( -modY * (verticalMovementRange/2.0) )
    }
    
}

class NHCCenteredParallaxSprite : NHCCenteredParallaxNode {
    
    // components
    let sprite: SKSpriteNode
    let sceneWidth: CGFloat
    let minZoom: CGFloat
    var maxZoom: CGFloat
    
    let insetAmt: CGFloat = 0.95
    
    init(texture: SKTexture, sceneWidth: CGFloat, verticalMovement: CGFloat) {
        self.sprite = SKSpriteNode(texture: texture)
        self.sceneWidth = sceneWidth
        
        minZoom = sceneWidth/sprite.size.width
        maxZoom = 1.0
        
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init(rangeH: sprite.size.width - sceneWidth, rangeV: verticalMovement)
        
        addChild(sprite)
    }
    
    override func updatePosition(modX: CGFloat, modY: CGFloat) {
        // modX = -1.0 -> 1.0, modY = 0.0 -> 1.0
        let moveRange = ((sprite.size.width) * xScale) - sceneWidth
        position.x = basePosition.x + ( -modX * insetAmt * (moveRange/2.0) )
        position.y = basePosition.y + ( -modY * (verticalMovementRange/2.0) )
    }
    
    func updateZoom(mod: CGFloat) {
        let range = maxZoom - minZoom
        let newZoom = range * mod + minZoom
        xScale = newZoom
        yScale = newZoom
    }
}