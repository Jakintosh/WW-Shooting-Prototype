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
    
    let ANIM_INTRO_CONSTANT_BAD_KILL_ME: CGFloat = 0.33
    
    // MARK: Properties
    var isInteracting: Bool                         = false
    var interactionHasEnded: Bool                   = false
    var activeInteraction: InteractionData?         = nil
    var activeInteractiveEntity: InteractiveEntity? = nil
    var hoverTrigger: InteractionTrigger?           = nil
    var debugLayer: NHCNode                         = NHCNode()
    var timingNode: NHCNode                         = NHCNode()
    
    var timeLeftInMoment: NSTimeInterval            = 0.0
    
    // MARK: Data
    private var loadedInteractionGroups: [String : [String]]      = [String : [String]]()
    private var loadedInteractionData: [String : InteractionData] = [String : InteractionData]()
    private var interactionTriggers: [InteractionTrigger]         = [InteractionTrigger]()
    private var interactionEntities: [String:InteractiveEntity]   = [String:InteractiveEntity]()
    
    init() {
        debugLayer.hidden = true
    }
    
    // MARK: File I/O
    func loadInteractions(groupKey: String, dataFile: String) {
        if let filepath = NSBundle.mainBundle().pathForResource(dataFile, ofType: "plist") {
            if let fileURL = NSURL(fileURLWithPath: filepath) {
                if let contentsOfFile = NSDictionary(contentsOfURL: fileURL) {
                    for (name, data) in contentsOfFile {
                        let newData = InteractionData(data: data as NSDictionary)
                        loadedInteractionData[newData.interactionID] = newData
        }   }   }   }
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
        }
