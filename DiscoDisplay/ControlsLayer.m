//
//  ControlsLayer.m
//  DiscoDisplay
//
//  Created by David Smith on 10/27/11.
//  Copyright (c) 2011 University of Sourther California. All rights reserved.
//

#import "ControlsLayer.h"

#import "SneakyButton.h"
#import "SneakyJoystick.h"
#import "SneakyButtonSkinnedBase.h"
#import "SneakyJoystickSkinnedBase.h"
#import "ColoredCircleSprite.h"
#import "ColoredSquareSprite.h"

#import "SendUDP.h"

#import "math.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

#define TILT_LIMIT 1.3962634

@implementation ControlsLayer

int count = 0;
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ControlsLayer *layer = [ControlsLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


- (id)init
{
    self = [super init];
    if (self) {        
        
        // now patiently wait for the notification
        
        // ask director the the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        NSString *ipAddress = @"192.168.1.102";
        SUDP_Init([ipAddress cStringUsingEncoding:NSASCIIStringEncoding]);
        
        motionManager = [[CMMotionManager alloc] init];
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
        [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
        
        sendDataTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(sendData) userInfo:nil repeats:YES];
        
        [CCMenuItemFont setFontSize:25];
        CCMenuItemFont *help = [CCMenuItemFont itemFromString:@"Help" target:self selector:@selector(help:)];
        CCMenu *menu = [CCMenu menuWithItems:help, nil];
        menu.position = ccp(size.width/2, 50);
        [self addChild:menu];
        
        CCLabelTTF *text = [CCLabelTTF 
                            labelWithString:@"Motion/Joystick Toggle" 
                            dimensions:CGSizeMake(size.width/2 + 200, 275) 
                            alignment:UITextAlignmentLeft
                            lineBreakMode:UILineBreakModeWordWrap
                            fontName:@"Helvetica" 
                            fontSize:20];
        text.position = ccp(size.width/2 + 250, 130);
        [self addChild:text];
        
        CCLabelTTF *text1 = [CCLabelTTF 
                            labelWithString:@"LED Pattern Selector" 
                            dimensions:CGSizeMake(size.width/2 + 200, 150) 
                            alignment:UITextAlignmentLeft
                            lineBreakMode:UILineBreakModeWordWrap
                            fontName:@"Helvetica" 
                            fontSize:20];
        text1.position = ccp(size.width/2 + 250, 93);
        [self addChild:text1];
        
        SneakyJoystickSkinnedBase *mainJoy = [[SneakyJoystickSkinnedBase alloc] init];
        mainJoy.position =          ccp(130,size.height/2);
        mainJoy.backgroundSprite =  [ColoredCircleSprite circleWithColor:ccc4(255, 0, 0, 128) radius:100];
        mainJoy.thumbSprite =       [ColoredCircleSprite circleWithColor:ccc4(0, 0, 255, 200) radius:40];
        mainJoy.joystick =          [[[SneakyJoystick alloc] initWithRect:CGRectMake(0,0,100,100)] autorelease];
        mainJoystick = [mainJoy.joystick retain];
        
        [self addChild:mainJoy];
        [mainJoy release];
        [mainJoystick release];
        
        SneakyButtonSkinnedBase *ledBut = [[[SneakyButtonSkinnedBase alloc] init] autorelease];
        ledBut.position =           ccp(380, 100);
        ledBut.defaultSprite =      [ColoredCircleSprite circleWithColor:ccc4(255, 0, 0, 128) radius:32];
        ledBut.pressSprite =        [ColoredCircleSprite circleWithColor:ccc4(0, 255, 0, 128) radius:32];
        ledBut.button =             [[[SneakyButton alloc] initWithRect:CGRectMake(0, 0, 64, 64)] autorelease];
        ledPattern = [ledBut.button retain];
        ledPattern.isToggleable = NO;
        ledPattern.isHoldable = YES;
        [self addChild:ledBut];
        
        SneakyButtonSkinnedBase *motionButton = [[[SneakyButtonSkinnedBase alloc] init] autorelease];
        motionButton.position =         ccp(380, 205);
        motionButton.defaultSprite =    [ColoredSquareSprite squareWithColor:ccc4(255, 0, 0, 128) size:CGSizeMake(50, 25)];
        motionButton.activatedSprite =  [ColoredSquareSprite squareWithColor:ccc4(0, 0, 255, 128) size:CGSizeMake(50, 25)];
        motionButton.pressSprite =      [ColoredSquareSprite squareWithColor:ccc4(0, 255, 0, 128) size:CGSizeMake(50, 25)];
        motionButton.button =           [[[SneakyButton alloc] initWithRect:CGRectMake(0, 0, 50, 25)] autorelease];
        motionSelector = [motionButton.button retain];
        motionSelector.isToggleable = YES;
        [self addChild:motionButton];        
        
        [self scheduleUpdate];
    }
    return self;
}

-(void) update: (ccTime) dt
{
    if (motionSelector.value) {
        useMotion = NO;
    } else {
        useMotion = YES;
    }
    
    int t,s;
    float ttemp, stemp;
    float pitch, roll;
    if (!useMotion) {
        ttemp = mainJoystick.stickPosition.y;
        t = roundf(((ttemp+50)*255)/100);
        stemp = mainJoystick.stickPosition.x;
        s = roundf(((stemp+50)*255)/100);
    } else {
        roll = motionManager.deviceMotion.attitude.roll;
        if (roll > TILT_LIMIT) {
            roll = TILT_LIMIT;
        }
        if (roll < -TILT_LIMIT) {
            roll = -TILT_LIMIT;
        }
        pitch = motionManager.deviceMotion.attitude.pitch;
        if (pitch > TILT_LIMIT) {
            pitch = TILT_LIMIT;
        }
        if (pitch < -TILT_LIMIT) {
            pitch = -TILT_LIMIT;
        }
        t = roundf(((pitch + TILT_LIMIT)*255)/(2*TILT_LIMIT));
        s = roundf(((roll + TILT_LIMIT)*255)/(2*TILT_LIMIT));
    }
    
    int ledOn;
    if (ledPattern.active) {
        ledOn = 1;
    } else {
        ledOn = 0;
    }
    
    data[0] = 'b';
    data[1] = (unsigned char) t;
    data[2] = (unsigned char) s;
    data[3] = (unsigned char) ledOn;
    data[4] = 'e';
    
}

-(void)sendData
{
    SUDP_SendMsg(data, 5);
}

- (NSString *)getIPAddress { 
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; 
                    
                } 
                
            } 
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address; 
    
} 

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)help:(id)sender
{
    [motionManager stopDeviceMotionUpdates];
    [sendDataTimer invalidate];
    SUDP_Close();
    [SceneManager goHelp];
}


@end
