//
//  InteractionManager.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/21/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

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