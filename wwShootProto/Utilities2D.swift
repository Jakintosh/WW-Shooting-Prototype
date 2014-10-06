//
//  2DUtilities.swift
//  wwShootProto
//
//  Created by Jak Tiano on 10/5/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

import Foundation
import SpriteKit

struct Utilities2D {
    
    static func lerpFromPoint(p1: CGPoint, toPoint p2: CGPoint, atPosition val: CGFloat) -> CGPoint {
        return CGPointMake( p1.x + ((p2.x - p1.x) * val), p1.y + ((p2.y - p1.y) * val) );
    }
    
    static func addPoint( p1: CGPoint, toPoint p2: CGPoint) -> CGPoint {
        return CGPointMake(p1.x + p2.x, p1.y + p2.y);
    }
    
    static func subPoint( p1: CGPoint, fromPoint p2: CGPoint) -> CGPoint {
        return CGPointMake(p2.x - p1.x, p2.y - p1.y);
    }
    
    static func logPoint(point: CGPoint) {
        println("{\(point.x), \(point.y)}")
    }
}