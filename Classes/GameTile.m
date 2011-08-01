//
//  GameTile.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import "GameTile.h"


@implementation GameTile
@synthesize pos;
@synthesize oldPos;
@synthesize type;
@synthesize age;
@synthesize active;

- (id)init
{
  if (![super init]) {
    return nil;
  }
  
  pos = NSZeroPoint;
  oldPos = NSZeroPoint;
  type = GhostTile;
  age = 0;
  active = NO;
  
  return self;
}

- (void)dealloc
{
  [super dealloc];
}


- (NSImage *)image
{
  if (active) {
    if (self.type == BlueTile)
      return [NSImage imageNamed:@"Blue_Active"];
    else if (self.type == GoldTile)
      return [NSImage imageNamed:@"Gold_Active"];
  }
  else {
    if (self.type == BlueTile)
      return [NSImage imageNamed:@"Blue_Inactive"];
    else if (self.type == GoldTile)
      return [NSImage imageNamed:@"Gold_Inactive"];
  }
  
  if (self.type == GhostTile)
    return [NSImage imageNamed:@"Ghost_Inactive"];
  return [NSImage imageNamed:@"Unknown"];
}

- (void)incrementAge
{
  self.age += 1;
}


@end
