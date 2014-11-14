//
//  NHCSky.h
//  wwShootProto
//
//  Created by Jak Tiano on 11/10/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface NHCSky : SKSpriteNode

@property(nonatomic,strong) NSArray* topColors;
@property(nonatomic,strong) NSArray* botColors;
@property(nonatomic,strong) NSArray* times;

@property(nonatomic) NSTimeInterval currentTime;

-(void)updateShader:(CGFloat)currentHour;

@end
