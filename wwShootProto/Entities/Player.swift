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
    var getUpSprite: SKSpriteNode!
    var getUpFrames: [SKTexture]! = []
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
    var isUp: Bool = false
    
    override init() {
        self.animatorKey = "player_entity"
        
        super.init()
        
        let atlas = SKTextureAtlas(named: "dad_getup")
//        for i in 0..<6 {
//            getUpFrames.append(atlas.textureNamed("dadStart\(i)"))
//        }
        getUpFrames.append(atlas.textureNamed("dadStart0"))
        getUpFrames.append(atlas.textureNamed("dadStart1"))
        getUpFrames.append(atlas.textureNamed("dadStart1"))
        getUpFrames.append(atlas.textureNamed("dadStart2"))
        getUpFrames.append(atlas.textureNamed("dadStart2"))
        getUpFrames.append(atlas.textureNamed("dadStart3"))
        getUpFrames.append(atlas.textureNamed("dadStart3"))
        getUpFrames.append(atlas.textureNamed("dadStart4"))
        getUpFrames.append(atlas.textureNamed("dadStart5"))
        
        getUpSprite = SKSpriteNode(texture: getUpFrames[0])
        getUpSprite.anchorPoint = CGPoint(x: 0.49833333, y: 0.03166667)
        getUpSprite.xScale = 2.0
        getUpSprite.yScale = 2.0
        animationNode.addChild(getUpSprite)
        
        animator = game.animationManager.registerEntity(animatorKey, owner: self)
        
//        setupAnimationNode()
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
    func getUp() {
        if !isUp {
            getUpSprite.runAction(SKAction.animateWithTextures(getUpFrames, timePerFrame: 0.2222), completion: {
                self.setupAnimationNode()
                self.animator.playAnimation("start", introPeriod: 0.1)
                self.animator.setQueuedAnimation("idle", introPeriod: 0.1)
                self.getUpSprite.hidden = true
                self.getUpSprite = nil
                self.getUpFrames = nil
                self.isUp = true
            })
        }
    }
    
    func setupAnimationNode() {
//        let char = SKSpriteNode(imageNamed: "idle01")
//        char.anchorPoint = CGPoint(x: 0.5, y: 0.0)
//        char.xScale = 2.5
//        char.yScale = 2.5
//        animationNode.addChild(char)
        setSpine("spine_player_entity", animKey: "start")
    }
    
    func update(dt: CFTimeInterval) {
        animator.update(dt)
    }
    
}