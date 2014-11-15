//
//  NHCSky.m
//  wwShootProto
//
//  Created by Jak Tiano on 11/10/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

#import "NHCSky.h"

@implementation NHCSky

-(id)initWithColor:(UIColor *)color size:(CGSize)size {
    
    if (self = [super initWithColor:color size:size]) {
        
        self.topColors = @[ [[SKColor alloc] initWithRed:0.878 green:0.631 blue:0.392 alpha:1.0],
                            [[SKColor alloc] initWithRed:0.878 green:0.631 blue:0.392 alpha:1.0],
                            [[SKColor alloc] initWithRed:0.470 green:0.133 blue:0.082 alpha:1.0],
                            [[SKColor alloc] initWithRed:0.274 green:0.008 blue:0.254 alpha:1.0],
                            [[SKColor alloc] initWithRed:0.074 green:0.086 blue:0.188 alpha:1.0]];
        
        self.botColors = @[ [[SKColor alloc] initWithRed:0.541 green:0.890 blue:0.909 alpha:1.0],
                            [[SKColor alloc] initWithRed:0.541 green:0.890 blue:0.909 alpha:1.0],
                            [[SKColor alloc] initWithRed:0.705 green:0.458 blue:0.137 alpha:1.0],
                            [[SKColor alloc] initWithRed:0.541 green:0.254 blue:0.235 alpha:1.0],
                            [[SKColor alloc] initWithRed:0.247 green:0.086 blue:0.427 alpha:1.0]];
        self.times = @[ [NSNumber numberWithFloat:00.0],
                        [NSNumber numberWithFloat:15.5],
                        [NSNumber numberWithFloat:17.0],
                        [NSNumber numberWithFloat:18.0],
                        [NSNumber numberWithFloat:19.0] ];
        
        SKShader* skyShader = [SKShader shaderWithFileNamed:@"Sky.fsh"];
        skyShader.uniforms = @[
                               [SKUniform uniformWithName:@"height"   float: self.frame.size.height],
                               [SKUniform uniformWithName:@"topColor" floatVector3:GLKVector3Make(0.878, 0.631, 0.392)],
                               [SKUniform uniformWithName:@"botColor" floatVector3:GLKVector3Make(0.541, 0.890, 0.909)],
                               ];
        self.shader = skyShader;
    }
    
    return self;
}

-(void)updateShader:(CGFloat)currentHour {
    
    GLKVector3 newTop = [self getTopColor:currentHour];
    GLKVector3 newBot = [self getBotColor:currentHour];
    
    self.shader.uniforms = @[
                             [SKUniform uniformWithName:@"height"   float: self.frame.size.height],
                             [SKUniform uniformWithName:@"topColor" floatVector3:newTop],
                             [SKUniform uniformWithName:@"botColor" floatVector3:newBot],
                             ];
}

-(GLKVector3)getTopColor:(CGFloat)hour {
    
    int currentIndex = 0;
    
    for (int i = 0; i < self.times.count; i++) {
        CGFloat time = [self.times[i] floatValue];
        if (hour < time) {
            break;
        }
        currentIndex = i;
    }
    
    int nextIndex = currentIndex + 1;
    nextIndex = (nextIndex % self.times.count);
    
    CGFloat prevHour = [self.times[currentIndex] floatValue];
    CGFloat nextHour = [self.times[nextIndex]    floatValue];
    CGFloat diff = hour - prevHour;
    CGFloat range = nextHour - prevHour;
    CGFloat nor = diff/range;
    CGFloat inv = 1 - nor;
    
    SKColor* prev = self.topColors[currentIndex];
    SKColor* next = self.topColors[nextIndex];
    
    CGFloat r, g, b, pr, pg, pb, nr, ng, nb, a;
    
    [prev getRed:&pr green:&pg blue:&pb alpha:&a];
    [next getRed:&nr green:&ng blue:&nb alpha:&a];
    
    r = (pr*inv) + (nr*nor);
    g = (pg*inv) + (ng*nor);
    b = (pb*inv) + (nb*nor);
    
    return GLKVector3Make(r, g, b);
}

-(GLKVector3)getBotColor:(CGFloat)hour {
    
    int currentIndex = 0;
    
    for (int i = 0; i < self.times.count; i++) {
        CGFloat time = [self.times[i] floatValue];
        if (hour < time) {
            break;
        }
        currentIndex = i;
    }
    
    int nextIndex = currentIndex + 1;
    nextIndex = (nextIndex % self.times.count);
    
    CGFloat prevHour = [self.times[currentIndex] floatValue];
    CGFloat nextHour = [self.times[nextIndex]    floatValue];
    CGFloat diff = hour - prevHour;
    CGFloat range = nextHour - prevHour;
    CGFloat nor = diff/range;
    CGFloat inv = 1 - nor;
    
    SKColor* prev = self.botColors[currentIndex];
    SKColor* next = self.botColors[nextIndex];
    
    CGFloat r, g, b, pr, pg, pb, nr, ng, nb, a;
    
    [prev getRed:&pr green:&pg blue:&pb alpha:&a];
    [next getRed:&nr green:&ng blue:&nb alpha:&a];
    
    r = (pr*inv) + (nr*nor);
    g = (pg*inv) + (ng*nor);
    b = (pb*inv) + (nb*nor);
    
    return GLKVector3Make(r, g, b);
}

@end
