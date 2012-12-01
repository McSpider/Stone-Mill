//
//  GameTile.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import "GameTile.h"


@implementation GameTile
@synthesize renderObject;
@synthesize pos;
@synthesize oldPos;
//@synthesize type;
@synthesize age;
//@synthesize active;

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
  
  CCTexture2D *ghost = [[CCTextureCache sharedTextureCache] addImage:@"Ghost_Inactive.png"];
  renderObject = [[[CCSprite alloc] initWithTexture:ghost] retain];
  
  return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ %p> pos: %f %f age: %i", NSStringFromClass([self class]), self, self.pos.x, self.pos.y, self.age];
}

- (void)dealloc
{
  [super dealloc];
}


- (void)updateSprite
{
  CCTexture2D *blue = [[CCTextureCache sharedTextureCache] addImage:@"Blue_Inactive.png"];
  CCTexture2D *blue_a = [[CCTextureCache sharedTextureCache] addImage:@"Blue_Active.png"];
  CCTexture2D *gold = [[CCTextureCache sharedTextureCache] addImage:@"Gold_Inactive.png"];
  CCTexture2D *gold_a = [[CCTextureCache sharedTextureCache] addImage:@"Gold_Active.png"];
  CCTexture2D *ghost = [[CCTextureCache sharedTextureCache] addImage:@"Ghost_Inactive.png"];
  
  CCTexture2D *texture;
  
  if (type == BlueTile && active)
    texture = blue_a;
  else if (type == BlueTile && !active)
    texture = blue;
  else if (type == GoldTile && active)
    texture = gold_a;
  else if (type == GoldTile && !active)
    texture = gold;
  else if (type == GhostTile)
    texture = ghost;
  
  if (texture)
    [renderObject setTexture:texture];
}


- (void)setType:(int)aType
{
  type = aType;
  [self updateSprite];
}

- (int)type
{
  return type;
}

- (void)setActive:(BOOL)isActive
{
  active = isActive;
  [self updateSprite];
}

- (BOOL)active
{
  return active;
}

- (void)incrementAge
{
  self.age += 1;
}

- (void)moveToPos:(NSPoint)aPos animate:(BOOL)animate
{
  [self setOldPos:self.pos];
  
  if (animate) {
    float distance = ccpDistance(self.renderObject.position, CGPointMake(aPos.x+0.5, aPos.y+0.5));
    
    id action = [CCMoveTo actionWithDuration:distance/800 position:CGPointMake(aPos.x+0.5, aPos.y+0.5)];
    id seqence = [CCSequence actions:action, nil];
    [renderObject runAction:seqence];
  }
  [self setPos:aPos];
}

- (void)setPos:(NSPoint)aPos
{
  pos = aPos;
  [renderObject setPosition:NSMakePoint(aPos.x+0.5, aPos.y+0.5)];
}

@end
