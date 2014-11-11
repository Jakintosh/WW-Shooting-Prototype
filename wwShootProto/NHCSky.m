//
//  NHCSky.m
//  wwShootProto
//
//  Created by Jak Tiano on 11/10/14.
//  Copyright (c) 2014 not a hipster coffee shop. All rights reserved.
//

#import "NHCSky.h"

@implementation NHCSky

-(id) initWithColor:(UIColor *)color size:(CGSize)size {
    
    if (self = [super initWithColor:color size:size]) {
        
        SKShader* skyShader = [SKShader shaderWithFileNamed:@"Sky.fsh"];
        skyShader.uniforms = @[
                               [SKUniform uniformWithName:@"size" floatVector3:GLKVector3Make(self.frame.size.width, self.frame.size.height, 0)],
                               [SKUniform uniformWithName:@"topColor" floatVector3:GLKVector3Make(0.878, 0.631, 0.392)],
                               [SKUniform uniformWithName:@"botColor" floatVector3:GLKVector3Make(0.541, 0.890, 0.909)],
                               ];
        self.shader = skyShader;
    }
    
    return self;
}

@end
