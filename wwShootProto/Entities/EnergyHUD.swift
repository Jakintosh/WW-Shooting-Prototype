//
//  EnergyHUD.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/20/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class EnergyHUD : NHCNode {
    
    enum EnergyHUDState {
        case ZoomedIn, ZoomedOut
    }
    
    // parts
    let reticle: SKSpriteNode
    let hud: SKSpriteNode
    
    // properties
    var lockDuration: CGFloat   = 2.0
    var lockProgress: CGFloat   = 0.0
    var lockOnRadius: CGFloat   = 81.0
    
    let fillMeter: SKShapeNode  = SKShapeNode()
    var fillPath: UIBezierPath  = UIBezierPath()
    let fillNode: NHCNode = NHCNode()
    
    var reticlePosition: CGPoint = CGPointZero
    var hudPosition: CGPoint = CGPoint(x: 0, y: 125.0)
    var morphValue: CGFloat = 0.0
    var targetMorphValue: CGFloat = 0.0
    var currentState: EnergyHUDState = .ZoomedOut {
        didSet {
            switch (self.currentState)
            {
                case .ZoomedIn:
                    targetMorphValue = 1.0
                    
                case .ZoomedOut:
                    targetMorphValue = 0.0
            }
        }
    }
    
    override init() {
        reticle = SKSpriteNode(imageNamed: "reticle")
        hud = SKSpriteNode(imageNamed: "energyHUD")
        
        super.init()
        
        // setup reticle
        reticle.zPosition = 1
        hud.zPosition = -473
        hud.alpha = 0.5
        
        fillMeter.position.y = 1
        fillMeter.zPosition = -2
        fillMeter.strokeColor = SKColor.greenColor()
        fillMeter.fillColor = SKColor.clearColor()
        fillMeter.lineWidth = 3
        fillPath.moveToPoint(CGPointMake(0, lockOnRadius))
        fillNode.addChild(fillMeter)
        
        addChild(fillNode)
        addChild(reticle)
        addChild(hud)
    }
    
    func update(touchLocation: CGPoint?) {
        
        if let u_touchLocation = touchLocation {
            reticlePosition = u_touchLocation
        }
        
        morphValue = Utilities2D.lerpFrom(morphValue, toNum: targetMorphValue, atPosition: 0.2)
        reticle.alpha = morphValue
        hud.alpha = (1.0 - morphValue) * 0.5
        reticle.xScale = ((1.0 - morphValue) * 4.2702) + 1.0
        reticle.yScale = ((1.0 - morphValue) * 4.2702) + 1.0
        hud.xScale = 1.0 - (morphValue * 0.8103)
        hud.yScale = 1.0 - (morphValue * 0.8103)
        fillNode.xScale = 1.0 - (morphValue * 0.8103)
        fillNode.yScale = 1.0 - (morphValue * 0.8103)
        fillMeter.lineWidth = 3 + (morphValue * 3)
        position = Utilities2D.lerpFromPoint(hudPosition, toPoint: reticlePosition, atPosition: morphValue)
        
        if morphValue == 0.0 {
            reticle.hidden = true
        } else if morphValue == 1.0 {
            hud.hidden = true
        } else {
            reticle.hidden = false
            hud.hidden = false
        }
        
        // draw circle
        var mod: CGFloat = game.energyManager.currentEnergy/game.energyManager.energyCap
        mod *= 2.0 * CGFloat(M_PI)
        mod = CGFloat(M_PI)/2.0 - mod
        fillPath.removeAllPoints()
        fillPath.addArcWithCenter(  CGPointMake(0.0, 0.0),
            radius: lockOnRadius,
            startAngle: CGFloat(M_PI/2.0),
            endAngle: CGFloat(mod),
            clockwise: false )
        fillMeter.path = nil
        fillMeter.path = fillPath.CGPath
        
    }
}