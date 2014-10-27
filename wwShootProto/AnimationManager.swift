//
//  AnimationManager.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/27/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation

// MARK: -
class AnimationManager {
    
    // Animations are loaded first, then entities are created
    // Entities are assigned their spines seperately
    // Spines can be swapped on entities
    
    // MARK: Data
    private var loadedAnimationGroups: [String : [String]]      = [String : [String]]()
    private var loadedAnimations:   [String : SGG_Spine]        = [String : SGG_Spine]()
    private var animatableEntities: [String : AnimatableEntity] = [String : AnimatableEntity]()
    
    // MARK: File I/O
    func loadAnimations(groupKey: String, dataFile: String) {
        
        // holds all animations loaded now
        var animationsBeingLoaded: [String] = [String]()
        
        // load all animations from a file with specified name
        if let filepath = NSBundle.mainBundle().pathForResource(dataFile, ofType: "plist") {
            if let fileURL = NSURL(fileURLWithPath: filepath) {
                if let contentsOfFile = NSArray(contentsOfURL: fileURL) {
                    for item in contentsOfFile {
                        let definition = item as NSDictionary
                        let name = definition["name"] as String
                        let json = definition["json"] as String
                        let atlas = definition["atlas"] as String
                        
                        let newSpineAnimation = SGG_Spine()
                        newSpineAnimation.skeletonFromFileNamed(json, andAtlasNamed: atlas, andUseSkinNamed: nil)
                        loadedAnimations[name] = newSpineAnimation
                        
                        animationsBeingLoaded.append(name)
        }   }   }   }
        
        // if any animations were loaded, push them onto the loaded animation group array
        if animationsBeingLoaded.count > 0 { loadedAnimationGroups[groupKey] = animationsBeingLoaded }
    }
    func releaseAnimations(groupKey: String?) {
        // if a valid group key is given, only remove that group
        if let key = groupKey {
            if let animGroup = loadedAnimationGroups[key] {
                for animKey in animGroup {
                    let spine = loadedAnimations[animKey]
                    for (_, entity) in animatableEntities {
                        entity.removeSpine(spine)
                    }
                    loadedAnimations[animKey] = nil
                }
                loadedAnimationGroups[key] = nil
            } else {
                println("Tried to remove animation group but group doesn't exist")
            }
        }
        // otherwise, remove all animations
        else {
            for (key, _) in loadedAnimations {
                loadedAnimations[key] = nil
        }   }
    }
    
    // MARK: Entity Management
    func registerEntity(name: String) -> AnimatableEntity {
        let newAnimatableEntity = AnimatableEntity()
        animatableEntities[name] = newAnimatableEntity
        return newAnimatableEntity
    }
    func removeEntity(name: String) {
        if let entity = animatableEntities[name] {
            entity.animationSpine?.removeFromParent()
            animatableEntities[name] = nil
        }
    }
    func setSpineForEntity(spineKey: String, entityKey: String) {
        if let spine = loadedAnimations[spineKey] {
            if let entity = animatableEntities[entityKey] {
                entity.setSpine(spine)
            } else {
                println("tried to assign spine to entity but entitiy doesn't exist for key")
            }
        } else {
            println("tried to assign spine to entity but spine doesn't exist or hasn't been loaded for key")
        }
    }
    func runAnimation(entityKey: String, animationName: String, introPeriod: CGFloat) {
        if let entity = animatableEntities[entityKey] {
            entity.playAnimation(animationName, introPeriod: introPeriod)
        }
    }
}

// MARK: -
class AnimatableEntity {
    
    // MARK: Properties
    var animationSpine: SGG_Spine? = nil
    
    // MARK: Methods
    func update(dt: NSTimeInterval) {
        animationSpine?.activateAnimations()
    }
    
    // MARK: Spine Management
    func setSpine(spine:SGG_Spine) {
        if animationSpine != nil {
            removeSpine(animationSpine)
        }
        animationSpine = spine
    }
    func removeSpine(spine: SGG_Spine?) {
        if spine === animationSpine && spine != nil {
            animationSpine!.stopAnimation()
            animationSpine = nil
        }
    }
    
    // MARK: Animations
    func setupSpine(defaultAnimation: String, introPeriod: CGFloat = 0.1) {
        if let spine = animationSpine {
            spine.queuedAnimation = defaultAnimation
            spine.queueIntro = introPeriod
            spine.runAnimation(defaultAnimation, andCount: 0, withIntroPeriodOf: introPeriod, andUseQueue: true)
        }
    }
    func playAnimation(name: String, introPeriod: CGFloat) {
        if let spine = animationSpine {
            spine.runAnimation(name, andCount: 0, withIntroPeriodOf: introPeriod, andUseQueue: true)
        }
    }
}