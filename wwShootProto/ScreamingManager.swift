//
//  ScreamingManager.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/21/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation

class ScreamingManager {
    
    var camCon: CameraController! = nil
    var maxScreaming: CGFloat = 5.0
    var screamingLevel: CGFloat = 0.0
    var percentage: CGFloat {
        return self.screamingLevel/self.maxScreaming
    }
    
    func reset(startValue: CGFloat = 0.0) {
        screamingLevel = startValue
    }
    
    func update(dt: CFTimeInterval, totalScreams: CGFloat) {
        
        if totalScreams == 0.0 {
            screamingLevel -= CGFloat(dt)*2.0
        } else {
            screamingLevel += totalScreams
        }
        
        screamingLevel = Utilities2D.clamp(screamingLevel, min: 0, max: maxScreaming)
        
        camCon.shake(percentage * 20.0, duration: 1.0)
//        println(screamingLevel)
    }
    
    func getFade() -> CGFloat {
        return percentage
    }
}