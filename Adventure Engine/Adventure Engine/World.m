//
//  TestLayerBottom.m
//  AdventureEngine
//
//  Created by Galen Koehne on 12/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "World.h"
#import "Engine.h"

#define Z_PLAYER 5
#define Z_BELOW_PLAYER 1
#define Z_IN_FRONT_OF_PLAYER 10

@implementation World

-(id) init {
    self=[super init];
    if(!self) return nil;
    
    self.isTouchEnabled = true;
    
    [self schedule:@selector(tick:)];
    
    gd = [GameData instance];
    
    cameraFocusedOnTile = 6;
    
    for (int i = 0; i < WORLDTILES_X; i++) {
        for (int j = 0; j < WORLDTILES_Y; j++) {
            WorldTile * wt = [[WorldTile alloc] init];
            worldTiles[i][j] = wt;
        }
    }
    
    spawnPositions = [[NSMutableArray alloc] init];
    player = [[Player alloc] init];
    [self addChild:player z:Z_PLAYER];
    
    [gd._worldHistory setStatus:false forID:@"has_bath_key"];
    
    return self;
}

// Called when loading a world or when scene is switched
-(void) clearWorld {
    //Log(@"clearing world");
    for (int i = 0; i < WORLDTILES_X; i++) {
        for (int j = 0; j < WORLDTILES_Y; j++) {
            [(WorldTile *)worldTiles[i][j] removeAllSprites];
            [(WorldTile *)worldTiles[i][j] setVisible:true];
        }
    }
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    [backgroundBatchNode removeFromParentAndCleanup:true];
    [worldObjectsBatchNode removeFromParentAndCleanup:true];
    
    [spawnPositions removeAllObjects];
    [[GameData instance]._worldObjects removeAllObjects];
    [[GameData instance]._worldTappables removeAllObjects];
    [[GameData instance]._worldTriggerables removeAllObjects];
    [[GameData instance]._barriers removeAllObjects];
    //[[GameData instance]._worldHistory clear];
    
}

// Defaults to the first spawn available
-(void) loadWorld:(NSString *) worldToLoad {
    [self loadWorld:worldToLoad withSpawn:1];
}

