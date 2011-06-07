//
//  GameController.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>
#import "GamePlayer.h"

#define TotalGamePositions (24)
#define MaxPlayerTiles (9)
#define TileSize (29)
#define HalfTileSize (14)

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

@property (nonatomic, readonly) GamePlayer *humanPlayer;
@property (nonatomic, readonly) GamePlayer *robotPlayer;

- (BOOL)tilesCanJump;
- (BOOL)gameIsSetup;

- (NSString*)totalMoves;

- (NSArray *)validTilePositions;
- (GameTile *)tileAtPoint:(NSPoint)point;
- (GameTile *)tileNearestToPoint:(NSPoint)point;
- (NSArray *)validTilePositionsFromPoint:(NSPoint)point;

@end
