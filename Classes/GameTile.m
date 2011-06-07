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


- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init]))
	{
		pos = [decoder decodePointForKey:@"pos"];
    oldPos = [decoder decodePointForKey:@"oldPos"];
		type = [decoder decodeIntForKey:@"type"];
		age = [decoder decodeIntForKey:@"age"];
    active = [decoder decodeBoolForKey:@"active"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodePoint:pos forKey:@"pos"];
	[coder encodePoint:oldPos forKey:@"oldPos"];
	[coder encodeInt:type forKey:@"type"];
	[coder encodeInt:age forKey:@"age"];
  [coder encodeBool:active forKey:@"active"];
}

- (NSImage *)image
{
  if (active) {
    if (self.type == PlayerTile)
      return [NSImage imageNamed:@"Blue_Active"];
    else if (self.type == RobotTile)
      return [NSImage imageNamed:@"Gold_Active"];
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