// Spawn Points increment from 1 and up
-(void) loadWorld:(NSString *) worldToLoad withSpawn:(int) spawnPt {
    [self clearWorld];
    [self loadTiles: worldToLoad withSpawn: spawnPt];
    
    [self loadWorldObjects: worldToLoad];
    // load barriers
    // load tappables/triggerables
    
    if ([worldToLoad isEqualToString:@"bath"]) {
        // Load barrier from map files
        Barrier * bathDoorBarrier = [Barrier barrierWithPosition:110.0f withWidth:20.0f withID:@"shower_door_barrier"];
        // Load barrier's status from persistent data
        bool bathDoorBarrierStatus = true;
        [bathDoorBarrier setEnabled:bathDoorBarrierStatus];
        if (Display_Barriers) [self addChild:[bathDoorBarrier getVisual] z:Z_BELOW_PLAYER];
        
        //barrier:(110,20):shower_door_barrier
        //type:(x,y):barrier_id
        
        //tappable:(x,y):4
        //
        
        
        GameAction * doorUnlocked = [ActionDialogue actionWithDialogue:@"door now unlocked!"];
        GameAction * unlockShowerDoor = [ActionBarrier actionWithID:@"shower_door_barrier" active:false];
        GameAction * unlockShowerDoorAnimation = [ActionObjectAnimation actionWithID:@"shower_door" running:2];
        GameAction * lockTap1 = [ActionTap actionWithID:4 active:false];
        GameAction * unlockOtherTap1 = [ActionTap actionWithID:5 active:true];
        Tappable * unlockShowerDoorTap = [Tappable tappableWithPosition:ccp(8,4) withActions:[NSArray arrayWithObjects:doorUnlocked, unlockShowerDoor,unlockShowerDoorAnimation,lockTap1,unlockOtherTap1, nil] withIdentity:4];
        [unlockShowerDoorTap addPrereq:@"has_bath_key"];
        [unlockShowerDoorTap addGameActionsIfPrereqsNotMet:[NSArray arrayWithObject:[ActionDialogue actionWithDialogue:@"I need a key for that"]]];

        [self addChild:[unlockShowerDoorTap getGlow] z:Z_BELOW_PLAYER];
        
        GameAction * doorLocked = [ActionDialogue actionWithDialogue:@"door now locked!"];
        GameAction * lockShowerDoor = [ActionBarrier actionWithID:@"shower_door_barrier" active:true];
        GameAction * lockShowerDoorAnimation = [ActionObjectAnimation actionWithID:@"shower_door" running:3];
        GameAction * lockTap2 = [ActionTap actionWithID:5 active:false];
        GameAction * unlockOtherTap2 = [ActionTap actionWithID:4 active:true];
        Tappable * lockShowerDoorTap = [Tappable tappableWithPosition:ccp(8,4) withActions:[NSArray arrayWithObjects:doorLocked, lockShowerDoor,lockShowerDoorAnimation,lockTap2,unlockOtherTap2, nil]  withSize:CGSizeMake(1,1) withIdentity:5 isEnabled:false];
        [self addChild:[lockShowerDoorTap getGlow] z:Z_BELOW_PLAYER];
        
        
        GameAction * doorToCat = [ActionLoadWorld actionWithWorldToLoad:@"catherine_bed" atSpawnPoint:1];
        Tappable * doorToCatTap = [Tappable tappableWithPosition:ccp(11,2) withActions:[NSArray arrayWithObjects: doorToCat, nil] withSize:CGSizeMake(2,4) withIdentity:1 isEnabled:true];
        [self addChild:[doorToCatTap getGlow] z:Z_BELOW_PLAYER];
        
        
        GameAction * makeDissappear = [ActionObjectVisibility actionWithID:@"disappearer" active:false];
        GameAction * disableSelf = [ActionTap actionWithID:2 active:false];
        Tappable * coatTap = [Tappable tappableWithPosition:ccp(1,2) withActions:[NSArray arrayWithObjects: makeDissappear, disableSelf, nil] withSize:CGSizeMake(2,1) withIdentity:2 isEnabled:true];
        [self addChild:[coatTap getGlow] z:Z_BELOW_PLAYER];
        
        
        Tappable * firstComp = [Tappable tappableWithPosition:ccp(14,2) withActions:[NSArray arrayWithObjects:[ActionDialogue actionWithDialogue:@"The terminal seems to still have power"], [ActionReadable actionWithReadable:@"first_reading"],nil] withSize:CGSizeMake(1, 3) withIdentity:23 isEnabled:true];
        [self addChild:[firstComp getGlow] z:Z_BELOW_PLAYER];
        
        
        
    } else if([worldToLoad isEqualToString:@"catherine_bed"]) {
        /*Barrier * bathDoorBarrier = [Barrier barrierWithPosition:200.0f withWidth:60.0f withID:@"catherine_bed_door"];
        // Load barrier's status from persistent data
        bool bathDoorBarrierStatus = true;
        [bathDoorBarrier setEnabled:bathDoorBarrierStatus];
        if (Display_Barriers) [self addChild:[bathDoorBarrier getVisual] z:Z_BELOW_PLAYER];
        */
        
        
        GameAction * doorToBath = [ActionLoadWorld actionWithWorldToLoad:@"bath" atSpawnPoint:2];
        NSArray * doorToBathArray = [NSArray arrayWithObjects: doorToBath, nil];
        Triggerable * doorToBathTrig = [Triggerable triggerableWithPosition:ccp(2,2) withActions:doorToBathArray withIdentity:3 isEnabled:true];
        [self addChild:[doorToBathTrig  getGlow] z:Z_BELOW_PLAYER];
        
        
        Tappable * mirrorTap = [Tappable tappableWithPosition:ccp(8,4) withActions: [NSArray arrayWithObjects:
                                                                                     [ActionDialogue actionWithDialogue:@"Got Key"],
                                                                                     [ActionHistory actionWithID:@"has_bath_key" newStatus:true], nil]
                                                 withIdentity:1];
        [self addChild:[mirrorTap getGlow] z:Z_BELOW_PLAYER];
        
        
        Triggerable * doorToTestBed = [Triggerable triggerableWithPosition:ccp(18,2) withActions: [NSArray arrayWithObjects:
                                                                                                              [ActionLoadWorld actionWithWorldToLoad:@"test_bed" atSpawnPoint:1], nil] withIdentity:5 isEnabled:true];
        [self addChild:[doorToTestBed getGlow] z:Z_BELOW_PLAYER];
        
    } else if ([worldToLoad isEqualToString:@"test_bed"]) {
        Triggerable * doorToCatBed = [Triggerable triggerableWithPosition:ccp(1,2) withActions: [NSArray arrayWithObjects:
                                                                                                   [ActionLoadWorld actionWithWorldToLoad:@"catherine_bed" atSpawnPoint:2], nil] withIdentity:0 isEnabled:true];
        [self addChild:[doorToCatBed getGlow] z:Z_BELOW_PLAYER];
        
        
        NSArray * getFirstSwitch = [NSArray arrayWithObjects:[ActionDialogue actionWithDialogue:@"First switch now enabled"],
                                    [ActionHistory actionWithID:@"switch1_enabled" newStatus:true], nil];
        
        Tappable * getFirstSwitchTap = [Tappable tappableWithPosition:ccp(2,3) withActions:getFirstSwitch withIdentity:1];
        [self addChild:[getFirstSwitchTap getGlow] z:Z_BELOW_PLAYER];
        
        
        NSArray * resetSwitches = [NSArray arrayWithObjects:[ActionDialogue actionWithDialogue:@"Switches reset!"],
                                   [ActionHistory actionWithID:@"switch1_enabled" newStatus:false],
                                   [ActionHistory actionWithID:@"switch2_enabled" newStatus:false],
                                   [ActionHistory actionWithID:@"switch3_enabled" newStatus:false], nil];        
        // switch 1 no reqs
        NSArray * switch1GAs = [NSArray arrayWithObjects:
                                [ActionDialogue actionWithDialogue:@"Switch 2 enabled!"],
                                [ActionHistory actionWithID:@"switch1_enabled" newStatus:false],
                                [ActionHistory actionWithID:@"switch2_enabled" newStatus:true],
                                [ActionHistory actionWithID:@"switch3_enabled" newStatus:false], nil];
        
        Tappable * switch1 = [Tappable tappableWithPosition:ccp(4,3) withActions:switch1GAs withSize:CGSizeMake(1,1) withIdentity:1 isEnabled:true];
        [switch1 addGameActionsIfPrereqsNotMet:resetSwitches];
        [switch1 addPrereq:@"switch1_enabled"];
        
        // switch 2 needs 1 hit
        NSArray * switch2GAs = [NSArray arrayWithObjects:
                                [ActionDialogue actionWithDialogue:@"Switch 3 enabled!"],
                                [ActionHistory actionWithID:@"switch1_enabled" newStatus:false],
                                [ActionHistory actionWithID:@"switch2_enabled" newStatus:false],
                                [ActionHistory actionWithID:@"switch3_enabled" newStatus:true], nil];
        
        Tappable * switch2 = [Tappable tappableWithPosition:ccp(6,3) withActions:switch2GAs withSize:CGSizeMake(1,1) withIdentity:1 isEnabled:true];
        [switch2 addGameActionsIfPrereqsNotMet:resetSwitches];
        [switch2 addPrereq:@"switch2_enabled"];
        
        // switch 3 needs 2 hit
        NSArray * switch3GAs = [NSArray arrayWithObjects:
                                [ActionDialogue actionWithDialogue:@"You got the right order!"],
                                [ActionTap actionWithID:1 active:false], nil];
        
        Tappable * switch3 = [Tappable tappableWithPosition:ccp(8,3) withActions:switch3GAs withSize:CGSizeMake(1,1) withIdentity:1 isEnabled:true];
        [switch3 addGameActionsIfPrereqsNotMet:resetSwitches];
        [switch3 addPrereq:@"switch3_enabled"];
        
        [self addChild:[switch1 getGlow] z:Z_BELOW_PLAYER];
        [self addChild:[switch2 getGlow] z:Z_BELOW_PLAYER];
        [self addChild:[switch3 getGlow] z:Z_BELOW_PLAYER];
    }
}

