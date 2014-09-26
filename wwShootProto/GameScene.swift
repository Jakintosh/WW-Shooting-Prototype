//
//  GameScene.swift
//  wwShootProto
//
//  Created by Jak Tiano on 9/21/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // properties
    var lastTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    
    let reticle = SKShapeNode(circleOfRadius: 20)
    var whales = [Whale]()
    var touchLocation: CGPoint?
    
    var onebutton: SKSpriteNode = SKSpriteNode(color: SKColor.greenColor(), size: CGSizeZero)
    var twobutton: SKSpriteNode = SKSpriteNode(color: SKColor.whiteColor(), size: CGSizeZero)
    var moveType: Int = 0
    
    var partcleManager: ParticleManager?
    
    // initializers
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // functions
    override func didMoveToView(view: SKView) {
        partcleManager = ParticleManager(root: self, numParticles: 375)
        
        onebutton.size = CGSizeMake(frame.width/2, 60)
        twobutton.size = CGSizeMake(frame.width/2, 60)
        onebutton.position = CGPointMake(frame.width/4, frame.height - 30)
        twobutton.position = CGPointMake(frame.width/4 + frame.width/2, frame.height - 30)
        addChild(onebutton)
        addChild(twobutton)
        
        let label1 = SKLabelNode(fontNamed: "HelveticaNeue")
        label1.text = "1"
        label1.position = CGPointMake(frame.width/2 - 110, 738)
        label1.fontSize = 32
        label1.fontColor = SKColor.blackColor()
        label1.horizontalAlignmentMode = .Left
        label1.verticalAlignmentMode = .Center
        label1.zPosition = 200
        addChild(label1)
        
        let label2 = SKLabelNode(fontNamed: "HelveticaNeue")
        label2.text = "2"
        label2.position = CGPointMake(frame.width/2 + 110, 738)
        label2.fontSize = 32
        label2.fontColor = SKColor.blackColor()
        label2.horizontalAlignmentMode = .Left
        label2.verticalAlignmentMode = .Center
        label2.zPosition = 200
        addChild(label2)
        
        // setup reticle
        reticle.fillColor = SKColor.clearColor()
        reticle.strokeColor = SKColor.clearColor()
        reticle.lineWidth = 3
        reticle.zPosition = 200
        addChild(reticle)
        
        // setup water
        let left = SKShapeNode(rect: CGRectMake(0, 0, frame.width, 200))
        left.fillColor = SKColor.blueColor()
        left.strokeColor = SKColor.blueColor()
        left.zPosition = 100
        addChild(left)
        
        // run actions
        //addWhale(position: CGPointMake(frame.width/2, frame.height/2))
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
        for whale in whales {
            whale.disengage()
        }
        for touch: AnyObject in touches {
            if onebutton.containsPoint(touch.locationInNode(self)) {
                onebutton.color = SKColor.greenColor()
                twobutton.color = SKColor.whiteColor()
                moveType = 0
            } else if twobutton.containsPoint(touch.locationInNode(self)) {
                onebutton.color = SKColor.whiteColor()
                twobutton.color = SKColor.greenColor()
                moveType = 1
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        deltaTime = currentTime - lastTime
        if deltaTime > 1.0 { deltaTime = 1.0 }
        println(deltaTime)
        lastTime = currentTime
        
        if let u_touchLocation = touchLocation {
            reticle.position = u_touchLocation
            reticle.position.y += 100
            for whale in whales {
                whale.update(touchPos: reticle.position, dt: deltaTime)
            }
            reticle.strokeColor = SKColor.redColor()
        } else {
            reticle.strokeColor = SKColor.clearColor()
            for whale in whales {
                whale.update(touchPos: nil, dt: deltaTime)
            }
        }
    }
    
    func addWhale(position pos: CGPoint?) {
        let newWhale = Whale(partMan: partcleManager!)
        if let whalePos = pos {
            newWhale.position = whalePos
        } else {
            newWhale.position.x = newWhale.size.width
            newWhale.position.y = frame.size.height/2 - 400
        }
        addChild(newWhale)
        newWhale.move(moveType)
        
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
