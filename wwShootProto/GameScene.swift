//
//  GameScene.swift
//  wwShootProto
//
//  Created by Jak Tiano on 9/21/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // Problem: The player needs to be able to shoot a whale
    // Soultion: Create whales that jump and can be shot
    
    // Every so many seconds, a whale will jump out of the water
    // When players touch the whale, the whale becomes targeted
    // The closer to the center of the whale they are, the faster the lock on occurs
    // When fully locked, the whale explodes
    
    // properties
    let reticle = SKShapeNode(circleOfRadius: 20)
    var whales = [Whale]()
    var touchLocation: CGPoint?
    
    // initializers
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // functions
    override func didMoveToView(view: SKView) {
        
        // setup reticle
        reticle.fillColor = SKColor.clearColor()
        reticle.strokeColor = SKColor.clearColor()
        reticle.lineWidth = 3
        reticle.zPosition = 200
        addChild(reticle)
        
        // setup water
        let water = SKShapeNode(rect: CGRectMake(0, 0, frame.width, 200))
        water.fillColor = SKColor.blueColor()
        water.zPosition = 100
        addChild(water)
        
        // run actions
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock({self.addWhale(position: nil)}), SKAction.waitForDuration(7)])))
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            touchLocation = touch.locationInNode(self)
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            touchLocation = touch.locationInNode(self)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        touchLocation = nil
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        if let u_touchLocation = touchLocation {
            reticle.position = u_touchLocation
            reticle.position.y += 100
            reticle.strokeColor = SKColor.redColor()
            for whale in whales {
                whale.update(touchPos: reticle.position)
            }
        } else {
            reticle.strokeColor = SKColor.clearColor()
        }
    }
    
    func addWhale(position pos: CGPoint?) {
        let newWhale = Whale()
        if let whalePos = pos {
            newWhale.position = whalePos
        } else {
            newWhale.position.x = newWhale.size.width
            newWhale.position.y = frame.size.height/2 - 400
        }
        addChild(newWhale)
        newWhale.move()
        
        whales += [newWhale]
    }
    
    func removeWhale(#whale: Whale) {
        for i in 0..<whales.count {
            if whales[i] === whale {
                whales.removeAtIndex(i)
                return
            }
        }
    }
}
