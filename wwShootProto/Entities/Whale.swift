//
//  Whale.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/16/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: -
class Whale : NHCNode {
    
    enum WhaleAngerState {
        case White, Yellow, Red
        
        mutating func increase() {
            switch (self)
            {
                case .White:
                    self = .Yellow
                    
                case .Yellow:
                    self = .Red
                    
                case .Red:
                    self = .Red
            }
        }
    }
    
    enum WhaleState {
        case Submerged, Jumping, Stunned
    }
    
    // components
    let animationNode   = NHCNode()
    let exposedNode     = NHCNode()
    let lockOnNode      = NHCNode()
    
    let animatorKey: String
    var animator: AnimatableEntity!
    
    var lockOnWell: EnergyWell!
    var exposedWells: [EnergyWell] = [EnergyWell]()
    
    // closures
    let onDeath: (pos: CGPoint, root: SKNode) -> Void
    let screenShake: (intensity: CGFloat, duration: NSTimeInterval) -> Void
    var onSubmerge: () -> () = {}
    
    // properties
    var isAlive: Bool     = true
    var isScreaming: Bool = false
    var isMirrored: Bool  = false
    var managerIndex: Int
    var angerState: WhaleAngerState  = .White
    var whaleState: WhaleState = .Submerged
    var timeSubmerged: NSTimeInterval = 0.0
    var timeScreaming: NSTimeInterval = 0.0
    var dirMult: CGFloat {
        if isMirrored { return -1.0 }
        else { return 1.0 }
    }
    var scale: CGFloat = 1.0 {
        didSet {
            self.xScale = self.scale
            self.yScale = self.scale
        }
    }
    
    // initialization
    init(onDeath: (CGPoint, SKNode) -> Void, ss: (CGFloat, NSTimeInterval)->Void, mgrInd: Int, animatorKey: String) {
        self.onDeath = onDeath
        self.screenShake = ss
        self.animatorKey = animatorKey
        self.managerIndex = mgrInd
        
        super.init()
        
        animator = game.animationManager.registerEntity(animatorKey, owner: self)
        
        setupAnimationNode()
        setupExposedNode()
        setupLockOnNode()
        
        addChild(animationNode)
        addChild(exposedNode)
        addChild(lockOnNode)
        
        exposedNode.hidden = true
        lockOnNode.hidden = true
    }
    func setupAnimationNode() {}
    func setupExposedNode() {}
    func setupLockOnNode() {}
    
    // MARK: Animation
    func setSpine(spineKey: String, animKey: String) {
        animationNode.removeAllChildren()
        
        game.animationManager.setSpineForEntity(spineKey, entityKey: animatorKey)
        animator.setupSpine(animKey, introPeriod: 0.1)
        
        if let spineNode = animator.animationSpine {
            animationNode.addChild(spineNode)
        }
    }
    func setSpine(spine: SGG_Spine, animKey: String) {
        animationNode.removeAllChildren()
        
        animator.setSpine(spine)
        animator.setupSpine(animKey, introPeriod: 0.1)
        
        if let spineNode = animator.animationSpine {
            animationNode.addChild(spineNode)
        }
    }
    func removeSpine() {
        animator.removeSpine()
    }
    
    // updates
    func update(scenePos: CGPoint, dt: CFTimeInterval) {
        
        updateAnimationNode(dt)
        
        switch( whaleState )
        {
            case .Jumping:
                updateLockOnNode(scenePos, dt: dt)
                
            case .Submerged:
                timeSubmerged += dt
            
            case .Stunned:
                updateExposedNode(scenePos, dt: dt)
        }
        
        if isScreaming {
            timeScreaming += dt
        }
    }
    func updateAnimationNode(dt: CFTimeInterval) {
        animator.update(dt)
    }
    func updateExposedNode(scenePos: CGPoint, dt: CFTimeInterval) {
        var numFinished = 0
        for well in exposedWells {
            if well.activated {
                well.update(scenePos, dt: dt)
                if well.lockedOn {
                    well.burst()
//                    lockOnWell.wellLockOn.texture = lockOnWell
                    screenShake(intensity: 8, duration: 0.2)
                    game.animationManager.runAnimation("player_entity", animationName: "shoot", introPeriod: 0.1)
                    numFinished++
                }
            } else {
                numFinished++
            }
        }
        if isAlive {
            if numFinished >= exposedWells.count {
                kill()
            }
        }
    }
    func updateLockOnNode(scenePos: CGPoint, dt: CFTimeInterval) {
        lockOnWell.update(scenePos, dt: dt)
        if lockOnWell.lockedOn {
            stun()
            for well in exposedWells {
                well.openWell()
            }
            screenShake(intensity: 10, duration: 0.33)
            game.animationManager.runAnimation("player_entity", animationName: "shoot", introPeriod: 0.1)
        }
    }
    
