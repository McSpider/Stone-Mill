//
//  GamePlayer.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import <Cocoa/Cocoa.h>
#import "GameTile.h"

typedef enum {
  BluePlayer,
  GoldPlayer,
  ZeroPlayer
} PlayerTypes;


@interface GamePlayer : NSObject {
  int type;
  int placedTileCount;
  int moves;
  
  NSMutableArray *activeTiles;
}
@property int type;
@property int placedTileCount;
@property int moves;
@property (nonatomic, retain) NSMutableArray *activeTiles;

- (id)initWithType:(int)playerType;

// Player has placed all his tiles and can now move
- (BOOL)isSetup;

// Player has less than 3 active tiles then he can jump it the game permits it
- (BOOL)tilesCanJump;
- (int)tileType;
- (NSString*)playerName;

- (void)reset;


@end
