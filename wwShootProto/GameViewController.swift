//
//  GameViewController.swift
//  wwShootProto
//
//  Created by Jak Tiano on 9/21/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: nil)
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as HomeScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    enum GameOrientation {
        case Portrait, Landscape
    }
    
    var gameOrientation: GameOrientation = .Portrait
//    var gameOrientation: GameOrientation = .Landscape
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willTransitionToLandscape", name: "NHCSWillTransitionToHome", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willTransitionToPortrait",  name: "NHCSWillTransitionToWork", object: nil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willTransitionToLandscape", name: "NHCSWillTransitionToHome", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willTransitionToPortrait",  name: "NHCSWillTransitionToWork", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        if let scene = HomeScene.unarchiveFromFile("HomeScene") as? HomeScene {
        let screenSize = UIScreen.mainScreen().bounds.size
        let scene = LoadingScene(size: screenSize)
        
        // Configure the view.
        let skView = self.view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            if gameOrientation == .Portrait {
                return Int(UIInterfaceOrientationMask.Portrait.toRaw())
            }
            else if gameOrientation == .Landscape {
                return Int(UIInterfaceOrientationMask.Landscape.toRaw())
            }
            else {
                return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
            }
        } else {
            return Int(UIInterfaceOrientationMask.All.toRaw())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func willTransitionToLandscape() {
        gameOrientation = .Landscape
        forceOrientationChange()
    }
    
    func willTransitionToPortrait() {
        gameOrientation = .Portrait
        forceOrientationChange()
    }
    
    func forceOrientationChange() {
        presentViewController(UIViewController(), animated: false, completion: nil)
        dismissViewControllerAnimated(false, completion: nil)
    }
}
