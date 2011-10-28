//
//  HelpLayer.m
//  DiscoDisplay
//
//  Created by David Smith on 10/27/11.
//  Copyright (c) 2011 University of Sourther California. All rights reserved.
//

#import "HelpLayer.h"

@implementation HelpLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelpLayer *layer = [HelpLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self addChild:[CCLayerColor layerWithColor:ccc4(20, 84, 142, 255)]];
        // ask director the the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        [CCMenuItemFont setFontSize:30];
        
        CCMenuItemFont *back = [CCMenuItemFont itemFromString:@"back" target:self selector:@selector(back:)];
        CCMenu *menu = [CCMenu menuWithItems:back, nil];
        menu.position = ccp(size.width/2, 50);
        [self addChild:menu];
        
        CCLabelTTF *text = [CCLabelTTF 
                            labelWithString:@"1.) Make sure you are connected to the robot's wifi network before starting control. \n2.) Try simply restarting this app by killing it in the 'recent apps' list and opening it again once you are connected. \n3.) If you are still having trouble, recheck your connection to the wifi; make sure you have manually set your IP. \n4.) Make sure the robot is on and within range." 
                            dimensions:CGSizeMake(size.width/2 + 200, 275) 
                            alignment:UITextAlignmentLeft
                            lineBreakMode:UILineBreakModeWordWrap
                            fontName:@"Helvetica" 
                            fontSize:17];
        text.position = ccp(size.width/2, 160);
        [self addChild:text];
    }
    
    return self;
}

-(void)back:(id)sender
{
    [SceneManager goControls];
}

-(void)dealloc
{
    [super dealloc];
}



@end