    // methods
    func mirror(m: Bool) {
        isMirrored = m
        if m { xScale = -scale } else { xScale = scale }
    }
    func dive() {
        whaleState = .Submerged
        timeSubmerged = 0.0
        stopScream()
        
        angerState.increase()
        onSubmerge()
        
        // reset lock on mode
        lockOnNode.hidden = true
        lockOnWell.resetWell()
        
        // hide exposed
        exposedNode.hidden = true
        
        // reset visual propertiess
        self.zRotation = 0.0
        self.removeFromParent()
    }
    func jump() {
        whaleState = .Jumping
        lockOnNode.hidden = false
        var x: Int = 0
        for well in exposedWells {
            if well.activated { x++ }
        }
        lockOnWell.updateLockOnTexture(x)
    }
    func stun() {
        whaleState = .Stunned
        lockOnNode.hidden = true
        exposedNode.hidden = false
        stopScream()
    }
    func scream() {
        isScreaming = true
        timeScreaming = 0.0
    }
    func getScream() -> CGFloat {
        if isScreaming {
            return CGFloat(timeScreaming)
        } else {
            return 0.0
        }
    }
    func stopScream() {
        isScreaming = false
        timeScreaming = 0.0
    }
    func kill() {
        isAlive = false
        stopScream()
    }
    func remove() {
        stopScream()
        self.animator.removeSpine()
        self.removeFromParent()
        self.removeAllChildren()
    }
}

// MARK: -
class Orca : Whale {
    
    // properties
    var jumpAction: SKAction// {
//        let animLength: NSTimeInterval = 8.0
//        let horizontalMove = SKAction.sequence([
//            SKAction.moveByX(25.0 * self.dirMult, y: 0, duration: animLength/15.0),
//            SKAction.moveByX(5.0 * self.dirMult, y: 0, duration: (animLength*5.0)/6.0),
//            SKAction.moveByX(25.0 * self.dirMult, y: 0, duration: animLength/10.0) ])
//        horizontalMove.timingMode = .EaseInEaseOut
//        let up = SKAction.moveByX(0, y: 700, duration: animLength/2.0)
//        let down = up.reversedAction()
//        up.timingFunction  = { time in
//            return (1.0 - ((1.0 - time)*(1.0 - time)*(1.0 - time)))
//        }
//        down.timingFunction = { time in
//            return (time*time*time)
//        }
//        let verticalMovement = SKAction.sequence([up, /*SKAction.waitForDuration(animLength/3.0)*/ down])
//        let rotate = SKAction.sequence([
//            SKAction.rotateByAngle(CGFloat(M_PI * -0.05), duration: animLength/4.0),
//            SKAction.rotateByAngle(CGFloat(M_PI *   0.0), duration: animLength/2.0),
//            SKAction.rotateByAngle(CGFloat(M_PI *  -0.1), duration: animLength/4.0)])
//        
//        return SKAction.group([ horizontalMove, verticalMovement, rotate ])
//    }
    var explosionSound: SKAction
    var screamSound: SKAction
    var deathAnimation = [SKTexture]()
    var deathSprite: SKSpriteNode
    
    struct Stored {
        static var instanceNum: Int = 0
    }
    
