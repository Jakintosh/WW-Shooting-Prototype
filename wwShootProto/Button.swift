//
//  NHCSButton.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/20/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class Button : SKFuckNode {
    
    // MARK: - Properties
    let activeState: SKSpriteNode
    let defaultState: SKSpriteNode
    let completionAction: () -> Void
    
    // MARK: - Initializers
    init(activeImageName: String, defaultImageName: String, action: () -> Void) {
        defaultState = SKSpriteNode(imageNamed: defaultImageName)
        activeState = SKSpriteNode(imageNamed: activeImageName)
        completionAction = action
        
        super.init()
        
        userInteractionEnabled = true
        addChild(defaultState)
        addChild(activeState)
    }
    
    // MARK: - Methods
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        activeState.hidden = false
        defaultState.hidden = true
    }

    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var touch: UITouch = touches.allObjects[0] as UITouch
        var location: CGPoint = touch.locationInNode(self)
        
        if defaultState.containsPoint(location) {
            activeState.hidden = false
            defaultState.hidden = true
        } else {
            activeState.hidden = true
            defaultState.hidden = false
        }
    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        var touch: UITouch = touches.allObjects[0] as UITouch
        var location: CGPoint = touch.locationInNode(self)
        
        if defaultState.containsPoint(location) {
            completionAction()
        }
        
        activeState.hidden = true
        defaultState.hidden = false
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        activeState.hidden = true
        defaultState.hidden = false
    }
}