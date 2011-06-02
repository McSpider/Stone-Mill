//
//  TileManager.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GamePlayer.h"

#define TotalGamePositions (24)
#define MaxPlayerTiles (9)

@interface TileManager : NSObject {
  BOOL gameIsSetup;
  BOOL tilesCanJump;
  
  GamePlayer *player1;
  GamePlayer *player2;
}

@end
