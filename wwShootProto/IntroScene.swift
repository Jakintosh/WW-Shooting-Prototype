//
//  IntroScene.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/18/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class IntroScene : SKFuckScene {
    
    let camCon = CameraController()
    let house = IntroHouse()
    let dad: Dad
    let daughter = Daughter()
    
    var lastTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    
    var isZoomingOut: Bool = false
    var currentZoom: CGFloat = 1.0
    
    override init(size: CGSize) {
        dad = Dad(startingRoom: house.startingRoom)
        super.init(size: size)
    }
    
    func setup(view: SKView) {
        
        game.interactionManager.setActiveEntity("entity_dad")
        
        // set up camera
        camCon.disableDebug()
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
            self.isZoomingOut = true
            self.camCon.setCameraPosition(x: 2087, y: 150)
            self.camCon.runAction(SKAction.fadeAlphaTo(0.0, duration: 5.0))
            self.runAction(SKAction.sequence([SKAction.waitForDuration(4.0), SKAction.runBlock({
                NSNotificationCenter.defaultCenter().postNotificationName("NHCSWillTransitionToWork", object: nil)
                let transition = SKTransition.crossFadeWithDuration(1.0)
                transition.pausesOutgoingScene = false
                let nextScene = GameScene(size: CGSize(width: self.frame.height, height: self.frame.width))
                view.presentScene(nextScene, transition: transition)
            })]))
        }
        
        // set up "daughter"
        daughter.position = CGPoint(x: 2150, y: 53)
        daughter.setOrientation(.Left)
        
        // camera stuff
        camCon.lerpSpeed = 0.03
        camCon.addCameraChild(house, withZ: 0)
        camCon.addCameraChild(dad, withZ: 2)
        camCon.addCameraChild(daughter, withZ: 1)
        camCon.setCameraStartingPosition(dad.position)
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
            camCon.setCameraPosition(Utilities2D.addPoint(dad.position, toPoint: CGPoint(x: 0, y: 100)))
            camCon.setScale(1.0)
        }
        if isZoomingOut {
            currentZoom *= 1.008
            camCon.setScale(1.0/(currentZoom*currentZoom))
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