// Sets up both animated and static tiles (not worlds objects)
-(void) loadTiles:(NSString *) worldToLoad withSpawn:(int) spawnPt {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:
     [NSString stringWithFormat:@"%@.plist",worldToLoad]];
    
    backgroundBatchNode = [CCSpriteBatchNode 
                           batchNodeWithFile:
                           [NSString stringWithFormat:@"%@.png",worldToLoad]];
    
    [self addChild:backgroundBatchNode z:Z_BELOW_PLAYER];
    
    NSError * error;
    
    NSString * contents = [NSString stringWithContentsOfFile:
                           [[NSBundle mainBundle] pathForResource:worldToLoad ofType:@"txt"]
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];
    
    NSArray * contentsArray = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    int spawnPtID = 0;
    
    for (NSString * s in contentsArray) {
        if ([s hasPrefix:@"spawn"]) {
            NSArray * spawnInfo = [s componentsSeparatedByString:@","];
            int spawnX = [[spawnInfo objectAtIndex:1] intValue];
            int spawnY = [[spawnInfo objectAtIndex:2] intValue];
            Direction d;
            if ([[spawnInfo objectAtIndex:3] isEqualToString:@"R"]) d = RIGHT;
            else d = LEFT;
            
            spawnPtID++;
            
            SpawnPosition * currentSpawn = [[[SpawnPosition alloc] initWithPos:CGPointMake(spawnX, spawnY) withDir:d withID:spawnPtID] autorelease];
            [spawnPositions addObject:currentSpawn];
            
            if (spawnPtID==spawnPt) {
                [player setPositionManually:CGPointMake(spawnX, spawnY)];
                [player setFacing:d];
                
                cameraCenter = CGPointMake(240 - player.position.x, player.position.y);
                
            }
        } else if ([s hasPrefix:@"info"]) {
            NSArray * inputBarriers = [s componentsSeparatedByString:@","];
            
            NSString * leftBarrierString = [inputBarriers objectAtIndex:1];
            Barrier * leftWorldBoundary = [Barrier barrierWithPosition:[leftBarrierString floatValue] withID:@"left_boundary"];
            [leftWorldBoundary setEnabled:true];
            if (Display_Barriers) [self addChild:[leftWorldBoundary getVisual] z:Z_BELOW_PLAYER];
            
            
            NSString * rightBarrierString = [inputBarriers objectAtIndex:2];
            Barrier * rightWorldBoundary = [Barrier barrierWithPosition:[rightBarrierString floatValue] withID:@"left_boundary"];
            [rightWorldBoundary setEnabled:true];
            if (Display_Barriers) [self addChild:[rightWorldBoundary getVisual] z:Z_BELOW_PLAYER];
            
        } else if ([s hasPrefix:@"//"]) {
            // Disregard notes!
        } else {
            bool isAnimated = false;
            NSArray * tileArray = [s componentsSeparatedByString:@","];
            
            NSString * tileName; // Used only if static
            NSMutableArray * animatedTileNames; // Used only if animated
            float animationDelay; // Used only if animated
            
            if ([[tileArray objectAtIndex:0] rangeOfString:@"-"].location == NSNotFound) {
                tileName = [NSString stringWithFormat:@"%@_%@.png",worldToLoad,[tileArray objectAtIndex:0]];
            } else {
                NSMutableArray * animatedTileNumbers = [NSMutableArray arrayWithArray:[[tileArray objectAtIndex:0] componentsSeparatedByString:@"-"]];
                animatedTileNames = [NSMutableArray array];
                animationDelay = [[animatedTileNumbers objectAtIndex:0] floatValue];
                [animatedTileNumbers removeObjectAtIndex:0];
                
                for (NSString * animatedTileNumber in animatedTileNumbers) {
                    [animatedTileNames addObject:[NSString stringWithFormat:@"%@_%@.png",worldToLoad,animatedTileNumber]];
                }
                
                isAnimated = true;
            }
            
            
            NSString * xRange = [tileArray objectAtIndex:1];
            NSString * yRange = [tileArray objectAtIndex:2];
            
            int tileMinX,tileMaxX;
            int tileMinY,tileMaxY;
            
            if ([xRange rangeOfString:@"-"].location == NSNotFound) {
                // only 1 value
                tileMinX = tileMaxX = [xRange intValue];
            } else {
                // multiple values
                NSArray * xArray = [xRange componentsSeparatedByString:@"-"];
                tileMinX = [[xArray objectAtIndex:0] intValue];
                tileMaxX = [[xArray objectAtIndex:1] intValue];
            }
            
            if ([yRange rangeOfString:@"-"].location == NSNotFound) {
                // only 1 value
                tileMinY = tileMaxY = [yRange intValue];
            } else {
                // multiple values
                NSArray * yArray = [yRange componentsSeparatedByString:@"-"];
                tileMinY = [[yArray objectAtIndex:0] intValue];
                tileMaxY = [[yArray objectAtIndex:1] intValue];
            }
            
            
            for (int tx = tileMinX; tx <= tileMaxX; tx++) {
                for (int ty = tileMinY; ty <= tileMaxY; ty++) {
                    if (!isAnimated) {
                        [self addSprite:tileName atTileCoords:CGPointMake(tx,ty) inFrontOfPlayer:false];
                    } else {
                        [self addAnimatedSprite:animatedTileNames atTileCoords:CGPointMake(tx, ty) inFrontOfPlayer:false delay:animationDelay];
                    }
                    
                }
            }
            
        }
    }
    
    if (spawnPtID==0) Log(@"Spawn point not provided in map load");
    
}

