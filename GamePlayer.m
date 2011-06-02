//
//  GamePlayer.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GamePlayer.h"


@implementation GamePlayer
@synthesize playerType;
@synthesize placedTileCount;


- (id)init
{
  if (![super init]) {
    return nil;
  }
  
  activeTiles = [[NSMutableArray alloc] init];
  return self;
}

- (BOOL)isSetup
{
  return placedTileCount == 9;
}

@end
