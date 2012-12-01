//
//  GameTile.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import <Cocoa/Cocoa.h>

typedef enum {
  BlueTile,
  GoldTile,
  GhostTile
} StoneTypes;


@interface GameTile : NSObject {
  CCSprite *renderObject;
  
  NSPoint pos;     // Tile position
  NSPoint oldPos;     // Tile position
  int type;       // Tile type
  int age;        // How old the tile is in turns
  BOOL active;    // Tile is being dragged or is selected
}

@property (nonatomic, retain) CCSprite *renderObject;

@property (nonatomic) NSPoint pos;
@property NSPoint oldPos;
@property int age;

- (void)incrementAge;

- (void)moveToPos:(NSPoint)aPos animate:(BOOL)animate;
- (void)setPos:(NSPoint)aPos;

- (void)setType:(int)aType;
- (int)type;

- (void)setActive:(BOOL)isActive;
- (BOOL)active;

@end
