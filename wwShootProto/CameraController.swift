//
//  Camera.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/5/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

class CameraController : SKNode, UIGestureRecognizerDelegate {
    
    // camera properties
    var camera: CGPoint
    var lerpSpeed: Float = 0.1 // 0 - doesn't move, 1 - locked to target
    
    // camera components
    let zoomNode: SKNode
    let rootNode: SKNode
    let hudNode: SKNode
    
    let blurFilter: CIFilter
    
    // other
    var debugMode: Bool
    
    private let pinchGestureRecognizer: UIPinchGestureRecognizer?
    private let panGestureRecognizer: UIPanGestureRecognizer?
    
    // MARK: - CameraController
    
    override init() {
        camera = CGPointZero
        zoomNode = SKNode()
        rootNode = SKNode()
        hudNode = SKNode()
        blurFilter = CIFilter(name: "CIGaussianBlur")
        debugMode = false
        super.init()
        
        zoomNode.name = "Zoom Node"
        rootNode.name = "Root Node"
        hudNode.name  = "HUD Node"
        
        zoomNode.zPosition = 0.0
        rootNode.zPosition = 0.0
        hudNode.zPosition = 1000.0
        
        blurFilter.setDefaults()
        blurFilter.setValue(30.0, forKey: "inputRadius")
        
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panGestureRecognizer?.maximumNumberOfTouches = 1
        
        addChild(hudNode)
        addChild(zoomNode)
        zoomNode.addChild(rootNode)
    }
    
    required init(coder aDecoder: NSCoder) {
        camera = CGPointZero
        zoomNode = SKNode()
        rootNode = SKNode()
        hudNode = SKNode()
        blurFilter = CIFilter(name: "CIGaussianBlur")
        debugMode = false
        super.init(coder: aDecoder)
    }
    
    func update(dt: NSTimeInterval) {
        rootNode.position = Utilities2D.lerpFromPoint(rootNode.position, toPoint: CGPointMake(-camera.x, -camera.y), atPosition: CGFloat(lerpSpeed))
    }
    
    func addCameraChild(inNode: SKNode, withZ z: Float) {
        rootNode.addChild(inNode)
        inNode.zPosition = CGFloat(z)
    }
    
    func addHUDChild(inNode: SKNode, withZ z: Float) {
        hudNode.addChild(inNode)
        inNode.zPosition = CGFloat(z)
    }
    
    func removeCameraChildren(nodes: SKNode...) {
        rootNode.removeChildrenInArray(nodes)
    }
    
    func removeHUDChildren(nodes: SKNode...) {
        hudNode.removeChildrenInArray(nodes)
    }
    
    func convertScenePointToCamera(point: CGPoint) -> CGPoint {
        return Utilities2D.subPoint(rootNode.position, fromPoint: point)
    }
    
    func blurRootNode() {
//        rootNode.shouldCenterFilter = true
//        rootNode.shouldEnableEffects = true
//        rootNode.shouldRasterize = true
//        rootNode.filter = blurFilter
    }
    
    func resetEffects() {
//        rootNode.shouldCenterFilter = false
//        rootNode.shouldEnableEffects = false
//        rootNode.shouldRasterize = false
//        rootNode.filter = nil
    }
    

//    MARK: - Getters/Setters
    
    func setCameraStartingPosition(position: CGPoint) {
        camera = position
        rootNode.position = CGPointMake(-position.x, -position.y)
    }
    
    func setCameraPosition(target: CGPoint) {
        camera = target
    }
    
    func setRootScale(scale: Float) {
        zoomNode.xScale = CGFloat(scale)
        zoomNode.yScale = CGFloat(scale)
    }
    
    func getRootScale() -> Float {
        return Float(zoomNode.xScale)
    }
    
    func enableDebug() {
        debugMode = true
        pinchGestureRecognizer?.enabled = true
        panGestureRecognizer?.enabled = true
    }
    
    func disableDebug() {
        debugMode = false
        pinchGestureRecognizer?.enabled = false
        panGestureRecognizer?.enabled = false
    }
    
//    MARK: - Gesture Recognizers
    
    func connectGestureRecognizers(view: SKView) {
        if let pinch = pinchGestureRecognizer {
            view.addGestureRecognizer(pinch)
        }
        if let pan = panGestureRecognizer {
            view.addGestureRecognizer(pan)
        }
    }
    
    func disconnectGestureRecognizers(view: SKView) {
        if let pinch = pinchGestureRecognizer {
            view.removeGestureRecognizer(pinch)
        }
        if let pan = panGestureRecognizer {
            view.removeGestureRecognizer(pan)
        }
    }
    
    func handlePinch(gestureRecognizer: UIPinchGestureRecognizer) {
        if debugMode {
            if gestureRecognizer.state == .Began {
                gestureRecognizer.scale = self.zoomNode.xScale
            }
            let scale: CGFloat = gestureRecognizer.scale
            zoomNode.xScale = scale
            zoomNode.yScale = scale
        }
    }
    
    func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        if debugMode {
            if gestureRecognizer.state == .Changed {
                var translation: CGPoint = gestureRecognizer.translationInView(gestureRecognizer.view!)
                translation = CGPointMake(translation.x, -translation.y)
                camera = CGPointMake(camera.x - translation.x, camera.y - translation.y)
                gestureRecognizer.setTranslation(CGPointZero, inView:gestureRecognizer.view)
            }
        }
    }
    
}
