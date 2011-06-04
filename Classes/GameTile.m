//
//  GameTile.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameTile.h"


@implementation GameTile
@synthesize pos;
@synthesize type;
@synthesize age;


- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init]))
	{
		pos = [decoder decodePointForKey:@"pos"];
		type = [decoder decodeIntForKey:@"type"];
		age = [decoder decodeIntForKey:@"age"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodePoint:pos forKey:@"pos"];
	[coder encodeInt:type forKey:@"type"];
	[coder encodeInt:age forKey:@"age"];
}

- (NSImage *)image
{
  if (self.type == SMComputerTile)
    return [NSImage imageNamed:@"Gold Stone"];
  if (self.type == SMPlayerTile)
    return [NSImage imageNamed:@"Blue Stone"];
  
  return [NSImage imageNamed:@"Ghost Stone"];
}

@end
