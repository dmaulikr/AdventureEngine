//
//  SharedTypes.h
//  Adventure Engine
//
//  Created by Galen Koehne on 12/27/12.
//

#ifndef Adventure_Engine_SharedTypes_h
#define Adventure_Engine_SharedTypes_h

enum Direction {
    LEFT=1,
    RIGHT=2
};
typedef enum Direction Direction;

enum GameActionTypes {
    ACTIONDELAY,
    ACTIONDIALOGUE,
    ACTIONCUTSCENE,
    ACTIONLOADWORLD,
    ACTIONPICKUPITEM,
    ACTIONREMOVEITEM,
    ACTIONREADABLE,
    ACTIONENDGAME,
    ACTIONTAP,
    ACTIONTRIG,
    ACTIONSHAKE,
    ACTIONBARRIER,
    ACTIONOBJECTVISIBILITY,
    ACTIONOBJECTANIMATION,
    ACTIONHISTORY
};

#endif