-(void) loadWorldObjects:(NSString *) worldToLoad {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:
     [NSString stringWithFormat:@"%@_objects.plist",worldToLoad]];
    
    worldObjectsBatchNode = [CCSpriteBatchNode 
                             batchNodeWithFile:
                             [NSString stringWithFormat:@"%@_objects.png",worldToLoad]];
    
    [self addChild:worldObjectsBatchNode z:Z_BELOW_PLAYER];
    
    NSError * error;
    
    NSString * objectsTextFile = [NSString stringWithFormat:@"%@_objects",worldToLoad];
    
    NSString * contents = [NSString stringWithContentsOfFile:
                           [[NSBundle mainBundle] pathForResource:objectsTextFile ofType:@"txt"]
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];
    
    NSArray * contentsArray = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString * s in contentsArray) {
        if ([s hasPrefix:@"object"]) {
            NSArray * objectComponents = [s componentsSeparatedByString:@","];
            
            NSString * objectName = [objectComponents objectAtIndex:1];
            int objectX = [[objectComponents objectAtIndex:2] intValue];
            int objectY = [[objectComponents objectAtIndex:3] intValue];
            
            WorldObject * object = [WorldObject objectWithPos:ccp(objectX,objectY) withID:objectName];
            
            for (int i = 4; i < [objectComponents count]; i++) {
                NSArray * framesInAnimation = [[objectComponents objectAtIndex:i] componentsSeparatedByString:@"-"];
                
                NSMutableArray * animFrames = [[NSMutableArray alloc] init];
                
                for (NSString * animatedFrame in framesInAnimation) {
                    NSString * currentFrameName = [NSString stringWithFormat:@"%@_objects_%@.png",worldToLoad,animatedFrame];
                    CCSpriteFrame * frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:currentFrameName];
                    [animFrames addObject:frame];
                }
                
                CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:DEFAULTANIMATIONDELAY];
                animation.restoreOriginalFrame = false;
                [object addAnimation:animation];
                
            }
            
            [worldObjectsBatchNode addChild:object z:Z_BELOW_PLAYER];
            
        }
    }    
}

