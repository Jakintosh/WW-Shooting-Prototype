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
    let compass = SKSpriteNode(imageNamed: "energyHUD")
    
    override init(size: CGSize) {
        let short: CGFloat = min(size.width, size.height)
        let long: CGFloat = max(size.width, size.height)
        screen = (short, long)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(compass)
        
//        game.interactionManager.loadInteractions("home", dataFile: "testDayOne")
//        game.animationManager.loadAnimations("home", dataFile: "home_characters")
        
//        NSNotificationCenter.defaultCenter().postNotificationName("NHCSWillTransitionToHome", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("NHCSWillTransitionToWork", object: nil)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            game = Game()
            game.interactionManager.loadInteractions("home", dataFile: "testDayOne")
            game.animationManager.loadAnimations("home", dataFile: "home_characters")
            game.whaleSpawnManager.loadWhaleAnimations()
            
            // set up scene
//                let nextScene = IntroScene(size: CGSize(width: self.screen.long, height: self.screen.short))
            let nextScene = GameScene(size: CGSize(width: self.screen.short, height: self.screen.long))
//                let nextScene = HomeScene(size: CGSize(width: self.screen.long, height: self.screen.short))
            
            dispatch_async(dispatch_get_main_queue(), {
                self.runAction(SKAction.sequence([SKAction.waitForDuration(1.0), SKAction.runBlock({
                    // set up transition
                    let transition = SKTransition.crossFadeWithDuration(1.0)
                    transition.pausesIncomingScene = false
                    transition.pausesOutgoingScene = false
                    
                    // present scene
                    view.presentScene(nextScene, transition: transition)
                })
                    ]))
                });
            });
    }
    
    override func update(currentTime: NSTimeInterval) {
        compass.zRotation += 0.005
    }
    
}