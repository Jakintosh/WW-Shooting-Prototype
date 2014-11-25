//
//  Game.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/27/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import CoreMotion

class Game {
    
    var currentFail: String = "DayZeroSuccess"
    
    let animationManager:    AnimationManager    = AnimationManager()
    let interactionManager:  InteractionManager  = InteractionManager()
    let timeManager:         TimeManager         = TimeManager()
    let whaleSpawnManager:   WhaleSpawnManager   = WhaleSpawnManager()
    let energyManager:       EnergyManager       = EnergyManager()
    let screamManager:       ScreamingManager    = ScreamingManager()
    let motionManager:       CMMotionManager     = CMMotionManager()
    
}

var game: Game!