//
//  Background.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/16/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class Background : NHCCenteredParallaxNode {
    
//    let sky: NHCSky
    let sky: SKSpriteNode
    
    init(sceneWidth: CGFloat) {
//        let skyTexture = SKTexture(imageNamed: "sky")
//        sky = NHCSky(color: SKColor.whiteColor(), size: skyTexture.size())
//        sky.texture = skyTexture // dont ask
        sky = SKSpriteNode(imageNamed: "sky")
        
        super.init(rangeH: 80, rangeV: 0.0)
        
        self.addChild(sky)
    }
    
    func update(time: CGFloat) {
//        sky.updateShader(time)
    }
}