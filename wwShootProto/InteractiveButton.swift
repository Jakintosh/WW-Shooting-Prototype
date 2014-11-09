//
//  InteractiveButton.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/7/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

enum InteractiveButtonType {
    case Option, Speech
}

class InteractiveButton : Button {
    
    let PRESENTATION_TIME: NSTimeInterval = 0.75
    
    // MARK: Cool Properties!
    private var label: SKLabelNode = SKLabelNode()
    let type: InteractiveButtonType
    var text: String                = "" {
        didSet {
            label.text = self.text
        }
    }
    var isPresented: Bool {
        didSet {
            if isPresented != oldValue {
                if isPresented {
                    self.removeActionForKey("completion")
                    
                    moveTo(self.targetPosition)
                    scaleFade(present: true)
                } else {
                    moveTo(CGPointZero)
                    scaleFade(present: false)
                    self.runAction(SKAction.sequence([SKAction.waitForDuration(PRESENTATION_TIME),SKAction.runBlock({
                        self.text = ""
                        self.completionAction = {}
                    })]), withKey: "completion")
                }
            }
        }
    }
    var targetPosition: CGPoint {
        didSet {
            if isPresented {
                moveTo(targetPosition)
            }
            if targetPosition.x > 0 {
                self.defaultState.xScale = 1.0
                self.activeState.xScale = 1.0
                self.label.position.x = 6.5
            } else {
                self.defaultState.xScale = -1.0
                self.activeState.xScale = -1.0
                self.label.position.x = -6.5
            }
        }
    }
    var targetAlpha: CGFloat = 1.0
    
    init(type: InteractiveButtonType) {
        self.type = type
        self.isPresented = false
        self.targetPosition = CGPointZero
        
        switch type
        {
        case .Option:
            super.init(activeImageName: "button_default", defaultImageName: "button_default", action: {} )
        case .Speech:
            super.init(activeImageName: "button_speech", defaultImageName: "button_speech", action: {} )
        }
        
        
        if type == .Option { targetAlpha = 0.75 }
        
        // label setup
        label.verticalAlignmentMode   = .Center
        label.horizontalAlignmentMode = .Center
        label.fontName = "HelveticaNeue-Light"
        label.fontSize = 12.0
        self.addChild(label)
        
        self.xScale = 0.05
        self.yScale = 0.05
        self.alpha = 0.0
        
    }
    
    func updateSpeechAlpha(newAlpha: CGFloat) {
        self.alpha = newAlpha
    }
    
    private func moveTo(point: CGPoint) {
        self.removeActionForKey("movement")
        
        let move = SKAction.moveTo(point, duration: self.PRESENTATION_TIME)
        move.timingMode = .EaseInEaseOut
        self.runAction(move, withKey: "movement")
    }
    private func scaleFade(#present: Bool) {
        self.removeActionForKey("scale_alpha")
        
        if present {
            let scale = SKAction.scaleTo(1.0, duration: PRESENTATION_TIME)
            let alpha = SKAction.fadeAlphaTo(targetAlpha, duration: PRESENTATION_TIME)
            self.runAction(SKAction.group([scale, alpha]), withKey: "scale_alpha")
        } else {
            let scale = SKAction.scaleTo(0.05, duration: PRESENTATION_TIME)
            let alpha = SKAction.fadeAlphaTo(0.0, duration: PRESENTATION_TIME)
            self.runAction(SKAction.group([scale, alpha]), withKey: "scale_alpha")
        }
    }
    
}