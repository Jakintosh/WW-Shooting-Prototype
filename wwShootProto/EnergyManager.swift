//
//  EnergyManager.swift
//  wwShootProto
//
//  Created by Jak Tiano on 11/20/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation

class EnergyManager {
    
    var currentEnergy: CGFloat = 50.0
    let energyCap: CGFloat = 100.0
    
    func reset(startValue: CGFloat = 50.0) {
        currentEnergy = startValue
    }
    
    func addEnergy(amount: CGFloat) {
        var a = amount
        if a < 0 { a = 0 }
        currentEnergy += a
        if currentEnergy > 100.0 {
            currentEnergy = 100.0
        }
    }
    
    func useEnergy(amount: CGFloat) -> CGFloat {
        var a = amount
        if a < 0 { a = 0 }
        if currentEnergy > a {
            currentEnergy -= a
            return a
        } else {
            currentEnergy = 0
            return currentEnergy
        }
    }
    
    func update(dt: CFTimeInterval) {
        
    }
}