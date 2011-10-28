//
//  SceneManager.m
//  DiscoDisplay
//
//  Created by David Smith on 10/27/11.
//  Copyright (c) 2011 University of Sourther California. All rights reserved.
//

#import "SceneManager.h"

@interface SceneManager()
+(void)go:(CCLayer *)layer;
+(CCScene *)wrap:(CCLayer *)layer;
@end


@implementation SceneManager

+(void)goMenu
{
    CCLayer *layer = [MenuLayer node];
    [SceneManager go:layer];
}

+(void)goControls
{
    CCLayer *layer = [ControlsLayer node];
    [SceneManager go:layer];
}

+(void)goHelp
{
    CCLayer *layer = [HelpLayer node];
    [SceneManager go:layer];
}

+(void)go:(CCLayer *)layer
{
    CCDirector *director = [CCDirector sharedDirector];
    CCScene *newScene = [SceneManager wrap:layer];
    if ([director runningScene]) {
        [director replaceScene:newScene];
    }
    else
    {
        [director runWithScene:newScene];
    }
}

+(CCScene *)wrap:(CCLayer *)layer
{
    CCScene *newScene = [CCScene node];
    [newScene addChild:layer];
    return newScene;
}

@end
