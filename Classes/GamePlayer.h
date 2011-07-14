//
//  GamePlayer.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import <Cocoa/Cocoa.h>
#import "GameTile.h"

#define MAX_PLAYER_TILES (9)

typedef enum {
  HumanPlayer,
  RobotPlayer,
  GhostPlayer
} PlayerTypes;

typedef enum {
  BluePlayer,
  GoldPlayer,
  ZeroPlayer
} PlayerColors;


@interface GamePlayer : NSObject {
  int type;
  int color;
  int placedTileCount;
  int moves;
  
  int state; // 0 Idle, 1 MillClosed
  NSMutableArray *activeTiles;
}
@property int type, color;
@property int placedTileCount;
@property int moves;
@property int state;
@property (nonatomic, retain) NSMutableArray *activeTiles;

- (id)initWithType:(int)aPlayerType andColor:(int)aColor;

// Player has placed all his tiles and can now move
- (BOOL)isSetup;

// Player has less than 3 active tiles then he can jump it the game permits it
- (BOOL)tilesCanJump;
- (int)tileType;
- (NSString*)playerName;

- (void)reset;


@end
