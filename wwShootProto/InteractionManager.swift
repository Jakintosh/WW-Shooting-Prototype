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
// InteractionData
//
// Interaction Data stores all relevent information for a full interaction sequence. This
// includes all possible moments in an interaction, and the information on how to navigate
// through an interaction.

struct InteractionData {
    
    // MARK: Properties
    let startingMomentKey: String
    var currentMoment: InteractionMoment?
    
    // MARK: Data
    private var moments: [String:InteractionMoment] = [String:InteractionMoment]()
    
    // MARK: Initializers
    init(data: NSDictionary) {
        // initialize all data
        startingMomentKey = data["startingMomentKey"] as String
        
        // load in the moments
        let loadedMoments: NSDictionary = data["moments"] as NSDictionary
        for (name, data) in loadedMoments {
            if let dataDictionary = data as? NSDictionary {
                let newMoment = InteractionMoment(data: dataDictionary)
                moments[name as String] = newMoment
            } else {
                println("tried to load data into moment in wrong format")
            }
        }
        
        
        currentMoment = getMoment(key: startingMomentKey)
    }
    
    // MARK: Getters
    func getMoment(#key: String) -> InteractionMoment? {
        if let moment = moments[key] {
            return moment
        } else {
            println("Tried to load InteractionMoment with invalid key")
            return nil
        }
    }
    func getEntityKey()         -> String? {
        if let moment = currentMoment {
            return moment.activeEntityKey
        } else {
            println("Tried to retrieve entity key with nil currentMoment")
            return nil
        }
    }
    func getTextInfo()          -> NSDictionary? {
        if let moment = currentMoment {
            return moment.textInfo
        } else {
            println("Tried to retrieve text info with nil currentMoment")
            return nil
        }
    }
    func getStartAnimationKey() -> String? {
        if let moment = currentMoment {
            return moment.startAnimationKey
        } else {
            println("Tried to retrieve startAnim key with nil currentMoment")
            return nil
        }
    }
    func getEndAnimationKey()   -> String? {
        if let moment = currentMoment {
            return moment.endAnimationKey
        } else {
            println("Tried to retrieve endAnim key with nil currentMoment")
            return nil
        }
    }
    func getCameraActionKey()   -> String? {
        if let moment = currentMoment {
            return moment.cameraActionKey
        } else {
            println("Tried to retrieve camera action key with nil currentMoment")
            return nil
        }
    }
    
    // MARK: Methods
    mutating func moveToNextMoment() {
        if let moment = currentMoment {
            if let nextMomentKey = moment.nextMomentKey {
                currentMoment = getMoment(key: nextMomentKey)
            } else {
                leaveInteraction()
            }
        } else {
            println("Tried to move to next moment with nil currentMoment")
        }
    }
    func leaveInteraction() {
        
    }
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
    let activeEntityKey: String
    let textInfo: NSDictionary
    let startAnimationKey: String?
    let endAnimationKey: String?
    let cameraActionKey: String
    let nextMomentKey: String?
    
    init(data: NSDictionary) {
        activeEntityKey     = data["activeEntityKey"] as String
        textInfo            = data["textInfo"] as NSDictionary
        startAnimationKey   = data["startAnimationKey"] as String?
        endAnimationKey     = data["endAnimationKey"] as String?
        cameraActionKey     = data["cameraActionKey"] as String
        nextMomentKey       = data["nextMomentKey"] as String?
    }
    
}

// MARK: -
class InteractionManager {
    
    // MARK: Data
    private var dialogue: [String:String] = [String:String]()
    private var animations: [String:Int] = [String:Int]()
    private var cameraMoments: [String:InteractionCamera] = [String:InteractionCamera]()
    
    // MARK: Properties
    private var entities: [String:InteractiveEntity] = [String:InteractiveEntity]()
    private var interactionData: [String:InteractionData] = [String:InteractionData]()
    
    // MARK: Initializers
    init(fileName: String) {
        if let filepath = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist") {
            if let fileURL = NSURL(fileURLWithPath: filepath) {
                if let contentsOfFile = NSDictionary(contentsOfURL: fileURL) {
                    for (name, data) in contentsOfFile {
                        let newData = InteractionData(data: data as NSDictionary)
                        interactionData[name as String] = newData
                    }
                }
            }
        }
    }
    
    // MARK: Methods
    func createNewEntity(#name: String, ownerNode: SKNode) -> InteractiveEntity {
        let newEntity = InteractiveEntity(ownerNode: ownerNode)
        if entities.indexForKey(name) != nil { entities[name] = newEntity }
        return newEntity
    }
    
    func getEntityNamed(name: String) -> InteractiveEntity? {
        return entities[name]
    }
    
}

// MARK: -
class InteractiveEntity {
    
    // MARK: Properties
    let ownerNode: SKNode
    let displayNode: SKNode = SKNode()
    
    var loadedTextInfo: NSDictionary? = nil
    
    // MARK: Initializers
    init(ownerNode: SKNode) {
        self.ownerNode = ownerNode
    }
    
    // MARK: Methods
    func loadTextInfo(textInfo: NSDictionary) {
        loadedTextInfo = textInfo
    }
    
}

// MARK: -
class InteractiveDisplayNode : SKFuckNode {
    
    // MARK: Properties
    
}