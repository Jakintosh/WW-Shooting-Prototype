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
    
    // MARK: - Numbers
    static func clamp(number: Double, min: Double, max: Double) -> Double {
        var num = number
        if num > max { num = max }
        else if num < min { num = min }
        return num
    }
    static func clamp(number: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        var num = number
        if num > max { num = max }
        else if num < min { num = min }
        return num
    }
    static func clamp(number: Int, min: Int, max: Int) -> Int {
        var num = number
        if num > max { num = max }
        else if num < min { num = min }
        return num
    }
    static func lerpFrom(n1: CGFloat, toNum n2: CGFloat, atPosition val: CGFloat) -> CGFloat {
        return ( n1 + ( ( n2 - n1 ) * val) )
    }
    
    // MARK: - Points
    static func lerpFromPoint(p1: CGPoint, toPoint p2: CGPoint, atPosition val: CGFloat) -> CGPoint {
        return CGPointMake( p1.x + ((p2.x - p1.x) * val), p1.y + ((p2.y - p1.y) * val) );
    }
    static func addPoint( p1: CGPoint, toPoint p2: CGPoint) -> CGPoint {
        return CGPointMake(p1.x + p2.x, p1.y + p2.y);
    }
    static func subPoint( p1: CGPoint, fromPoint p2: CGPoint) -> CGPoint {
        return CGPointMake(p2.x - p1.x, p2.y - p1.y);
    }
    static func multiplyPoint( p1: CGPoint, byPoint p2: CGPoint) -> CGPoint {
        return CGPointMake(p1.x * p2.x, p1.y * p2.y);
    }
    static func dividePoint( p1: CGPoint, byPoint p2: CGPoint) -> CGPoint {
        return CGPointMake(p1.x / p2.x, p1.y / p2.y);
    }
    static func multiplyPoint( p: CGPoint, byNumber n: CGFloat) -> CGPoint {
        return CGPointMake(p.x * n, p.y * n);
    }
    static func dividePoint( p: CGPoint, byNumber n: CGFloat) -> CGPoint {
        return CGPointMake(p.x / n, p.y / n);
    }
    static func distanceSquaredFromPoint(p1: CGPoint, toPoint p2: CGPoint) -> CGFloat {
        return ((p2.x - p1.x) * (p2.x - p1.x)) + ((p2.y - p1.y) * (p2.y - p1.y))
    }
    static func distanceFromPoint(p1: CGPoint, toPoint p2: CGPoint) -> CGFloat {
        return sqrt(distanceSquaredFromPoint(p1, toPoint: p2))
    }
    static func logPoint(point: CGPoint) {
        println("{\(point.x), \(point.y)}")
    }
}