//
//  GamePlayer.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import "GamePlayer.h"


@implementation GamePlayer
@synthesize type,color;
@synthesize placedTileCount;
@synthesize moves;
@synthesize activeTiles;
@synthesize state;


- (id)init
{
  if (![super init]) {
    return nil;
  }
  
  type = ZeroPlayer;
  placedTileCount = 0;
  moves = 0;
  state = 0;
  activeTiles = [[NSMutableArray alloc] init];
  return self;
}

- (id)initWithType:(int)aPlayerType andColor:(int)aColor;
{
  if (![super init]) {
    return nil;
  }
  
  type = aPlayerType;
  color = aColor;
  placedTileCount = 0;
  moves = 0;
  state = 0;
  activeTiles = [[NSMutableArray alloc] init];
  return self;
}

- (void)dealloc
{
  [activeTiles release];
  [super dealloc];
}


- (BOOL)isSetup
{
  return placedTileCount >= MAX_PLAYER_TILES;
}

- (BOOL)tilesCanJump
{
  return [activeTiles count] == 3 && [self isSetup];
}

- (int)tileType
{
  switch (self.color) {
    case BluePlayer:
      return BlueTile;
      break;
      
    case GoldPlayer:
      return GoldTile;
      break;
      
    default:
      return GhostTile;
      break;
  }
  return GhostTile;
}

- (NSString*)playerName
{
  switch (self.color) {
    case BluePlayer:
      return @"Blue Player";
      break;
      
    case GoldPlayer:
      return @"Gold Player";
      break;
      
    default:
      break;
  }
  return @"Ghost Player";
}

- (void)reset
{
  self.placedTileCount = 0;
  self.moves = 0;
  self.state = 0;
  [self.activeTiles removeAllObjects];
}


@end
