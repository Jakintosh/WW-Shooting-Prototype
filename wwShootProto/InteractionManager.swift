//
//  InteractionManager.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/21/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: -
class InteractionManager {
    
    // MARK: Data
    private var loadedInteractionGroups: [String : [String]]      = [String : [String]]()
    private var loadedInteractionData: [String : InteractionData] = [String : InteractionData]()
    private var interactionEntities: [String:InteractiveEntity] = [String:InteractiveEntity]()
    
    // MARK: File I/O
    func loadInteractions(groupKey: String, dataFile: String) {
//        if let filepath = NSBundle.mainBundle().pathForResource(dataFile, ofType: "plist") {
//            if let fileURL = NSURL(fileURLWithPath: filepath) {
//                if let contentsOfFile = NSDictionary(contentsOfURL: fileURL) {
//                    for (name, data) in contentsOfFile {
//                        let newData = InteractionData(data: data as NSDictionary)
//                        interactionData[name as String] = newData
//                    }
//                }
//            }
//        }
        loadedInteractionData["interaction1"] = InteractionData()
    }
    func releaseInteractions(groupKey: String?) {
        // if a valid group key is given, only remove that group
        if let key = groupKey {
            if let intGroup = loadedInteractionGroups[key] {
                for intKey in intGroup {
                    let spine = loadedInteractionData[intKey]
                    for (_, entity) in interactionEntities {
                        // modify entity
                    }
                    loadedInteractionData[intKey] = nil
                }
                loadedInteractionGroups[key] = nil
            } else {
                println("Tried to remove animation group but group doesn't exist")
            }
        }
    }
    
    // MARK: Something Else
    func update(dt: NSTimeInterval) {
        let hour = game.timeManager.currentHour()
        let minute = game.timeManager.currentMinute()
        
        for (_, interaction) in loadedInteractionData {
            if let entity = getEntity(interaction.triggerEntityKey) {
                
            }
            
        }
        
    }
        
    // MARK: Entity Management
    func registerEntity(key: String) -> InteractiveEntity {
        let newEntity = InteractiveEntity()
        interactionEntities[key] = newEntity
        return newEntity
    }
    func getEntity(key: String) -> InteractiveEntity? {
        return interactionEntities[key]
    }
    
}

// MARK: -
class InteractiveEntity {
    
    // MARK: Properties
    let displayNode: SKNode = SKNode()
    
    
    // MARK: Initializers
    
    
    // MARK: Methods
    
    
}

// MARK: -
// InteractionData
//
// Interaction Data stores all relevent information for a full interaction sequence. This
// includes all possible moments in an interaction, and the information on how to navigate
// through an interaction.

struct InteractionData {
    
    // MARK: Properties
    let startingMomentKey: String
    var currentMoment: InteractionMoment?
    
    // triggers
    let triggerEntityKey: String
    let hourOpen: Int
    let minuteOpen: Int
    let hourClose: Int
    let minuteClose: Int
    let activeRect: CGRect
    
    // MARK: Data
    private var moments: [String:InteractionMoment] = [String:InteractionMoment]()
    
    // MARK: Initializers
    
    init() {
        
        triggerEntityKey = "entity_dad"
        
        hourOpen = 18
        hourClose = 20
        minuteOpen = 0
        minuteClose = 0
        
        activeRect = CGRect(x: 0, y: 0, width: 500, height: 300)
        
        moments["moment1"] = InteractionMoment(data: NSDictionary())
        moments["moment2"] = InteractionMoment(data: NSDictionary())
        
        startingMomentKey = "moment1"
        currentMoment = moments[startingMomentKey]
    }
    
//    init(data: NSDictionary) {
//        // initialize all data
//        startingMomentKey = data["startingMomentKey"] as String
//        
//        // load in the moments
//        let loadedMoments: NSDictionary = data["moments"] as NSDictionary
//        for (name, data) in loadedMoments {
//            if let dataDictionary = data as? NSDictionary {
//                let newMoment = InteractionMoment(data: dataDictionary)
//                moments[name as String] = newMoment
//            } else {
//                println("tried to load data into moment in wrong format")
//            }
//        }
//        
//        currentMoment = getMoment(key: startingMomentKey)
//    }
//    
//    // MARK: Getters
//    func getMoment(#key: String) -> InteractionMoment? {
//        if let moment = moments[key] {
//            return moment
//        } else {
//            println("Tried to load InteractionMoment with invalid key")
//            return nil
//        }
//    }
//    func getEntityKey()         -> String? {
//        if let moment = currentMoment {
//            return moment.activeEntityKey
//        } else {
//            println("Tried to retrieve entity key with nil currentMoment")
//            return nil
//        }
//    }
//    func getTextInfo()          -> NSDictionary? {
//        if let moment = currentMoment {
//            return moment.textInfo
//        } else {
//            println("Tried to retrieve text info with nil currentMoment")
//            return nil
//        }
//    }
//    func getStartAnimationKey() -> String? {
//        if let moment = currentMoment {
//            return moment.startAnimationKey
//        } else {
//            println("Tried to retrieve startAnim key with nil currentMoment")
//            return nil
//        }
//    }
//    func getEndAnimationKey()   -> String? {
//        if let moment = currentMoment {
//            return moment.endAnimationKey
//        } else {
//            println("Tried to retrieve endAnim key with nil currentMoment")
//            return nil
//        }
//    }
//    func getCameraActionKey()   -> NSDictionary? {
//        if let moment = currentMoment {
//            return moment.cameraAction
//        } else {
//            println("Tried to retrieve camera action info with nil currentMoment")
//            return nil
//        }
//    }
//    
//    // MARK: Methods
//    mutating func moveToNextMoment() {
//        if let moment = currentMoment {
//            if let nextMomentKey = moment.nextMomentKey {
//                currentMoment = getMoment(key: nextMomentKey)
//            } else {
//                leaveInteraction()
//            }
//        } else {
//            println("Tried to move to next moment with nil currentMoment")
//        }
//    }
//    func leaveInteraction() {
//        
//    }
}


// MARK: -
struct InteractionCamera {
    
}


// MARK: -
// InteractionMoment
//
// An Interaction Moment is a single presentation of (non-)interactive bubbles. For example,
// one moment may be the daughter saying something, and another might be a choice the father
// has to make.
    //
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

struct InteractionMoment {

    // MARK: Properties
    let decisionLength: CGFloat
    
    let activeEntityKey: String
    let activeEntityChoices: [InteractionChoice] = [InteractionChoice]()
    
    let otherEntityKey: String
    let otherResponseText: String
    let otherCameraAction: String
    
    init(data: NSDictionary) {
        for i in 0..<3 {
            activeEntityChoices[i] = InteractionChoice(data: data)
        }
        
        decisionLength = 10.0
        activeEntityKey = "entity_dad"
        
        otherEntityKey = "entity_daughter"
        otherResponseText = "yo"
        otherCameraAction = ""
    }
    
}

struct InteractionChoice {
    
    // MARK: Properties
    let animationKey: String
    let nextMomentKey: String
    let text: String
    
    init(data: NSDictionary) {
        animationKey = "idle"
        nextMomentKey = "moment2"
        text = "hey"
    }
    
}