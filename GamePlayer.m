//
//  GamePlayer.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GamePlayer.h"


@implementation GamePlayer
@synthesize type;
@synthesize color;
@synthesize placedTileCount;
@synthesize moves;
@synthesize activeTiles;


- (id)init
{
  if (![super init]) {
    return nil;
  }
  
  type = RobotPlayer;
  color = Ghost;
  placedTileCount = 0;
  moves = 0;
  activeTiles = [[NSMutableArray alloc] init];
  return self;
}

- (BOOL)isSetup
{
  return placedTileCount == 9;
}

- (BOOL)tilesCanJump
{
  return [activeTiles count] == 3 && [self isSetup];
}

@end
