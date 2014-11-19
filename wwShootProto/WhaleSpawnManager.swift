//
//  WhaleSpawnManager.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/18/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class WhaleSpawnManager {
    
    
    enum HeatLevel {
        case Low, Mid, High, End
    }
    
    
    // properties
    var heatLevel: HeatLevel
    
    // components
    
    
    init() {
        heatLevel = .Low
    }
    
    func update() {
        
    }
    
    // must keep track of the current whales in play
    func createWhale() {
        
    }
    func destroyWhale() {
        
    }
    
    // must spawn new whales to keep challenge mapped to heat level
    
    
    // must increase heat level appropriately
    
}