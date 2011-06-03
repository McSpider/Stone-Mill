//
//  GamePlayer.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GameTile.h"

typedef enum {
  RobotPlayer,
  HumanPlayer
} PlayerTypes;

typedef enum {
  Blue,
  Gold,
  Ghost
} StoneTypes;


@interface GamePlayer : NSObject {
  int type;
  int color;
  int placedTileCount;
  
  NSMutableArray *activeTiles;
}
@property int type;
@property int color;
@property int placedTileCount;


// Player has placed all his tiles and can now move
- (BOOL)isSetup;

// Player has less than 3 active tiles then he can jump it the game permits it
- (BOOL)tilesCanJump;


@end
