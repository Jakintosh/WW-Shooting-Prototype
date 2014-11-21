//
//  Player.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/16/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class Player : NHCNode {
    
    enum PlayerState {
        case Idle, Aim
    }
    
    // animation
    let animationNode = NHCNode()
    let animatorKey: String
    var animator: AnimatableEntity!
    var animationScale: CGFloat = 1.0 {
        didSet {
            self.animationNode.xScale = self.animationScale
            self.animationNode.yScale = self.animationScale
        }
    }
    
    // properties
    var currentState: PlayerState = .Idle {
        didSet {
            switch (self.currentState)
            {
            case .Idle:
                animator.playAnimation("idle", introPeriod: 0.2)
                animator.setQueuedAnimation("idle", introPeriod: 0.2)
                
            case .Aim:
                animator.playAnimation("aim_action", introPeriod: 0.2)
                animator.setQueuedAnimation("aim_idle", introPeriod: 0.2)
            }
        }
    }
    
    override init() {
        self.animatorKey = "player_entity"
        
        super.init()
        
        animator = game.animationManager.registerEntity(animatorKey, owner: self)
        
        setupAnimationNode()
        addChild(animationNode)
    }
    
    // MARK: Animation
    func setSpine(spineKey: String, animKey: String) {
        animationNode.removeAllChildren()
        
        game.animationManager.setSpineForEntity(spineKey, entityKey: animatorKey)
        animator.setupSpine(animKey, introPeriod: 0.5)
        
        if let spineNode = animator.animationSpine {
            animationNode.addChild(spineNode)
        }
    }
    func shoot() {
        animator.playAnimation("shoot", introPeriod: 0.1)
    }
    
    func setupAnimationNode() {
//        let char = SKSpriteNode(imageNamed: "idle01")
//        char.anchorPoint = CGPoint(x: 0.5, y: 0.0)
//        char.xScale = 2.5
//        char.yScale = 2.5
//        animationNode.addChild(char)
        setSpine("spine_player_entity", animKey: "idle")
    }
    
    func update(dt: CFTimeInterval) {
        animator.update(dt)
    }
    
}