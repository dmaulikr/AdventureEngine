//
//  AppDelegate.h
//  Adventure Engine
//
//  Created by Galen Koehne on 12/15/12.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "DebugFlags.h"

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;

	CCDirectorIOS	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end
