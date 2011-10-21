//
//  AppDelegate.h
//  DiscoDisplay
//
//  Created by David Smith on 10/21/11.
//  Copyright University of Sourther California 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
