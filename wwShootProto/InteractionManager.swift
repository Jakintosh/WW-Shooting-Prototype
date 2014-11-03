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
// InteractionManager
//
// InteractionManager loads all interaction data, manages triggers, and runs the interactions
// once they are activated.

class InteractionManager {
    
    // MARK: Properties
    var activeInteractiveEntity: InteractiveEntity? = nil
    var hoverTrigger: InteractionTrigger? = nil
    var isInteracting: Bool = false
    var activeInteraction: InteractionData?
    var debugLayer: NHCNode = NHCNode()
    
    // MARK: Data
    private var loadedInteractionGroups: [String : [String]]      = [String : [String]]()
    private var loadedInteractionData: [String : InteractionData] = [String : InteractionData]()
    private var interactionTriggers: [InteractionTrigger]       = [InteractionTrigger]()
    private var interactionEntities: [String:InteractiveEntity] = [String:InteractiveEntity]()
    
    init() {
        
    }
    
    // MARK: File I/O
    func loadInteractions(groupKey: String, dataFile: String) {
        if let filepath = NSBundle.mainBundle().pathForResource(dataFile, ofType: "plist") {
            if let fileURL = NSURL(fileURLWithPath: filepath) {
                if let contentsOfFile = NSDictionary(contentsOfURL: fileURL) {
                    for (name, data) in contentsOfFile {
                        let newData = InteractionData(data: data as NSDictionary)
                        loadedInteractionData[newData.interactionID] = newData
                    }
                }
            }
        }
//        let newInteraction = InteractionData()
//        loadedInteractionData[newInteraction.interactionID] = newInteraction
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
        // otherwise, remove all interactions
        else {
            for (key, _) in loadedInteractionData {
                loadedInteractionData[key] = nil
        }   }
    }
    
    // MARK: Something Else
    func update(dt: NSTimeInterval) {
        if !isInteracting {
            if let activeEntityPosition = activeInteractiveEntity?.owner.position {
                let hour = game.timeManager.currentHour()
                var tempHovTrig: InteractionTrigger? = nil
                for trigger in interactionTriggers {
                    if trigger.checkEligibility(scenePoint: activeEntityPosition, currentHour: hour) {
                        tempHovTrig = trigger
                        break
                    }
                }
                if hoverTrigger?.linkedInteractionKey != tempHovTrig?.linkedInteractionKey {
                    if let oldHover = hoverTrigger {
                        dismissHoverForTrigger(oldHover)
                    }
                    if let newHover = tempHovTrig {
                        presentHoverForTrigger(newHover)
                    }
                    hoverTrigger = tempHovTrig
                }
            }
        } else {
            
        }
    }
    