-(void) addAnimatedSprite:(NSArray *) animatedSpriteFrames atTileCoords:(CGPoint) pt inFrontOfPlayer:(bool) ifop {
    [self addAnimatedSprite:animatedSpriteFrames atTileCoords:pt inFrontOfPlayer:ifop delay:DEFAULTANIMATIONDELAY];
}

-(void) addAnimatedSprite:(NSArray *) spriteFrames atTileCoords:(CGPoint) pt inFrontOfPlayer:(bool) ifop delay:(float) d {
    CCSprite * sprite = [CCSprite spriteWithSpriteFrameName:[spriteFrames objectAtIndex:0]];
    [sprite setScale:2];
    [sprite setPosition:CGPointMake((pt.x-1) * 20 * 2 + 20, (pt.y-1) * 20 * 2 + 20)];
    if (ifop) [sprite setZOrder:Z_IN_FRONT_OF_PLAYER];
    else [sprite setZOrder:Z_BELOW_PLAYER];
    [[sprite texture] setAliasTexParameters];
    
    NSMutableArray * animFrames = [[NSMutableArray alloc] init];
    
    for (NSString * animatedFrame in spriteFrames) {
        CCSpriteFrame * frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:animatedFrame];
        [animFrames addObject:frame];
    }
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:d];
    [sprite runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation] ]];
    
    //animation.restoreOriginalFrame = true;
    //[sprite runAction:[CCAnimate actionWithAnimation:animation]];
    
    
    [backgroundBatchNode addChild:sprite];
    
    int wtX = pt.x - 1;
    int wtY = pt.y - 1;
    
    [((WorldTile *)worldTiles[wtX][wtY]) addSprite:sprite];
    
    if (sprite.position.x>[player getPosition].x + 260) 
        [((WorldTile *)worldTiles[wtX][wtY]) setVisible:false];
    else if (sprite.position.x<[player getPosition].x - 260) 
        [((WorldTile *)worldTiles[wtX][wtY]) setVisible:false];
}

