//
//  MenuLayer.m
//  DiscoDisplay
//
//  Created by David Smith on 10/27/11.
//  Copyright (c) 2011 University of Sourther California. All rights reserved.
//

#import "MenuLayer.h"

@implementation MenuLayer

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    [CCMenuItemFont setFontSize:34];
    [self addChild:[CCLayerColor layerWithColor:ccc4(20, 84, 142, 255)]];
    
    CCLabelTTF *title = [CCLabelTTF labelWithString:@"Welcome" fontName:@"Helvetica" fontSize:48];
    
    CCMenuItemFont *control = [CCMenuItemFont itemFromString:@"Begin Robot Control" target:self selector:@selector(onControlsSelect::)];

    CCMenu *menu = [CCMenu menuWithItems:control, nil];
    
    title.position = ccp(240, 270);
    [self addChild: title];
    
    menu.position = ccp(240, 110);
    [menu alignItemsVerticallyWithPadding:7.0f];
    [self addChild:menu z:2];
    
    return self;
}


@end
