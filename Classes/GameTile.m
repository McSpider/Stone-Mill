//
//  GameTile.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameTile.h"


@implementation GameTile
@synthesize type;

- (NSImage *)image
{
  if (self.type == SMPlayerTile)
    return [NSImage imageNamed:@"Gold Stone"];
  if (self.type == SMComputerTile)
    return [NSImage imageNamed:@"Blue Stone"];
  
  return [NSImage imageNamed:@"Ghost Stone"];
}

@end
