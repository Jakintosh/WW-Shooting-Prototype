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
                compass.runAction(SKAction.rotateByAngle(CGFloat(-M_PI/2.0), duration: 1.5))
                
            case .Fail:
                compass.runAction(SKAction.rotateByAngle(CGFloat(M_PI/2.0), duration: 1.5))
            }
        }
        else if prevScene == .Horizontal {
            switch results
            {
            case .Pass:
                compass.zRotation = CGFloat(M_PI/2.0)
                compass.runAction(SKAction.rotateByAngle(CGFloat((3.0*M_PI)/2.0), duration: 4.5))
                
            case .Fail:
                compass.zRotation = CGFloat(-M_PI/2.0)
                compass.runAction(SKAction.rotateByAngle(CGFloat(M_PI/2.0), duration: 1.5))
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
            } else if self.nextSceneName == "IntroScene" {
                nextScene = IntroScene(size: CGSize(width: 320.0, height: 568.0))
            } else if self.nextSceneName == "GameScene" {
                nextScene = GameScene(size: CGSize(width: 320.0, height: 568.0))
            } else if self.nextSceneName == "DayOneFailOne" {
                nextScene = DayOneFailOne(size: CGSize(width: 320.0, height: 568.0))
            } else if self.nextSceneName == "DayOneFailTwo" {
//                nextScene = TutorialScene(size: CGSize(width: 320.0, height: 568.0))
            } else if self.nextSceneName == "DayOneSuccess" {
//                nextScene = TutorialScene(size: CGSize(width: 320.0, height: 568.0))
            }
            
            
            dispatch_async(dispatch_get_main_queue(), {
                self.runAction(SKAction.sequence([SKAction.waitForDuration(1.0), SKAction.runBlock({
                    // set up transition
                    let transition = SKTransition.crossFadeWithDuration(1.0)
                    transition.pausesIncomingScene = false
                    transition.pausesOutgoingScene = false
                    
                    // present scene
                    view.presentScene(nextScene, transition: transition)
                })]))
            })
        })
    }
    
    override func willMoveFromView(view: SKView) {
        
    }
    
//    func setup(view: SKView) {
//        
//    }
    
    override func update(currentTime: NSTimeInterval) {
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