    init(onDeath: (CGPoint, SKNode) -> Void, ss: (CGFloat, NSTimeInterval)->Void, mgrInd: Int) {
        // setup SKActions
        
//        // .3333 into max jump, 4.1666, 0.5
        let animLength: NSTimeInterval = 8.0
        let horizontalMove = SKAction.sequence([
            SKAction.moveByX(50, y: 0, duration: animLength/15.0),
            SKAction.moveByX(50, y: 0, duration: (animLength*5.0)/6.0),
            SKAction.moveByX(50, y: 0, duration: animLength/10.0) ])
        horizontalMove.timingMode = .EaseInEaseOut
        let up = SKAction.moveByX(0, y: 700, duration: animLength/2.0)
        let down = up.reversedAction()
        up.timingFunction  = { time in
            return (1.0 - ((1.0 - time)*(1.0 - time)*(1.0 - time)))
        }
        down.timingFunction = { time in
            return (time*time*time)
        }
        let verticalMovement = SKAction.sequence([up, /*SKAction.waitForDuration(animLength/3.0)*/ down])
        let rotate = SKAction.sequence([
            SKAction.rotateByAngle(CGFloat(M_PI * -0.05), duration: animLength/4.0),
            SKAction.rotateByAngle(CGFloat(M_PI *   0.0), duration: animLength/2.0),
            SKAction.rotateByAngle(CGFloat(M_PI *  -0.1), duration: animLength/4.0)])
        
        jumpAction = SKAction.group([ horizontalMove, verticalMovement, rotate ])
        jumpAction.timingMode = .EaseInEaseOut
        screamSound = SKAction.repeatActionForever(SKAction.playSoundFileNamed("whale_scream.wav", waitForCompletion: true))
        explosionSound = SKAction.playSoundFileNamed("whale_explosion.caf", waitForCompletion: false)
        
        let atlas = SKTextureAtlas(named: "whale-death")
        for i in 0..<5 {
            deathAnimation.append(atlas.textureNamed("whaleType01_death0\(i)"))
        }
        
        deathSprite = SKSpriteNode(texture: deathAnimation[0])
        deathSprite.xScale = 1.953
        deathSprite.yScale = 1.953
        deathSprite.hidden = true
        deathSprite.anchorPoint = CGPoint(x: 0.28684211, y: 0.609375)
        
        // set up key
        let key = "whale_orca\(Stored.instanceNum)"
        Stored.instanceNum++
        
        super.init(onDeath: onDeath, ss: ss, mgrInd: mgrInd, animatorKey: key)
        
        addChild(deathSprite)
        
        scale = 0.8
    }
    override func setupAnimationNode() {
        animationNode.xScale = 0.5
        animationNode.yScale = 0.5
    }
    override func setupExposedNode() {
        let well1 = EnergyWell(radius: 40.0, duration: 0.5, type: .Exposed)
        let well2 = EnergyWell(radius: 30.0, duration: 0.4, type: .Exposed)
        let well3 = EnergyWell(radius: 20.0, duration: 0.1, type: .Exposed)
        
        well1.position = CGPoint(x: 112.5, y:  100.0)
        well2.position = CGPoint(x:  20.0, y:   30.0)
        well3.position = CGPoint(x: -35.0, y: -112.5)
        
        well1.xScale = 1.0 / scale
        well1.yScale = 1.0 / scale
        
        well2.xScale = 1.0 / scale
        well2.yScale = 1.0 / scale
        
        well3.xScale = 1.0 / scale
        well3.yScale = 1.0 / scale
        
        exposedWells += [well1, well2, well3]
        
        exposedNode.addChild(well1)
        exposedNode.addChild(well2)
        exposedNode.addChild(well3)
        exposedNode.zPosition = 1
    }
    override func setupLockOnNode() {
        lockOnWell = EnergyWell(radius: 30.0, duration: 1.0, type: .LockOn)
        lockOnWell.position = CGPoint(x: 0, y: 0)
        lockOnWell.xScale = 1.5
        lockOnWell.yScale = 1.5
        
        lockOnNode.addChild(lockOnWell)
        lockOnNode.zPosition = 1
    }
    
    
    override func update(scenePos: CGPoint, dt: CFTimeInterval) {
        super.update(scenePos, dt: dt)
    }
    override func updateAnimationNode(dt: CFTimeInterval) {
        super.updateAnimationNode(dt)
    }
    override func updateExposedNode(scenePos: CGPoint, dt: CFTimeInterval) {
        super.updateExposedNode(scenePos, dt: dt)
    }
    override func updateLockOnNode(scenePos: CGPoint, dt: CFTimeInterval) {
        super.updateLockOnNode(scenePos, dt: dt)
    }
    
    
    override func dive() {
        super.dive()
        animator.stopAnimation()
    }
    override func jump() {
        super.jump()
        switch (angerState)
        {
            case .White:
                animator.playAnimation("jump_white", introPeriod: 0.1)
                animator.setQueuedAnimation("jump_white", introPeriod: 0.1)
            case .Yellow:
                animator.playAnimation("jump_yellow", introPeriod: 0.1)
                animator.setQueuedAnimation("jump_yellow", introPeriod: 0.1)
            case .Red:
                animator.playAnimation("jump_red", introPeriod: 0.1)
                animator.setQueuedAnimation("scream", introPeriod: 0.1)
                runAction(SKAction.sequence([SKAction.waitForDuration(3.2), SKAction.runBlock( { self.scream() } )]), withKey: "scream")
        }
        runAction(jumpAction, completion: { self.dive() })
    }
    override func stun() {
        super.stun()
        removeActionForKey("scream")
        animator.playAnimation("stun", introPeriod: 0.05)
        animator.setQueuedAnimation("stun", introPeriod: 0.1)
    }
    override func scream() {
        super.scream()
        removeActionForKey("scream")
        SoundManager.sharedManager().playSound("whale_scream.wav", looping: true)
//        runAction(screamSound, withKey: "scream")
    }
    override func stopScream() {
        super.stopScream()
        SoundManager.sharedManager().stopSound("whale_scream.wav")
//        removeActionForKey("scream")
    }
    override func kill() {
        super.kill()
        animator.stopAnimation()
        animator.animationSpine?.hidden = true
        deathSprite.hidden = false
        deathSprite.runAction( SKAction.group( [SKAction.waitForDuration(0.2), SKAction.animateWithTextures(deathAnimation, timePerFrame: 0.1)]), withKey: "death")
        runAction(SKAction.waitForDuration(0.5), completion: {
            self.onDeath(pos: self.position, root: self.parent!)
            self.screenShake(intensity: 15, duration: 0.5)
//            self.runAction(self.explosionSound)
            SoundManager.sharedManager().playSound("whale_explosion.caf")
            self.remove()
        })
    }
    override func remove() {
        super.remove()
    }
}