-(void) addSprite:(NSString *) s atTileCoords:(CGPoint) pt inFrontOfPlayer:(bool) ifop {
    CCSprite * sprite = [CCSprite spriteWithSpriteFrameName:s];
    [sprite setScale:2];
    [sprite setPosition:CGPointMake((pt.x-1) * 20 * 2 + 20, (pt.y-1) * 20 * 2 + 20)];
    if (ifop) [sprite setZOrder:Z_IN_FRONT_OF_PLAYER];
    else [sprite setZOrder:Z_BELOW_PLAYER];
    [[sprite texture] setAliasTexParameters];
    
    [backgroundBatchNode addChild:sprite];
    
    int wtX = pt.x - 1;
    int wtY = pt.y - 1;
    
    [((WorldTile *)worldTiles[wtX][wtY]) addSprite:sprite];
    
    if (sprite.position.x>[player getPosition].x + 260) 
        [((WorldTile *)worldTiles[wtX][wtY]) setVisible:false];
    else if (sprite.position.x<[player getPosition].x - 260) 
        [((WorldTile *)worldTiles[wtX][wtY]) setVisible:false];
    
}

-(void) tick:(ccTime) dt {
    bool playerChangedPos;
    if (gd._playerHoldingLeft) {
        playerChangedPos = [player attemptMoveInDirection:LEFT];
    } else if (gd._playerHoldingRight) {
        playerChangedPos = [player attemptMoveInDirection:RIGHT];
    } else {
        playerChangedPos = [player attemptNoMove];
    }
    
    if(playerChangedPos) {
        for (Tappable * t in [GameData instance]._worldTappables) {
            [t updateGlow];
        }
    }
    
    [self updateCamera];
}

