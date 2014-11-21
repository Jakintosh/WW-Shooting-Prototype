//
//  ScreamingManager.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/21/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation

class ScreamingManager {
    
    var screamingLevel: CGFloat = 0.0
    var camCon: CameraController! = nil
    
    func reset(startValue: CGFloat = 50.0) {
        screamingLevel = startValue
    }
    
    func update(dt: CFTimeInterval, totalScreams: CGFloat) {
        camCon.shake(totalScreams, duration: (1.0/60.0))
    }
    
    
}