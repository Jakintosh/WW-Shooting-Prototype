//
//  GameScene.swift
//  wwShootProto
//
//  Created by Jak Tiano on 9/21/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - properties
    
    // properties
    var lastTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    
    // components?
    let reticle = SKShapeNode(circleOfRadius: 20)
    let bg: SKSpriteNode
    var whales = [Whale]()
    var touchLocation: CGPoint?
    var touch: UITouch?
    var char: SKSpriteNode
    
    // garbage
    var onebutton: SKSpriteNode = SKSpriteNode(color: SKColor.whiteColor(), size: CGSizeZero)
    var twobutton: SKSpriteNode = SKSpriteNode(color: SKColor.greenColor(), size: CGSizeZero)
    var moveType: Int = 1
    
    // systems
    var partcleManager: ParticleManager?
    let camCon: CameraController = CameraController()
    let swipeUpGesture: UISwipeGestureRecognizer?
    
    // scene vars
    let areaWidth: Float = 700
    var areaPos: Float = 0
    var currentTimeOfDay: Double = 0
    let totalDayTime: Double = 120
    
    // MARK: - initializers
    required init?(coder aDecoder: NSCoder) {
        char = SKSpriteNode(imageNamed: "idle01")
        bg = SKSpriteNode(color: SKColor.whiteColor(), size: CGSize(width: 1000, height: 1000))
        super.init(coder: aDecoder)
        
        swipeUpGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        swipeUpGesture?.numberOfTouchesRequired = 3
        swipeUpGesture?.direction = .Up
        swipeUpGesture?.cancelsTouchesInView = false
    }
    
    override init(size: CGSize) {
        char = SKSpriteNode(imageNamed: "idle01")
        bg = SKSpriteNode(color: SKColor.whiteColor(), size: CGSize(width: 1000, height: 1000))
        super.init(size: size)
        
        swipeUpGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        swipeUpGesture?.numberOfTouchesRequired = 3
        swipeUpGesture?.direction = .Up
        swipeUpGesture?.cancelsTouchesInView = false
    }
    
    // MARK: - UIKit
    override func didMoveToView(view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.addGestureRecognizer(swipeUpGesture!)
        
        areaPos = areaWidth/2
        
        camCon.zPosition = 0.0
        camCon.setCameraStartingPosition(CGPointMake(CGFloat(areaPos), frame.height/2))
        camCon.disableDebug()
        camCon.connectGestureRecognizers(view)
        self.addChild(camCon)
        
        bg.color = SKColor(hue: 0.03, saturation: 0.6, brightness: 0.8, alpha: 1.00)
        camCon.addHUDChild(bg, withZ: -5000)
        
//        bg.color = SKColor(hue: 0.5, saturation: 0.5, brightness: 0.9, alpha: 1.00)
        bg.runAction(SKAction.sequence([
            SKAction.colorizeWithColor(SKColor(hue: 0.5, saturation: 0.6, brightness: 0.9, alpha: 1.00), colorBlendFactor: 1.0, duration: totalDayTime/5.0),
            SKAction.waitForDuration((totalDayTime/5.0)*3.0),
            SKAction.colorizeWithColor(SKColor(hue: 0.045, saturation: 0.8, brightness: 1.0, alpha: 1.00), colorBlendFactor: 1.0, duration: totalDayTime/5.0),
            SKAction.colorizeWithColor(SKColor(hue: 0.7, saturation: 0.6, brightness: 0.2, alpha: 1.00), colorBlendFactor: 1.0, duration: (totalDayTime/5.0) * 2)
        ]))
        
        partcleManager = ParticleManager(cc: camCon, numParticles: 750)
        
//        onebutton.size = CGSizeMake(frame.width/2, 60)
//        twobutton.size = CGSizeMake(frame.width/2, 60)
//        onebutton.position = CGPointMake(-frame.width/4, frame.height/2 - 30)
//        twobutton.position = CGPointMake(frame.width/4, frame.height/2 - 30)
//        onebutton.alpha = 0.25
//        twobutton.alpha = 0.25
//        camCon.addHUDChild(onebutton, withZ: 0)
//        camCon.addHUDChild(twobutton, withZ: 0)
//        
//        let label1 = SKLabelNode(fontNamed: "HelveticaNeue")
//        label1.text = "debug"
//        label1.position = CGPointMake(-frame.width/4, frame.height/2 - 30)
//        label1.fontSize = 18
//        label1.fontColor = SKColor.blackColor()
//        label1.horizontalAlignmentMode = .Center
//        label1.verticalAlignmentMode = .Center
//        camCon.addHUDChild(label1, withZ: 200)
//        
//        let label2 = SKLabelNode(fontNamed: "HelveticaNeue")
//        label2.text = "game"
//        label2.position = CGPointMake(frame.width/4, frame.height/2 - 30)
//        label2.fontSize = 18
//        label2.fontColor = SKColor.blackColor()
//        label2.horizontalAlignmentMode = .Center
//        label2.verticalAlignmentMode = .Center
//        camCon.addHUDChild(label2, withZ: 200)
        
        // setup reticle
        reticle.fillColor = SKColor.clearColor()
        reticle.strokeColor = SKColor.clearColor()
        reticle.lineWidth = 3
        camCon.addCameraChild(reticle, withZ: 200)
        
//        let bg = SKSpriteNode(imageNamed: "bg")
//        camCon.addHUDChild(bg, withZ: -2000)
        
        let water1 = SKSpriteNode(imageNamed: "wave")
        water1.anchorPoint = CGPointMake(0, 0)
        water1.position = CGPointMake(0, 30)
        camCon.addCameraChild(water1, withZ: 100)
        let water2 = SKSpriteNode(imageNamed: "wave")
        water2.anchorPoint = CGPointMake(0, 0)
        water2.position = CGPointMake(350, 30)
        camCon.addCameraChild(water2, withZ: 100)
//        let water3 = SKSpriteNode(imageNamed: "wave")
//        water3.anchorPoint = CGPointMake(0, 0)
//        water3.position = CGPointMake(700, 30)
//        camCon.addCameraChild(water3, withZ: 100)
        let railing = SKSpriteNode(imageNamed: "rail")
        railing.anchorPoint = CGPointMake(0.5, 0)
        railing.position = CGPoint(x: 0, y: -frame.height/2)
        railing.name = "rail"
        camCon.addHUDChild(railing, withZ: 0)
        char.anchorPoint = CGPoint(x: 0.5, y: 0)
        char.xScale = 2.0
        char.yScale = 2.0
        char.position = CGPoint(x: 0, y: -frame.height/2 - 10)
        camCon.addHUDChild(char, withZ: 1)
        
        // run actions
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock({self.addWhale(position: nil)}), SKAction.waitForDuration(10)])))
    }
    
    override func willMoveFromView(view: SKView) {
        view.removeGestureRecognizer(swipeUpGesture!)
    }
    
    
    // MARK: - Touch
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            touchLocation = touch.locationInNode(camCon.rootNode)
            self.touch = touch as? UITouch
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            touchLocation = touch.locationInNode(camCon.rootNode)
            self.touch = touch as? UITouch
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        touchLocation = nil
        touch = nil
        
        for whale in whales {
            whale.disengage()
        }
        for touch: AnyObject in touches {
            if onebutton.containsPoint(touch.locationInNode(self)) {
                onebutton.color = SKColor.greenColor()
                twobutton.color = SKColor.whiteColor()
                camCon.enableDebug()
            } else if twobutton.containsPoint(touch.locationInNode(self)) {
                onebutton.color = SKColor.whiteColor()
                twobutton.color = SKColor.greenColor()
                camCon.disableDebug()
            }
        }
    }
    
    // MARK: - Logic
    override func update(currentTime: CFTimeInterval) {
        
        deltaTime = currentTime - lastTime
        if deltaTime > 1.0 { deltaTime = 1.0 }
//        println(deltaTime)
        
        lastTime = currentTime
        
        currentTimeOfDay += deltaTime
        
        if let fucktouch = touch {
            touchLocation = fucktouch.locationInNode(camCon.rootNode)
            
            let sceneX = fucktouch.locationInNode(scene).x
            let limit = frame.width/4
            if sceneX > limit {
                let mod: Float = Float((sceneX-limit)/limit) * Float((sceneX-limit)/limit) + 1
                areaPos += mod
            } else if sceneX < -limit {
                let mod: Float = Float((sceneX+limit)/limit) * Float((sceneX+limit)/limit) + 1
                areaPos -= mod
            }
        }
        
//        let thing: Double = sin(currentTime/4) * (Double(areaWidth/2) - Double(frame.width/2))
//        camCon.setCameraPosition(CGPoint(x: thing + Double(areaWidth/2), y: Double(frame.height/2)))
        
        if areaPos > areaWidth - Float(frame.width/2) {
            areaPos = areaWidth - Float(frame.width/2)
        }
        if areaPos < Float(frame.width/2) {
            areaPos = Float(frame.width/2)
        }
        
        camCon.setCameraPosition(CGPoint(x: Double(areaPos), y: Double(frame.height/2)))
        
        var retPos: CGPoint? = nil
        
        if let u_touchLocation = touchLocation {
            reticle.position = u_touchLocation
            reticle.position.y += 100
            retPos = reticle.position
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
        
        partcleManager?.updateSuction(touchPos: retPos, dt: deltaTime)
        
        camCon.update(deltaTime)
    }
    
    func addWhale(position pos: CGPoint?) {
        let newWhale = Whale(partMan: partcleManager!)
        camCon.addCameraChild(newWhale, withZ: 0)
        whales += [newWhale]
        
        if let whalePos = pos {
            newWhale.position = whalePos
        } else {
            newWhale.position.y = frame.size.height/2 - 400
            if arc4random_uniform(2) != 0 {
                newWhale.position.x = CGFloat(areaWidth/2 - 200)
                newWhale.move(moveType, direction: 1)
            } else {
                newWhale.position.x = CGFloat(areaWidth/2 + 200)
                newWhale.move(moveType, direction: -1)
            }
        }
    }
    
    func removeWhale(#whale: Whale) {
        for i in 0..<whales.count {
            if whales[i] === whale {
                whales.removeAtIndex(i)
                return
            }
        }
    }
    
    func handleSwipe(gestureRecognizer: UISwipeGestureRecognizer) {
        let transitionDuration = 1.0
        var transition: SKTransition = SKTransition.fadeWithDuration(transitionDuration)
        transition.pausesIncomingScene = false
        transition.pausesOutgoingScene = false
        let homeScene = HomeScene(size: CGSize(width: frame.height, height: frame.width))
        view?.presentScene(homeScene, transition: transition)
        homeScene.runAction(SKAction.sequence([SKAction.waitForDuration(transitionDuration/2.0), SKAction.runBlock({ NSNotificationCenter.defaultCenter().postNotificationName("NHCSWillTransitionToHome", object: nil) })]))
    }
}
