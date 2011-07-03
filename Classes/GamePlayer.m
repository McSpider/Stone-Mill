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
  
  type = GhostPlayer;
  placedTileCount = 0;
  moves = 0;
  activeTiles = [[NSMutableArray alloc] init];
  return self;
}

- (BOOL)isSetup
{
  return placedTileCount >= 9;
}

- (BOOL)tilesCanJump
{
  return [activeTiles count] == 3 && [self isSetup];
}

- (int)color
{
  return self.type;
}

- (NSString*)playerName
{
  switch (color) {
    case Blue:
      return @"Blue Player";
      break;
      
    case Gold:
      return @"Gold Player";
      break;
      
    default:
      break;
  }
  return @"Ghost Player";
}


@end
