//
//  GameTile.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define SMGhostTile (0)
#define SMPlayerTile (1)
#define SMComputerTile (2)


@interface GameTile : NSObject {
  NSPoint pos; // Tile position
  int type;       // Tile type
  int age;        // How old the tile is in turns
}

@property NSPoint pos;
@property int type;
@property int age;

- (NSImage *)image;

@end
