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
    let bg = SKSpriteNode(imageNamed: "LoadingScreen")
    
    var isLoading: Bool = true
    
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
        bg.zPosition = -1
        addChild(compass)
        addChild(bg)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            game = Game()
            game.animationManager.loadAnimations("home", dataFile: "home_characters")
            game.whaleSpawnManager.loadWhaleAnimations()
            
            SoundManager.initialize()
            
            // set up scene
            let nextScene = OrientationScene(size: CGSize(width: self.screen.short, height: self.screen.long))
            nextScene.transitionToNextScene(.Vertical, results: .Fail, nextSceneName: "GameScene")
            
            dispatch_async(dispatch_get_main_queue(), {
                SoundManager.sharedManager().playMusic("waves.wav", looping: true, fadeIn: true)
                self.isLoading = false
                self.compass.runAction(SKAction.scaleTo(1.0, duration: 0.5))
                self.runAction(SKAction.sequence([SKAction.waitForDuration(1.0), SKAction.runBlock({
                    // set up transition
                    let transition = SKTransition.crossFadeWithDuration(1.0)
                    transition.pausesIncomingScene = true
                    transition.pausesOutgoingScene = true
                    
                    // present scene
                    view.presentScene(nextScene, transition: transition)
                })]))
            })
        })
    }
    
    override func update(currentTime: NSTimeInterval) {
        if isLoading {
            compass.xScale = 1 + (sin(CGFloat(currentTime*2.0)) * 0.1)
            compass.yScale = 1 + (sin(CGFloat(currentTime*2.0)) * 0.1)
        }
    }
    
}