//
//  TileManager.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GameTile.h"

#define MaxTiles (9)

@interface TileManager : NSObject {

  int activeTiles;
  int totalTiles;
  BOOL tilesCanJump;
}

@end