    // interaction mnagement
    func presentHoverForTrigger(trigger: InteractionTrigger) {
        activeInteractiveEntity?.displayOption(trigger.linkedInteractionKey, { self.beginInteraction(trigger.linkedInteractionKey) } )
    }
    func dismissHoverForTrigger(trigger: InteractionTrigger) {
        activeInteractiveEntity?.dismissOption(1)
    }
    func beginInteraction(key: String) {
        
        // clear active entity options
        hoverTrigger = nil
        activeInteractiveEntity?.dismissOption(0)
        
        if let thisInteraction = loadedInteractionData[key] {
            activeInteraction = thisInteraction
            isInteracting = true
            
            // player cant move
            (activeInteractiveEntity?.owner as Character).canMove = false
            
            presentMoment(thisInteraction.startingMomentKey)
        }
    }
    func presentMoment(momentKey: String) {
        if momentKey != "end" {
            if let momentExists = activeInteraction?.moments[momentKey] {
                
                activeInteraction!.currentMoment = momentExists
                let thisMoment = activeInteraction!.currentMoment!
                let otherEntity = getEntity(activeInteraction!.otherEntityKey)!
                let activeEntity = getEntity(activeInteraction!.activeEntityKey)!
                
                // discard old info
                otherEntity.dismissOption(0)
                activeEntity.dismissOption(0)
                
                // set camera target
                let camera = activeInteractiveEntity!.displayNode.scene!.childNodeWithName("CamCon") as CameraController
//                let newPoint = Utilities2D.lerpFromPoint(otherEntity.displayNode.getScenePosition(), toPoint: activeEntity.displayNode.getScenePosition(), atPosition: 0.75)
                camera.setCameraPosition(thisMoment.cameraAction.position)
                camera.setScale(thisMoment.cameraAction.zoom)
                
                // display infos
                for choice in thisMoment.activeEntityChoices {
                    activeEntity.displayOption(choice.text, completion: { self.presentMoment(choice.nextMomentKey) } )
                }
                
                otherEntity.displayOption(thisMoment.otherResponseText, completion: {} )
            }
        } else {
            endInteraction()
        }
    }
    func endInteraction() {
        // TODO
        
        let thisMoment = activeInteraction!.currentMoment!
        let otherEntity = getEntity(activeInteraction!.otherEntityKey)!
        let activeEntity = getEntity(activeInteraction!.activeEntityKey)!
        activeInteraction!.currentMoment = nil
        
        otherEntity.dismissOption(0)
        activeEntity.dismissOption(0)
        
        (activeInteractiveEntity!.owner as Character).canMove = true
        
        isInteracting = false
        activeInteraction = nil
    }
    
    func setTrigger(point: CGPoint, radius: CGFloat, interactionKey: String, startHour: Int, endHour: Int) {
        let debug = SKShapeNode(circleOfRadius: radius)
        debug.position = point
        debug.fillColor = SKColor.clearColor()
        debug.strokeColor = SKColor.blueColor()
        debug.lineWidth = 3.0
        debugLayer.addChild(debug)
        
        let newTrigger = InteractionTrigger(sceneLocation: point, rad: radius, key: interactionKey, startHour: startHour, endHour: endHour, debug: debug)
        interactionTriggers.append(newTrigger)
    }
    
    // MARK: Entity Management
    func registerEntity(key: String, owner: NHCNode) -> InteractiveEntity {
        let newEntity = InteractiveEntity(owner: owner)
        interactionEntities[key] = newEntity
        return newEntity
    }
    func getEntity(key: String) -> InteractiveEntity? {
        return interactionEntities[key]
    }
    func setActiveEntity(key: String) {
        if let entity = getEntity(key) {
            activeInteractiveEntity = entity
        }
    }
    
}

// MARK: -
class InteractiveEntity {
    
    // MARK: Properties
    let displayNode: NHCNode = NHCNode()
    let owner: NHCNode
    
    let slot1: Button = Button(activeImageName: "button_default", defaultImageName: "button_default", action:  {} )
    let slot2: Button = Button(activeImageName: "button_default", defaultImageName: "button_default", action:  {} )
    let slot3: Button = Button(activeImageName: "button_default", defaultImageName: "button_default", action:  {} )
    let slot4: Button = Button(activeImageName: "button_default", defaultImageName: "button_default", action:  {} )
    
