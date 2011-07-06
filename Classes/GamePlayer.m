//
//  GamePlayer.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import "GamePlayer.h"


@implementation GamePlayer
@synthesize type;
@synthesize placedTileCount;
@synthesize moves;
@synthesize activeTiles;


- (id)init
{
  if (![super init]) {
    return nil;
  }
  
  type = ZeroPlayer;
  placedTileCount = 0;
  moves = 0;
  activeTiles = [[NSMutableArray alloc] init];
  return self;
}

- (id)initWithType:(int)playerType
{
  if (![super init]) {
    return nil;
  }
  
  type = playerType;
  placedTileCount = 0;
  moves = 0;
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
  return placedTileCount >= 9;
}

- (BOOL)tilesCanJump
{
  return [activeTiles count] == 3 && [self isSetup];
}

- (int)tileType
{
  switch (self.type) {
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
  switch (self.type) {
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
  [self.activeTiles removeAllObjects];
}


@end
