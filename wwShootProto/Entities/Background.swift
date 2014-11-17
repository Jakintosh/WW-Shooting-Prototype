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
    
    let sky: NHCSky
    
    init(sceneWidth: CGFloat) {
        let skyTexture = SKTexture(imageNamed: "sky")
        sky = NHCSky(color: SKColor.whiteColor(), size: skyTexture.size())
        sky.texture = skyTexture // dont ask
        
        super.init(range: sky.size.width - sceneWidth)
        
        self.addChild(sky)
    }
    
    func update(time: CGFloat) {
        sky.updateShader(time)
    }
}