//
//  DayOneFailOne.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/23/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class LighthouseScene : SKFuckScene {
    
    let camCon = CameraController()
    let house = IntroHouse()
    let dad: Dad
    let daughter = Daughter()
    let fire: SKSpriteNode
    let fireFrames: [SKTexture]
    let blackSprite = SKSpriteNode(color: SKColor.blackColor(), size: CGSize(width: 340.0, height: 580.0))
    
    var lastTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    
    var isZoomingOut: Bool = false
    var currentZoom: CGFloat = 1.0
    var cameraRotation: CGFloat = 0.0
    
    var nextSceneInfo: (prev: OrientationScene.SceneType, pass: OrientationScene.SceneResults, name: String)!
    
    override init(size: CGSize) {
        dad = Dad(startingRoom: house.startingRoom)
        
        fireFrames = []
        fireFrames.append(SKTexture(imageNamed: "Fire0"))
        fireFrames.append(SKTexture(imageNamed: "Fire1"))
        fireFrames.append(SKTexture(imageNamed: "Fire2"))
        fire = SKSpriteNode(texture: fireFrames[0])
        fire.runAction( SKAction.repeatActionForever(SKAction.animateWithTextures(fireFrames, timePerFrame: 0.2)))
        fire.position = CGPoint(x: 833.0, y: 15.0)
        fire.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        fire.zPosition = 100
        blackSprite.alpha = 0.0
        blackSprite.userInteractionEnabled = false
        
        super.init(size: size)
        
        camCon.addCameraChild(fire, withZ: 100)
    }
    
    func setup(view: SKView) {
        
        game.interactionManager.setActiveEntity("entity_dad")
        
        // set up camera
        camCon.disableDebug()
        camCon.setRotiation(cameraRotation)
        addChild(camCon)
        
        // set up dad
        var posStartLoc = house.getStartingLocation()
        if let startLoc = posStartLoc {
            dad.position = startLoc
        } else {
            dad.position = CGPointZero
            println("tried to set dad location with nil position")
        }
        
        dad.interactor.completion = {
            
            // load next scene
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                let nextScene = OrientationScene(size: CGSize(width: 320.0, height: 568.0))
                nextScene.transitionToNextScene(self.nextSceneInfo.prev, results: self.nextSceneInfo.pass, nextSceneName: self.nextSceneInfo.name)
                dispatch_async(dispatch_get_main_queue(), {
                    self.runAction(SKAction.sequence([SKAction.waitForDuration(3.0), SKAction.runBlock({
                        let transition = SKTransition.crossFadeWithDuration(1.0)
                        transition.pausesIncomingScene = false
                        transition.pausesOutgoingScene = false
                        view.presentScene(nextScene, transition: transition)
                    })]))
                })
            })
            
            // zoom out
            self.isZoomingOut = true
            self.camCon.runAction(SKAction.customActionWithDuration(3.0, actionBlock: { (node, elapsedTime) in
                (node as CameraController).setScale((elapsedTime/3.0) * (elapsedTime/3.0) * 0.1)
            }))
            
            // fade to black
            self.camCon.addHUDChild(self.blackSprite, withZ: 1000)
            self.blackSprite.runAction(SKAction.fadeAlphaTo(1.0, duration: 3.0))
        }
        
        // set up "daughter"
        daughter.position = CGPoint(x: 980, y: 60)
        daughter.setOrientation(.Left)
        
        // camera stuff
        camCon.lerpSpeed = 0.03
        camCon.addCameraChild(house, withZ: 0)
        camCon.addCameraChild(dad, withZ: 2)
        camCon.addCameraChild(daughter, withZ: 1)
        camCon.setCameraStartingPosition(x: 250, y: 160)
    }
    
    override func didMoveToView(view: SKView) {
        // set up scene
        anchorPoint = CGPointMake(0.5, 0.5)
        backgroundColor = SKColor.blackColor()
        setup(view)
    }
    
    override func willMoveFromView(view: SKView) {
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        // update time
        updateTime(currentTime)
        
        dad.update(deltaTime)
        daughter.update(deltaTime)
        game.interactionManager.update(deltaTime)
        
        // update camera
        if dad.state != .Interacting && !isZoomingOut {
            camCon.setCameraPosition(Utilities2D.addPoint(dad.position, toPoint: CGPoint(x: 100, y: 100)))
            camCon.setScale(1.0)
        }
        
        // update alpha
        let mod = dad.position.x / 1600.0
        var thing = 1.0 - (mod*mod)
        if thing < 0 { thing = 0.0 }
        house.alpha = thing
        
        camCon.update(deltaTime)
    }
    
    func updateTime(currentTime:NSTimeInterval) {
        game.timeManager.update(deltaTime)
        deltaTime = currentTime - lastTime
        if deltaTime > 1.0 { deltaTime = 1.0 }
        lastTime = currentTime
    }
    
    // MARK: - Touches
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch: UITouch = touches.anyObject() as UITouch
        let locationWorld = touch.locationInNode(camCon.rootNode)
        let locationScreen = touch.locationInNode(scene)
        
        dad.touchDown(touch)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch: UITouch = touches.anyObject() as UITouch
        let locationWorld = touch.locationInNode(camCon.rootNode)
        let locationScreen = touch.locationInNode(scene)
        
        dad.touchMove()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch: UITouch = touches.anyObject() as UITouch
        let location = touch.locationInNode(camCon.rootNode)
        let locationScreen = touch.locationInNode(scene)
        
        dad.touchEnd(touch)
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        let touch: UITouch = touches.anyObject() as UITouch
        let location = touch.locationInNode(camCon.rootNode)
        let locationScreen = touch.locationInNode(scene)
        
        dad.touchEnd(touch)
    }
}