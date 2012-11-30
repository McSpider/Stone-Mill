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
@synthesize smartness;
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
  smartness = 100;
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
  smartness = 100;
  placedTileCount = 0;
  moves = 0;
  state = 0;
  activeTiles = [[NSMutableArray alloc] init];
  return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@",[self playerName]];
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

- (BOOL)hasLost
{
  return [activeTiles count] <= 2 && [self isSetup];
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



@end
