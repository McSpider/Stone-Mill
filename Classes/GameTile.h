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
  NSPoint pos;     // Tile position
  NSPoint oldPos;     // Tile position
  int type;       // Tile type
  int age;        // How old the tile is in turns
  BOOL active;    // Tile is being dragged or is selected
}

@property NSPoint pos;
@property NSPoint oldPos;
@property int type;
@property int age;
@property BOOL active;

- (NSImage *)image;
- (void)incrementAge;

@end
