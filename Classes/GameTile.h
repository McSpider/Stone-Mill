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
  int xPos, yPos;
  int type;
}

@property int type;

- (NSImage *)image;

@end
