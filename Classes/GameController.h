//
//  GameController.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GamePlayer.h"

#define TotalGamePositions (24)
#define MaxPlayerTiles (9)

@interface GameController : NSObject {
  IBOutlet NSButton *multipurposeButton;
  IBOutlet NSButton *ghostCheck;
  IBOutlet NSButton *jumpCheck;
  
  BOOL gameIsRunning;
  BOOL gameIsPaused;
  BOOL gameIsSetup;
  BOOL tilesCanJump;
  BOOL ghostTiles;
  NSTimeInterval timeLimit;
  NSTimeInterval playingTime;
    
  GamePlayer *humanPlayer;
  GamePlayer *robotPlayer;
}

- (BOOL)tilesCanJump;
- (BOOL)gameIsSetup;

- (NSString*)totalMoves;

- (NSArray *)validTilePositions;
- (GameTile *)tileAtPoint:(NSPoint)point;
- (GameTile *)tileNearestToPoint:(NSPoint)point;

@end
