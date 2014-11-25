//
//  OrientationScene.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/22/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion

class OrientationScene : SKFuckScene {
    
    enum SceneType {
        case Vertical, Horizontal
    }
    
    enum SceneResults {
        case Pass, Fail
    }
    
    enum RotationType {
        case CCW, CW, Nope
    }
    
    var lastTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    
    var motionManager: CMMotionManager = CMMotionManager()
    var compass: SKSpriteNode = SKSpriteNode(imageNamed: "energyHUD")
    
    var nextSceneName: String!
    
    var allowedRotation: RotationType = .Nope
    
    var lastRotation: Double = 0.0
    var rotation: Double = 0.0
    
    var shouldTransition: Bool = false
    var isLoaded: Bool = false
    var transitionScene: SKScene?
    
    override init(size: CGSize) {
        super.init(size: size)
        addChild(compass)
        motionManager.startAccelerometerUpdates()
    }
    
    func transitionToNextScene(prevScene: SceneType, results: SceneResults, nextSceneName: String) {
        if prevScene == .Vertical {
            switch results
            {
                case .Pass:
                    let rotateAction = SKAction.rotateByAngle(CGFloat(M_PI/2.0), duration: 1.5)
                    rotateAction.timingMode = .EaseInEaseOut
                    compass.runAction(rotateAction, completion: {
                        self.shouldTransition = true
                    })
                    
                case .Fail:
                    let rotateAction = SKAction.rotateByAngle(CGFloat(-M_PI/2.0), duration: 1.5)
                    rotateAction.timingMode = .EaseInEaseOut
                    compass.runAction(rotateAction, completion: {
                        self.shouldTransition = true
                    })
            }
        }
        else if prevScene == .Horizontal {
            switch results
            {
                case .Pass:
                    compass.zRotation = CGFloat(M_PI/2.0)
                    let rotateAction = SKAction.rotateByAngle(CGFloat((3.0*M_PI)/2.0), duration: 4.5)
                    rotateAction.timingMode = .EaseInEaseOut
                    compass.runAction(rotateAction, completion: {
                        self.shouldTransition = true
                    })
                    
                case .Fail:
                    compass.zRotation = CGFloat(-M_PI/2.0)
                    let rotateAction = SKAction.rotateByAngle(CGFloat(M_PI/2.0), duration: 1.5)
                    rotateAction.timingMode = .EaseInEaseOut
                    compass.runAction(rotateAction, completion: {
                        self.shouldTransition = true
                    })
            }
        }
        
        self.nextSceneName = nextSceneName
    }
    
    override func didMoveToView(view: SKView) {
        // set up scene
        anchorPoint = CGPointMake(0.5, 0.5)
        backgroundColor = SKColor.whiteColor()
//        setup(view)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            var nextScene: SKScene? = nil
            if self.nextSceneName == "TutorialScene" {
                
                nextScene = TutorialScene(size: CGSize(width: 320.0, height: 568.0))
                game.interactionManager.releaseInteractions(nil)
                
            } else if self.nextSceneName == "DayZeroSuccess" {
                
                nextScene = LighthouseScene(size: CGSize(width: 320.0, height: 568.0))
                (nextScene as LighthouseScene).cameraRotation = CGFloat(M_PI/2.0)
                (nextScene as LighthouseScene).nextSceneInfo = (.Horizontal, .Pass, "GameScene")
                game.interactionManager.loadInteractions("default", dataFile: "dayZero")
                
            } else if self.nextSceneName == "GameScene" {
                
                nextScene = GameScene(size: CGSize(width: 320.0, height: 568.0))
                game.interactionManager.releaseInteractions(nil)
                
            } else if self.nextSceneName == "DayOneFailOne" {
                
                nextScene = LighthouseScene(size: CGSize(width: 320.0, height: 568.0))
                (nextScene as LighthouseScene).cameraRotation = CGFloat(-M_PI/2.0)
                (nextScene as LighthouseScene).nextSceneInfo = (.Horizontal, .Fail, "GameScene")
                game.interactionManager.loadInteractions("default", dataFile: "dayOneFailOne")
                
            } else if self.nextSceneName == "DayOneFailTwo" {
                
                nextScene = LighthouseScene(size: CGSize(width: 320.0, height: 568.0))
                (nextScene as LighthouseScene).cameraRotation = CGFloat(-M_PI/2.0)
                (nextScene as LighthouseScene).nextSceneInfo = (.Horizontal, .Fail, "GameScene")
                game.interactionManager.loadInteractions("default", dataFile: "dayOneFailTwo")
                
            } else if self.nextSceneName == "DayOneSuccess" {
                
                nextScene = LighthouseScene(size: CGSize(width: 320.0, height: 568.0))
                (nextScene as LighthouseScene).cameraRotation = CGFloat(M_PI/2.0)
                (nextScene as LighthouseScene).nextSceneInfo = (.Horizontal, .Pass, "TutorialScene")
                game.interactionManager.loadInteractions("default", dataFile: "dayOneSuccess")
                
            }
            
            self.transitionScene = nextScene
            self.isLoaded = true
        })
    }
    
    override func willMoveFromView(view: SKView) {
        
    }
    
//    func setup(view: SKView) {
//        
//    }
    
    override func update(currentTime: NSTimeInterval) {
        if isLoaded && shouldTransition {
            // set up transition
            let transition = SKTransition.crossFadeWithDuration(1.0)
            transition.pausesIncomingScene = false
            transition.pausesOutgoingScene = false
            
            // present scene
            view!.presentScene(transitionScene, transition: transition)
            shouldTransition = false
        }
        
//        // update time
//        updateTime(currentTime)
//        
//        updateRotation()
//        switch allowedRotation
//        {
//            case .CCW:
//                if lastRotation < rotation {
//                    rotation = lastRotation
//                }
//            
//            case .CW:
//                if lastRotation > rotation {
//                    rotation = lastRotation
//                }
//            
//            case .Nope:
//                break
//        }
//        rotation = Double(Utilities2D.lerpFrom(CGFloat(lastRotation), toNum: CGFloat(rotation), atPosition: 0.05))
//        compass.zRotation = CGFloat(rotation)
    }
    
    func updateTime(currentTime:NSTimeInterval) {
//        game.timeManager.update(deltaTime)
        deltaTime = currentTime - lastTime
        if deltaTime > 1.0 { deltaTime = 1.0 }
        lastTime = currentTime
    }
    
//    func updateRotation() {
//        lastRotation = rotation
////        let xData = game.motionManager.accelerometerData.acceleration.x
////        let yData = game.motionManager.accelerometerData.acceleration.y
////        let zData = game.motionManager.accelerometerData.acceleration.z
//        let xData = motionManager.accelerometerData.acceleration.x
//        let yData = motionManager.accelerometerData.acceleration.y
//        let zData = motionManager.accelerometerData.acceleration.z
//        var nextAngle = atan2(yData, xData)
//        if (nextAngle < 0) { nextAngle += (M_PI * 2.0) }
//        nextAngle = nextAngle + ((rotation - nextAngle) * 0.01)
//        rotation = nextAngle
//    }
}