// MARK: -
class EnergyWell : NHCNode {
    
    enum EnergyWellActivation {
        case NoPower, HalfPower, FullPower
    }
    
    enum EnergyWellType {
        case LockOn, Exposed, Debug
    }
    
    // components
    let wellDebug: SKShapeNode  = SKShapeNode()
    var wellExposed: SKSpriteNode!
    var wellExposedOpenAnimation = [SKTexture]()
    var wellExposedStaticAnimation = [SKTexture]()
    var wellLockOn: SKSpriteNode!
    var wellLockOnTextures = [SKTexture]()
    var wellExplosionTextures = [SKTexture]()
    let fillMeter: SKShapeNode  = SKShapeNode()
    var fillPath: UIBezierPath  = UIBezierPath()
    
    // properties
    var type: EnergyWellType
    var activationLevel: EnergyWellActivation = .NoPower
    var activated: Bool         = true
    var lockDuration: CGFloat   = 2.0
    var lockProgress: CGFloat   = 0.0
    var lockedOn: Bool          = false
    var lockOnRadius: CGFloat   = 10.0
    var lockOnRadiusSq: CGFloat = 100.0
    
    init(radius: CGFloat, duration: CGFloat, type: EnergyWellType = .Debug) {
        self.type = type
        
        super.init()
        
        lockOnRadius = radius
        lockOnRadiusSq = radius * radius
        lockDuration = duration
        
        let atlas = SKTextureAtlas(named: "textures")
        for i in 0..<5 {
            wellExposedOpenAnimation.append(atlas.textureNamed("hitbox-open_\(i)"))
        }
        for i in 0..<5 {
            wellExposedStaticAnimation.append(atlas.textureNamed("hitbox-static_\(i)"))
        }
        for i in 0..<3 {
            wellLockOnTextures.append(atlas.textureNamed("lockOn\(i)"))
        }
        for i in 0..<3 {
            wellExplosionTextures.append(atlas.textureNamed("explosion\(i)"))
        }
        
        // set up well
        setupWell()
        
        // set up fill meter
        setupFillMeter()
    }
    
    func setupWell() {
        
        switch(type)
        {
        case .Debug:
            let rad = lockOnRadius - 3.0
            let diameter = rad * 2.0
            wellDebug.path = CGPathCreateWithEllipseInRect(CGRectMake(-rad, -rad, diameter, diameter), nil)
            wellDebug.strokeColor = SKColor.orangeColor()
            wellDebug.fillColor = SKColor.clearColor()
            wellDebug.lineWidth = 3
            addChild(wellDebug)
            
        case .LockOn:
            let scale: CGFloat = lockOnRadius/40.0
            wellLockOn = SKSpriteNode(texture: wellLockOnTextures[0])
            wellLockOn.alpha = 0.7
            addChild(wellLockOn)
            wellLockOn.xScale = scale
            wellLockOn.yScale = scale
            
        case .Exposed:
            let scale: CGFloat = lockOnRadius/25
            wellExposed = SKSpriteNode(texture: wellExposedOpenAnimation[0])
            addChild(wellExposed)
            wellExposed.xScale = scale
            wellExposed.yScale = scale
        }
    }
    
