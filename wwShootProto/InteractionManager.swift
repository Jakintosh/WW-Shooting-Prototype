//
//  InteractionManager.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/21/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

// InteractionData
//
// Interaction Data stores all relevent information for a full interaction sequence. This
// includes all possible moments in an interaction, and the information on how to navigate
// through an interaction.

struct InteractionData {
    
}


// InteractionMoment
//
// An Interaction Moment is a single presentation of (non-)interactive bubbles. For example,
// one moment may be the daughter saying something, and another might be a choice the father
// has to make.

struct InteractionMoment {
    // what data must this contain?
    //
    // • character involved
    // • all relevant dialogue for each character
    // • all relevant animations for each character
    // • all camera queues
    // • next moment name
    
    // properties
/*
    var activeEntity: InteractiveEntity
    var dialogueKey: String
    var startAnimationKey: String?
    var endAnimationKey: String?
    var cameraAction: idfk
    var nextMomentKey: String
*/
    
    // what happens before
    //
    // • characters must be in position
    //
    // what happens during
    //
    // • dialogue is played
    // • animations are played
    // • camera is pan/zoomed
    //
    // what happens after
    //
    // • transitions to next moment
    // • optionally plays new animations
}

class InteractionManager {
    
    // MARK: Properties
    private var entities: [String:InteractiveEntity] = [String:InteractiveEntity]()
    
    // MARK: Initializers
    init() {
        
    }
    
    // MARK: Methods
    func createNewEntity(#name: String) -> InteractiveEntity {
        let newEntity = InteractiveEntity()
        if entities.indexForKey(name) != nil { entities[name] = newEntity }
        return newEntity
    }
    
    func getEntityNamed(name: String) -> InteractiveEntity? {
        return entities[name]
    }
    
}

class InteractiveEntity : SKFuckNode {
    
    // MARK: Properties
    
    
    
    // MARK: Initializers
    
    
    
    // MARK: Methods
    
    
}