-(void) updateCamera {
    CGPoint centerOfView = ccp(480.0/2,320.0/2);
    CGPoint viewPoint = ccpSub(centerOfView, self.position);
    
    cameraCenter.x = 240 - [player getPosition].x;
    
    if (shakeDuration) {
        shakeDuration--;
        
        //self.scaleY = shakeDuration;
        //self.skewX = shakeDuration;
        //self.rotation = shakeDuration;
        
        CGPoint shakeVariance = CGPointMake(arc4random() % shakeIntensity * (shakeDuration/shakeTotalDuration),
                                            arc4random() % shakeIntensity * (shakeDuration/shakeTotalDuration));
        
        //Log(@"Shake = (%f,%f)",shakeVariance.x,shakeVariance.y);
        
        [GameData instance]._cameraPosition = self.position
        = ccpAdd(cameraCenter, shakeVariance);
        
        if (shakeDuration==0) {
            [GameData instance]._actionRunning = false;
        }
    } else {
        [GameData instance]._cameraPosition = self.position = cameraCenter;
    }
    // Determine what tile the camera is at
    // If that is different than old camera tile pos, make one col visible and one not
    if (cameraFocusedOnTile != ((int)(viewPoint.x/40))) {
        //Log(@"Updating tile visibility:%d vs %d", cameraFocusedOnTile, (int)(viewPoint.x/40));
        [self updateTileVisibility];
    }
}

-(void) updateTileVisibility {
    int tilesToRenderFromCam = 7;
    
    CGPoint centerOfView = ccp(480.0/2,320.0/2);
    CGPoint viewPoint = ccpSub(centerOfView, self.position);
    int newCameraTilePos = viewPoint.x/40;
    if (newCameraTilePos>cameraFocusedOnTile) {
        // add to right, remove from left
        for (int i = 0; i < WORLDTILES_Y; i++) {
            if (cameraFocusedOnTile+tilesToRenderFromCam >= 0 && cameraFocusedOnTile+tilesToRenderFromCam < WORLDTILES_X)
                //((CCSprite *)worldTiles[cameraFocusedOnTile+7][i]).visible = true;
                [((WorldTile *)worldTiles[cameraFocusedOnTile+tilesToRenderFromCam][i]) setVisible:true];
            
            if (cameraFocusedOnTile-tilesToRenderFromCam >= 0 && cameraFocusedOnTile-tilesToRenderFromCam < WORLDTILES_X)
                [((WorldTile *)worldTiles[cameraFocusedOnTile-tilesToRenderFromCam][i]) setVisible:false];
        }
    } else {
        // add to left, remove from right
        for (int i = 0; i < WORLDTILES_Y; i++) {
            if (cameraFocusedOnTile+tilesToRenderFromCam >= 0 && cameraFocusedOnTile+tilesToRenderFromCam < WORLDTILES_X)
                [((WorldTile *)worldTiles[cameraFocusedOnTile+tilesToRenderFromCam][i]) setVisible:false];
            
            if (cameraFocusedOnTile-tilesToRenderFromCam >= 0 && cameraFocusedOnTile-tilesToRenderFromCam < WORLDTILES_X)
                [((WorldTile *)worldTiles[cameraFocusedOnTile-tilesToRenderFromCam][i]) setVisible:true];
        }
    }
    cameraFocusedOnTile = newCameraTilePos;
    //Log(@"camera position = %d",cameraTilePos);
}

-(void) setScreenShakeIntensity:(int) inputIntensity withDuration:(int) inputDuration {
    Log(@"shake intensity: %d and duration: %d", inputIntensity, inputDuration);
    shakeIntensity = inputIntensity;
    shakeTotalDuration = shakeDuration = inputDuration;
}

-(void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint worldLocation = [Logic worldPositionFromTap:location];
    CGPoint tileLocation = CGPointMake((int)worldLocation.x/40 + 1, (int)worldLocation.y/40 + 1);
    
    [(Engine *) self.parent handleTileTapAt:tileLocation];
}

-(void) dealloc {
    //Log(@"dealloc called");
    for (int i = 0; i < WORLDTILES_X; i++) {
        for (int j = 0; j < WORLDTILES_Y; j++) {
            [(WorldTile *)worldTiles[i][j] release];
        }
    }
    
    [player release];
    [spawnPositions release];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    [super dealloc];
}

@end
