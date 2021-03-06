//
//  Engine.h
//  AdventureEngine
//
//  Created by Galen Koehne on 11/10/12.
//

#import "cocos2d.h"
#import "AppDelegate.h"

// Import.....EVERYTHING!
//#import "Cutscene.h"
#import "GameData.h"
#import "Logic.h"
#import "DebugFlags.h"
#import "HUD.h"
#import "World.h"
#import "Dialogue.h"
#import "WorldObject.h"
#import "Tappable.h"
#import "Triggerable.h"
#import "GameAction.h"
#import "WorldHistory.h"
#import "Readable.h"

@interface Engine : CCLayer
{
    id hud;
    id world;
    int actionDelay;
    NSMutableArray * actionsToRun;
    
    //bool firstTimeRunningWorld;
}

// returns a CCScene that contains the all the Core Engine Layers as the only child
+(CCScene *) continueGameScene;
+(CCScene *) newGameScene;
-(void) handleTileTapAt:(CGPoint) tilePt;
-(void) handleTriggerAt:(CGPoint) tilePt;
-(void) run:(GameAction *) ga;
-(void) setHUDVisibility:(bool) v;
-(void) newGame;
-(void) endGame;
-(void) dealloc;
//-(void) loadMap:(NSString *) map;

@end
