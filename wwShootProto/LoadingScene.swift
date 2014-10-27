//
//  LoadingScene.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/16/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit


class LoadingScene : SKScene {
    
    var screen: (short: CGFloat, long: CGFloat) = (0, 0)
    
    override init(size: CGSize) {
        let short: CGFloat = min(size.width, size.height)
        let long: CGFloat = max(size.width, size.height)
        screen = (short, long)
        super.init(size: size)
        
        backgroundColor = SKColor.blackColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func didMoveToView(view: SKView) {
//        NSNotificationCenter.defaultCenter().postNotificationName("NHCSWillTransitionToHome", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("NHCSWillTransitionToWork", object: nil)
        
        runAction(SKAction.sequence([SKAction.waitForDuration(1.0), SKAction.runBlock({
                // set up transition
                let transition = SKTransition.crossFadeWithDuration(1.0)
                transition.pausesIncomingScene = false
                transition.pausesOutgoingScene = false
                
                // set up scene
                let nextScene = GameScene(size: CGSize(width: self.screen.short, height: self.screen.long))
//                let nextScene = HomeScene(size: CGSize(width: self.screen.long, height: self.screen.short))
            
                // present scene
                view.presentScene(nextScene, transition: transition)
            })
        ]))
    }
    
}