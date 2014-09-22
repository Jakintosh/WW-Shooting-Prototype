//
//  Whale.swift
//  wwShootProto
//
//  Created by Jak Tiano on 9/21/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class Whale : SKSpriteNode {
    
    var weakSpots = [SKShapeNode]()
    var moveSpeed: Float = 7
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        addWeakPoint(position: CGPointMake(-20, 50))
    }
    
    convenience override init() {
        self.init(texture: SKTexture(imageNamed: "whale"), color: SKColor.whiteColor(), size: SKTexture(imageNamed: "whale").size())
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(#touchPos: CGPoint) {
        if let theScene = scene {
            let touchInWhaleSpace = theScene.convertPoint(touchPos, toNode: self)
            for ws in weakSpots {
                let a = touchInWhaleSpace.x - ws.position.x
                let b = touchInWhaleSpace.y - ws.position.y
                let distSq = (a*a)+(b*b)
                println("input touch = \(touchPos) and converted touch = \(touchInWhaleSpace)")
                if distSq < (20*20) {
                    ws.strokeColor = SKColor.greenColor()
                    ws.fillColor = SKColor.greenColor()
                } else if distSq < (50*50) {
                    ws.strokeColor = SKColor.greenColor()
                    ws.fillColor = SKColor.clearColor()
                } else {
                    ws.strokeColor = SKColor.orangeColor()
                    ws.fillColor = SKColor.clearColor()
                }
            }
        }
    }
    
    func addWeakPoint(position pos: CGPoint) {
        let newWeakPoint = SKShapeNode(circleOfRadius: 10)
        newWeakPoint.position = pos
        newWeakPoint.zPosition = zPosition + 1
        newWeakPoint.strokeColor = SKColor.orangeColor()
        newWeakPoint.lineWidth = 6.0
        newWeakPoint.fillColor = SKColor.clearColor()
        addChild(newWeakPoint)
        
        weakSpots += [newWeakPoint]
    }
    
    func move() {
        if let theScene = scene {
            let rotate = SKAction.rotateByAngle(-CGFloat(M_PI_2), duration: NSTimeInterval(moveSpeed))
            let moveX = SKAction.moveByX(theScene.size.width - 2*size.width, y: 0, duration: NSTimeInterval(moveSpeed))
            let moveUp = SKAction.moveByX(0, y: 500, duration: NSTimeInterval(moveSpeed)/2)
            let moveDown = moveUp.reversedAction()
            moveUp.timingMode = .EaseOut
            moveDown.timingMode = .EaseIn
            
            let die = SKAction.runBlock({ () -> Void in
                (self.scene! as GameScene).removeWhale(whale: self)
                self.removeFromParent()
                self.removeAllActions()
                self.removeAllChildren()
            })
            
            runAction(SKAction.group([rotate, moveX, SKAction.sequence([moveUp, moveDown, die])]))
        }
    }

}