//
//  TimeManager.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/27/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation

class TimeManager {
    
    // MARK: Properties
    private var currentTimeOfDaySeconds: CGFloat = 0
    private var secondsPerSecond: CGFloat = 960.0 / 3.0 // divisor is num minutes
    private var militaryTime: Bool = false
    
    // MARK: Initializers
    init() {
        reset()
    }
    
    func reset() {
        currentTimeOfDaySeconds = 8 * (60*60) // start off at 5pm
    }
    
    // MARK: Methods
    func update(dt:NSTimeInterval) {
        currentTimeOfDaySeconds += CGFloat(dt) * secondsPerSecond
    }
    
    func currentTimeString() -> String {
        let hour = Int(currentDisplayHour())
        let minute = Int(currentMinute())
        let postfix = currentPostfix()
        return String(format: "%01d:%02d %@", hour, minute, postfix)
    }
    
    func currentPostfix() -> String {
        if militaryTime {
            return ""
        } else {
            if currentHour() < 12 {
                return "AM"
            } else {
                return "PM"
            }
        }
    }
    
    func currentDisplayHour() -> Int {
        let rawHour: Int = currentHour()
        if militaryTime {
            return rawHour
        } else {
            var dumbHour = rawHour % 12
            if dumbHour == 0 {
                dumbHour = 12
            }
            return Int(dumbHour)
        }
    }
    
    func currentHour() -> Int {
        return Int(floor(currentTimeOfDaySeconds / 3600.0)) % 24
    }
    
    func currentMinute() -> Int {
        return Int( floor((currentTimeOfDaySeconds % 3600.0)/60.0) )
    }
    
    func currentDecimalTime() -> CGFloat {
        return CGFloat(currentHour()) + CGFloat((currentTimeOfDaySeconds % 3600.0)/60.0)/60.0
    }
    
}