    let slot1Text: SKLabelNode = SKLabelNode()
    let slot2Text: SKLabelNode = SKLabelNode()
    let slot3Text: SKLabelNode = SKLabelNode()
    let slot4Text: SKLabelNode = SKLabelNode()
    
    
    // MARK: Initializers
    init(owner: NHCNode) {
        self.owner = owner
        
        slot1Text.horizontalAlignmentMode = .Center
        slot1Text.verticalAlignmentMode   = .Center
        slot2Text.horizontalAlignmentMode = .Center
        slot2Text.verticalAlignmentMode   = .Center
        slot3Text.horizontalAlignmentMode = .Center
        slot3Text.verticalAlignmentMode   = .Center
        slot4Text.horizontalAlignmentMode = .Center
        slot4Text.verticalAlignmentMode   = .Center
        
        slot1Text.fontName = "HelveticaNeue-Light"
        slot2Text.fontName = "HelveticaNeue-Light"
        slot3Text.fontName = "HelveticaNeue-Light"
        slot4Text.fontName = "HelveticaNeue-Light"
        
        slot1Text.fontSize = 12.0
        slot2Text.fontSize = 12.0
        slot3Text.fontSize = 12.0
        slot4Text.fontSize = 12.0
        
        slot1.addChild(slot1Text)
        slot2.addChild(slot2Text)
        slot3.addChild(slot3Text)
        slot4.addChild(slot4Text)
        
        slot1.position = CGPoint(x:  80, y:  60)
        slot2.position = CGPoint(x: 120, y:   0)
        slot3.position = CGPoint(x: 100, y: -60)
        slot4.position = CGPoint(x: -99, y:  25)
        
        displayNode.addChild(slot1)
        displayNode.addChild(slot2)
        displayNode.addChild(slot3)
        displayNode.addChild(slot4)
        
        slot1.hidden = true
        slot2.hidden = true
        slot3.hidden = true
        slot4.hidden = true
        
    }
    
    // MARK: Methods
    func displayOption(text: String, completion: ()->()) {
        if slot1.hidden {
            slot1.hidden = false
            slot1Text.text = text
            slot1.completionAction = completion
        } else if slot2.hidden {
            slot2.hidden = false
            slot2Text.text = text
            slot2.completionAction = completion
        } else if slot3.hidden {
            slot3.hidden = false
            slot3Text.text = text
            slot3.completionAction = completion
        } else if slot4.hidden {
            slot4.hidden = false
            slot4Text.text = text
            slot4.completionAction = completion
        }
        
    }
    
    func dismissOption(index: Int) {
        switch (index) {
        case 0:
            slot1.hidden = true
            slot1Text.text = ""
            slot1.completionAction = {}
            slot2.hidden = true
            slot2Text.text = ""
            slot2.completionAction = {}
            slot3.hidden = true
            slot3Text.text = ""
            slot3.completionAction = {}
            slot4.hidden = true
            slot4Text.text = ""
            slot4.completionAction = {}
            
        case 1:
            slot1.hidden = true
            slot1Text.text = ""
            slot1.completionAction = {}
            
        case 2:
            slot2.hidden = true
            slot2Text.text = ""
            slot2.completionAction = {}
            
        case 3:
            slot3.hidden = true
            slot3Text.text = ""
            slot3.completionAction = {}
            
        case 4:
            slot4.hidden = true
            slot4Text.text = ""
            slot4.completionAction = {}
            
        default:
            break
        }
    }
    
}

// MARK: -
// InteractionData
//
// Interaction Data stores all relevent information for a full interaction sequence. This
// includes all possible moments in an interaction, and the information on how to navigate
// through an interaction.

struct InteractionData {
    
    // MARK: Properties
    let interactionID: String
    let startingMomentKey: String
    let activeEntityKey: String
    let otherEntityKey: String
    var currentMoment: InteractionMoment?
    
    // trigger information
//    let hourOpen: Int
//    let hourClose: Int
//    let center: CGPoint
//    let radius: CGFloat
    
    // MARK: Data
    private var moments: [String: InteractionMoment] = [String: InteractionMoment]()
    
    // MARK: Initializers
    
    init() {
        
        // id
        interactionID = "cool_interaction"
        
        activeEntityKey = "entity_dad"
        otherEntityKey = "entity_daughter"
        
        // trigger info doesnt need to be saved
        let hourOpen: Int = 0
        let hourClose: Int = 24
        let center = CGPoint(x: 920, y: 880)
        let radius: CGFloat = 100.0
        game.interactionManager.setTrigger(center, radius: radius, interactionKey: interactionID, startHour: hourOpen, endHour: hourClose)
        
        // moments
        moments["moment1"] = InteractionMoment(data: NSDictionary())
        moments["moment2"] = InteractionMoment(data: NSDictionary())
        startingMomentKey = "moment1"
        currentMoment = moments[startingMomentKey]
    }
    
