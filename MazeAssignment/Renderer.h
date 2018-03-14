//
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#ifndef Renderer_h
#define Renderer_h
#import <GLKit/GLKit.h>
#import "MazeGen.h"
@interface Renderer : NSObject

@property float rotAngle;
@property bool isRotating;


- (void)setup:(GLKView *)view;
- (void)loadModels;
- (void)update;
- (void)draw:(CGRect)drawRect;
- (void)DayNightToggle;
- (void)FlashlightToggle;
- (void)FogToggle;
@end

#endif /* Renderer_h */