//            else if !interactionHasEnded {
//                timeLeftInMoment -= dt
//                if timeLeftInMoment <= 0 {
//                    if let thisMoment = activeInteraction?.currentMoment {
//                        let timeOut = thisMoment.timeOutChoice
//                        executeMomentTransition(speech: timeOut.activeSpeech, animKey: timeOut.animationKey, animQueueKey: timeOut.animationQueueKey, nextMomentKey: timeOut.nextMomentKey)
//                    }
//                }
//                if let interaction = activeInteraction {
//                    if let thisMoment = interaction.currentMoment {
//                        if let entity = getEntity(interaction.otherEntityKey) {
//                            //entity.speech.updateSpeechAlpha(CGFloat(timeLeftInMoment)/thisMoment.decisionLength)
//                        }
//                    }
//                }
//                println("\(timeLeftInMoment)")
//            }
    }
    
    // interaction mnagement
    func presentHoverForTrigger(trigger: InteractionTrigger) {
        activeInteractiveEntity?.displayOption(trigger.linkedInteractionKey, completion: { self.beginInteraction(trigger.linkedInteractionKey) } )
    }
    func dismissHoverForTrigger(trigger: InteractionTrigger) {
        activeInteractiveEntity?.dismissOption(1)
    }
    func beginInteraction(key: String) {
        
        // clear active entity options
        for i in 0..<interactionTriggers.count {
            if interactionTriggers[i].linkedInteractionKey == key {
                interactionTriggers.removeAtIndex(i)
                break
            }
        }
        
        hoverTrigger = nil
        activeInteractiveEntity?.dismissOption(0)
        
        if let thisInteraction = loadedInteractionData[key] {
            activeInteraction = thisInteraction
            isInteracting = true
            
            // player cant move
            (activeInteractiveEntity?.owner as Dad).interact()
            (activeInteractiveEntity?.owner as Dad).facePoint(getEntity(thisInteraction.otherEntityKey)!.displayNode.getScenePosition())
            
            presentMoment(thisInteraction.startingMomentKey, startDelay: 0.0)
        }
    }
    func executeMomentTransition(#speech: String, animKey: String, animQueueKey: String, nextMomentKey: String) {
        if let interaction = activeInteraction {
            if let animEntity: AnimatableEntity = game.animationManager.getEntity(interaction.activeEntityKey) {
                animEntity.setQueuedAnimation(animQueueKey, introPeriod: ANIM_INTRO_CONSTANT_BAD_KILL_ME)
                animEntity.playAnimation(animKey, introPeriod: ANIM_INTRO_CONSTANT_BAD_KILL_ME)
            }
            var offsetTotal: NSTimeInterval = 0.0
            if speech != "" {
                if let entity = getEntity(interaction.activeEntityKey) {
                    offsetTotal += 3.25
                    entity.displaySpeech(speech, delay: 0.25)
                    entity.dismissSpeech(delay: offsetTotal)
                }
            }
            if let aEntity = getEntity(interaction.activeEntityKey) {
                aEntity.dismissOption(0, delay: 0.0)
            }
            if let oEntity = getEntity(interaction.otherEntityKey) {
                oEntity.dismissSpeech(delay: 0.125)
            }
            offsetTotal += 0.75
            presentMoment(nextMomentKey, startDelay: offsetTotal)
        }
    }
    func presentMoment(momentKey: String, startDelay: NSTimeInterval = 0.0) {
        if momentKey != "end" {
            if let momentExists = activeInteraction?.moments[momentKey] {
                
                activeInteraction!.currentMoment = momentExists
                let thisMoment = activeInteraction!.currentMoment!
                let otherEntity = getEntity(activeInteraction!.otherEntityKey)!
                let activeEntity = getEntity(activeInteraction!.activeEntityKey)!
                
                // set timings
                timeLeftInMoment = NSTimeInterval(thisMoment.decisionLength)
                let choiceDisplayOffset: NSTimeInterval = 1.5 + startDelay
                let otherSpeechDisplayOffset: NSTimeInterval = startDelay
                
                // set camera target
                let camera = activeInteractiveEntity!.displayNode.scene!.childNodeWithName("CamCon") as CameraController
                camera.setCameraPosition(thisMoment.cameraAction.position)
                camera.setScale(thisMoment.cameraAction.zoom)
                
                // display infos
                var i: NSTimeInterval = 0
                otherEntity.displaySpeech(thisMoment.otherResponseText, delay: otherSpeechDisplayOffset)
                for choice in thisMoment.activeEntityChoices {
                    activeEntity.displayOption(choice.text,
                        completion: { self.executeMomentTransition(speech: choice.activeSpeech, animKey: choice.animationKey, animQueueKey: choice.animationQueueKey, nextMomentKey: choice.nextMomentKey) },
                                                delay: (i * 0.25 + choiceDisplayOffset) )
                    i += 1.0
                }
                
                // run initial animations
                for (entityKey, info) in thisMoment.startAnimations {
                    if let animEnt: AnimatableEntity = game.animationManager.getEntity(entityKey as String) {
                        animEnt.setQueuedAnimation(info["queue"] as String, introPeriod: ANIM_INTRO_CONSTANT_BAD_KILL_ME)
                        animEnt.playAnimation( info["key"] as String, introPeriod: ANIM_INTRO_CONSTANT_BAD_KILL_ME )
                    }
                }
            }
        } else {
            if let interaction = activeInteraction {
                if let entity = getEntity(interaction.activeEntityKey) {
                    interactionHasEnded = true
                    entity.displayNode.runAction(SKAction.sequence([ SKAction.waitForDuration(startDelay), SKAction.runBlock({ self.endInteraction() }) ]))
                }
            }
        }
    }
    func endInteraction() {
        
        // get all of the current objects
        let otherEntity = getEntity(activeInteraction!.otherEntityKey)!
        let activeEntity = getEntity(activeInteraction!.activeEntityKey)!
        activeInteraction!.currentMoment = nil
        
        let otherChar = (otherEntity.owner as Character)
        otherChar.animator.setQueuedAnimation(otherChar.defaultAnimationKey, introPeriod: ANIM_INTRO_CONSTANT_BAD_KILL_ME)
        otherChar.animator.playAnimation(otherChar.defaultAnimationKey, introPeriod: ANIM_INTRO_CONSTANT_BAD_KILL_ME)
        
        activeEntity.endInteraction()
        (activeInteractiveEntity!.owner as Dad).stopInteracting()
        
        interactionHasEnded = false
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
    
    var completion: () -> () = { }
    
    // buttons
    let slot1:  InteractiveButton = InteractiveButton(type: .Option)
    let slot2:  InteractiveButton = InteractiveButton(type: .Option)
    let slot3:  InteractiveButton = InteractiveButton(type: .Option)
    let speech: InteractiveButton = InteractiveButton(type: .Speech)
    
    // MARK: Initializers
    init(owner: NHCNode) {
        self.owner = owner
        
        slot2.targetPosition = CGPoint(x:  -70, y:  60)
        slot1.targetPosition = CGPoint(x: -100, y:   0)
        slot3.targetPosition = CGPoint(x:  -90, y: -60)
        speech.targetPosition = CGPoint(x:  75, y:  10)
        
        displayNode.addChild(slot1)
        displayNode.addChild(slot2)
        displayNode.addChild(slot3)
        displayNode.addChild(speech)
    }
    
    // MARK: Methods
    func setMirrored(mirrored: Bool) {
        if !mirrored {
            slot2.targetPosition = CGPoint(x: -70, y:  60)
            slot1.targetPosition = CGPoint(x:-100, y:   0)
            slot3.targetPosition = CGPoint(x: -90, y: -60)
            speech.targetPosition = CGPoint(x: 75, y:  10)
        } else {
            slot2.targetPosition = CGPoint(x:  70, y:  60)
            slot1.targetPosition = CGPoint(x: 100, y:   0)
            slot3.targetPosition = CGPoint(x:  80, y: -60)
            speech.targetPosition = CGPoint(x:-75, y:  10)
        }
    }
    func displayOption(text: String, completion: ()->(), delay: NSTimeInterval = 0) {
        let display: () -> () =   {
            if !self.slot1.isPresented {
                self.slot1.text = text
                self.slot1.completionAction = completion
                self.slot1.isPresented = true
            } else if !self.slot2.isPresented {
                self.slot2.text = text
                self.slot2.completionAction = completion
                self.slot2.isPresented = true
            } else if !self.slot3.isPresented {
                self.slot3.text = text
                self.slot3.completionAction = completion
                self.slot3.isPresented = true
            }
        }
        
        if delay > 0 {
            displayNode.runAction(SKAction.sequence([SKAction.waitForDuration(delay),SKAction.runBlock(display)]))
        } else {
            display()
        }
    }
    func displaySpeech(text: String, delay: NSTimeInterval = 0) {
        
        let display: () -> () = {
            self.speech.text = text
            self.speech.isPresented = true
        }
        
        if delay > 0 {
            displayNode.runAction(SKAction.sequence([SKAction.waitForDuration(delay),SKAction.runBlock(display)]))
        } else {
            display()
        }
    }
    func dismissOption(index: Int, delay: NSTimeInterval = 0) {
        let dismiss: () -> () = {
            switch (index)
            {
                case 1:
                    self.slot1.isPresented = false
                    
                case 2:
                    self.slot2.isPresented = false
                    
                case 3:
                    self.slot3.isPresented = false
                    
                default:
                    self.slot1.isPresented = false
                    self.slot2.isPresented = false
                    self.slot3.isPresented = false
            }
        }
        if delay > 0 {
            displayNode.runAction(SKAction.sequence([SKAction.waitForDuration(delay),SKAction.runBlock(dismiss)]))
        } else {
            dismiss()
        }
    }
    func dismissSpeech(delay: NSTimeInterval = 0) {
        let dismiss: () -> () = {
            self.speech.isPresented = false
        }
        
        if delay > 0 {
            displayNode.runAction(SKAction.sequence([SKAction.waitForDuration(delay),SKAction.runBlock(dismiss)]))
        } else {
            dismiss()
        }
    }
    
    func endInteraction() {
        completion()
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
    let timeOutChoice: InteractionChoice
    let otherResponseText: String
    let cameraAction: InteractionCamera
    let startAnimations: NSDictionary
    let endAnimations: NSDictionary
    
    init(data: NSDictionary) {
        
        // load in choices from data
        timeOutChoice = InteractionChoice( data: data["timeOut"] as NSDictionary )
        let choices = data["choices"] as NSArray
        for choice in choices {
            let newChoice = InteractionChoice(data: choice as NSDictionary)
            activeEntityChoices.append(newChoice)
        }
        
        // load in remaining data
        startAnimations = data["startAnimations"] as NSDictionary
        endAnimations = data["endAnimations"] as NSDictionary
        decisionLength = data["decisionLength"] as CGFloat
        otherResponseText = data["responseText"] as String
        cameraAction = InteractionCamera(data: data["cameraInfo"] as NSDictionary )
    }
    
}

struct InteractionChoice {
    
    // MARK: Properties
    let animationKey: String
    let animationQueueKey: String
    let nextMomentKey: String
    let text: String
    let activeSpeech: String
    
    init(data: NSDictionary) {
        animationKey = data["animation"] as String
        animationQueueKey = data["animationQueue"] as String
        nextMomentKey = data["nextMomentKey"] as String
        text = data["text"] as String
        activeSpeech = data["speech"] as String
    }
    
}