    init(data: NSDictionary) {
        // initialize all data
        interactionID = data["interactionID"] as String
        startingMomentKey = data["startingMomentKey"] as String
        
        activeEntityKey = data["activeEntityKey"] as String
        otherEntityKey = data["otherEntityKey"] as String
        
        // trigger info doesnt need to be saved
        let hourOpen: Int = data["hourOpen"] as Int
        let hourClose: Int = data["hourClose"] as Int
        let center = CGPoint(x: data["centerX"] as CGFloat, y: data["centerY"] as CGFloat)
        let radius: CGFloat = data["radius"] as CGFloat
        game.interactionManager.setTrigger(center, radius: radius, interactionKey: interactionID, startHour: hourOpen, endHour: hourClose)
        
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
//    func getEntityKey()         -> String? {
//        if let moment = currentMoment {
//            return moment.activeEntityKey
//        } else {
//            println("Tried to retrieve entity key with nil currentMoment")
//            return nil
//        }
//    }
}


// MARK: -
struct InteractionCamera {
    
    let position: CGPoint
    let zoom: CGFloat
    
    init (data: NSDictionary) {
        let positionData = data["position"] as NSDictionary
        position = CGPoint(x: positionData["x"] as CGFloat, y: positionData["y"] as CGFloat)
        zoom = data["zoom"] as CGFloat
    }
}

// MARK: - 
struct InteractionTrigger {
    
    let debugNode: SKShapeNode?
    
    // location
    let center: CGPoint
    let radius: CGFloat
    let radiusSq: CGFloat
    
    // time
    let triggerStartHour: Int
    let triggerEndHour: Int
    
    // keys
    let linkedInteractionKey: String
    
    init( sceneLocation: CGPoint, rad: CGFloat, key: String, startHour: Int, endHour: Int, debug: SKShapeNode? = nil) {
        center = sceneLocation
        radius = rad
        radiusSq = rad * rad
        linkedInteractionKey = key
        triggerStartHour = startHour
        triggerEndHour = endHour
        debugNode = debug
    }
    
    func checkEligibility( #scenePoint: CGPoint, currentHour: Int ) -> Bool {
        if currentHour >= triggerStartHour && currentHour < triggerEndHour {
            if Utilities2D.distanceSquaredFromPoint(scenePoint, toPoint: center) < radiusSq {
                debugNode?.strokeColor = SKColor.greenColor()
                return true
            } else {
                debugNode?.strokeColor = SKColor.blueColor()
                return false
            }
        } else {
            debugNode?.strokeColor = SKColor.blueColor()
            return false
        }
    }
}

// MARK: -
// InteractionMoment
//
// An Interaction Moment is a single presentation of (non-)interactive bubbles. For example,
// one moment may be the daughter saying something, and another might be a choice the father
// has to make.

struct InteractionMoment {

    // MARK: Properties
    let decisionLength: CGFloat
    let activeEntityChoices: [InteractionChoice] = [InteractionChoice]()
    let otherResponseText: String
    let cameraAction: InteractionCamera
    
    init(data: NSDictionary) {
        
        // load in choices from data
        let choices = data["choices"] as NSArray
        for choice in choices {
            let newChoice = InteractionChoice(data: choice as NSDictionary)
            activeEntityChoices.append(newChoice)
        }
        
        // load in remaining data
        decisionLength = data["decisionLength"] as CGFloat
        otherResponseText = data["responseText"] as String
        cameraAction = InteractionCamera(data: data["cameraInfo"] as NSDictionary )
    }
    
}

struct InteractionChoice {
    
    // MARK: Properties
    let animationKey: String
    let nextMomentKey: String
    let text: String
    
    init(data: NSDictionary) {
        animationKey = data["animation"] as String
        nextMomentKey = data["nextMomentKey"] as String
        text = data["text"] as String
    }
    
}