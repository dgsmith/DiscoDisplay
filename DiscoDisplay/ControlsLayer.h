//
//  ControlsLayer.h
//  DiscoDisplay
//
//  Created by David Smith on 10/27/11.
//  Copyright (c) 2011 University of Sourther California. All rights reserved.
//

#import "cocos2d.h"
#import "SceneManager.h"
#import <CoreMotion/CoreMotion.h>

@class SneakyJoystick;
@class SneakyButton;

@interface ControlsLayer : CCLayer
{
    SneakyJoystick *mainJoystick;
    
    SneakyButton *ledPattern;
    SneakyButton *motionSelector;
    
    CCLabelTTF *check;

    unsigned char data[5];
    
    NSTimer *sendDataTimer;
    
    BOOL useMotion;

    CMMotionManager *motionManager;
}

-(void)help:(id)sender;

@end
