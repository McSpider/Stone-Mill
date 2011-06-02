//
//  TileManager.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TileManager.h"


@implementation TileManager


- (BOOL)tilesCanJump
{
  if (activeTiles == 3)
    return YES;
  return NO;
}


@end
