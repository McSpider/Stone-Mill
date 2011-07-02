//
//  GameTile.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the New BSD license.
//

#import "GameTile.h"


@implementation GameTile
@synthesize pos;
@synthesize oldPos;
@synthesize type;
@synthesize age;
@synthesize active;


- (NSImage *)image
{
  if (active) {
    if (self.type == PlayerTile)
      return [NSImage imageNamed:@"Blue_Active"];
    else if (self.type == RobotTile)
      return [NSImage imageNamed:@"Gold_Active"];
  }
  else if (0 != 0) {
    if (self.type == PlayerTile)
      return [NSImage imageNamed:@"Blue_Scared"];
    else if (self.type == RobotTile)
      return [NSImage imageNamed:@"Gold_Scared"];
  }
  else {
    if (self.type == PlayerTile)
      return [NSImage imageNamed:@"Blue_Inactive"];
    else if (self.type == RobotTile)
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