    func setupFillMeter() {
        fillMeter.zPosition = 1
        fillMeter.strokeColor = SKColor.whiteColor()
        fillMeter.fillColor = SKColor.clearColor()
        fillMeter.lineWidth = 3
        fillPath.moveToPoint(CGPointMake(0, lockOnRadius))
        addChild(fillMeter)
    }
    
    func updateLockOnTexture(numWells: Int) {
        if let lockOn = wellLockOn {
            switch numWells
            {
                case 1:
                    lockOn.texture = wellLockOnTextures[2]
                    
                case 2:
                    lockOn.texture = wellLockOnTextures[1]
                    
                case 3:
                    lockOn.texture = wellLockOnTextures[0]
                
                default:
                    lockOn.texture = wellLockOnTextures[0]
            }
        }
    }
    
    func resetWell() {
        lockProgress = 0.0
        lockedOn = false
        activated = true
    }
    
    func openWell() {
        switch(type)
        {
            case .Debug:
                break
                
            case .LockOn:
                break
                
            case .Exposed:
                let openAnim = SKAction.animateWithTextures(wellExposedOpenAnimation, timePerFrame: 0.033)
                let staticAnim = SKAction.animateWithTextures(wellExposedStaticAnimation, timePerFrame: 0.1, resize: true, restore: false)
                wellExposed.runAction(SKAction.sequence([ openAnim, SKAction.repeatActionForever(staticAnim) ]))
        }
    }
    
    func update( sceneTouch: CGPoint, dt: CFTimeInterval ) {
        if activated {
            if let u_scene = scene {
                let touchPos = u_scene.convertPoint(sceneTouch, toNode: self)
                let distance = Utilities2D.distanceSquaredFromPoint(CGPointZero, toPoint: touchPos)
                if distance < lockOnRadiusSq {
                    activate(activation: .FullPower)
                } else if distance < lockOnRadiusSq * 1.2 {
                    activate(activation: .HalfPower)
                } else {
                    activate(activation: .NoPower)
                }
                
                updateProgress(dt)
            }
        }
        if let lockOn = wellLockOn {
            lockOn.zRotation += 0.01
        }
    }
    
    func updateProgress(dt: CFTimeInterval) {
        // update activity based on activation
        
        var requestedEnergy: CGFloat = 0.0
        
        switch(activationLevel)
        {
            case .NoPower:
                lockProgress -= CGFloat(dt/2.0)
                
            case .HalfPower:
                requestedEnergy += CGFloat(dt/3.0)
                
            case .FullPower:
                requestedEnergy += CGFloat(dt)
        }
        
        let allottedEnergy = game.energyManager.useEnergy(requestedEnergy)
        lockProgress += allottedEnergy
        
        // clamp results
        lockProgress = Utilities2D.clamp(lockProgress, min: 0.0, max: lockDuration)
        
        if lockProgress <= 0.0 {
            fillMeter.hidden = true
        } else {
            fillMeter.hidden = false
        }
        
        if lockProgress >= lockDuration {
            lockedOn = true
        }
        
        // draw circle
        var mod: CGFloat = lockProgress/lockDuration
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
    
    func activate(#activation: EnergyWellActivation) {
        switch (activation)
        {
            case .NoPower:
                activationLevel = .NoPower
                wellDebug.strokeColor = SKColor.orangeColor()
                wellDebug.fillColor = SKColor.clearColor()
            case .HalfPower:
                activationLevel = .HalfPower
                wellDebug.strokeColor = SKColor.greenColor()
                wellDebug.fillColor = SKColor(red: 0, green: 1, blue: 0, alpha: 0.5)
            case .FullPower:
                activationLevel = .FullPower
                wellDebug.strokeColor = SKColor.greenColor()
                wellDebug.fillColor = SKColor.greenColor()
        }
    }
    
    func burst() {
        activated = false
        activationLevel = .NoPower
        fillMeter.runAction(SKAction.fadeOutWithDuration(0.5))
        switch(type)
        {
            case .Debug:
                wellDebug.strokeColor = SKColor.grayColor()
                wellDebug.fillColor = SKColor.clearColor()
                
            case .LockOn:
                break
                
            case .Exposed:
                let explodeAnim = SKAction.animateWithTextures(wellExplosionTextures, timePerFrame: 0.1, resize: true, restore: false)
                wellExposed.runAction(SKAction.sequence( [explodeAnim, SKAction.runBlock({
                    self.wellExposed.removeFromParent()
                })]))
                SoundManager.sharedManager().playSound("well_explosion.wav")
        }
        
    }
    
}