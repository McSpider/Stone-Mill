//
//  GameController.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import <Cocoa/Cocoa.h>
#import "GamePlayer.h"

#define TOTAL_POSITIONS (24)
#define TILE_SIZE (29)
#define HALF_TILE_SIZE (14)

typedef enum {
  GameIdle,
  GamePaused,
  GameRunning,
  GameOver
} GameState;

typedef enum {
  Gold_Playing,
  Blue_Playing,
  Gold_MillClosed,
  Blue_MillClosed,
  Gold_Wins,
  Blue_Wins
} PlayingState;


@class GameView;

@interface GameController : NSObject {
  IBOutlet NSButton *gameButton;
  IBOutlet NSButton *pauseButton;
  IBOutlet NSButton *ghostCheck;
  IBOutlet NSButton *jumpCheck;
  
  int gameState;
  int playingState;

  BOOL tilesCanJump;
  BOOL ghostTiles;
  NSTimeInterval timeLimit;
  NSTimeInterval playingTime;
    
  GamePlayer *bluePlayer;
  GamePlayer *goldPlayer;
  GamePlayer *playingPlayer;
  
  NSMutableArray *ghostTileArray;
  
  IBOutlet GameView *gameView;
}

@property (nonatomic, readonly) GamePlayer *bluePlayer;
@property (nonatomic, readonly) GamePlayer *goldPlayer;
@property (nonatomic, assign) GamePlayer *playingPlayer;
@property (nonatomic, retain) NSMutableArray *ghostTileArray;
@property int gameState, playingState;

- (BOOL)tilesCanJump;
- (BOOL)isGameSetup;

- (NSString*)movesLabelString;
- (NSString*)timeLabelString;
- (NSString*)statusLabelString;

- (NSDictionary *)validTilePositions;
- (GameTile *)tileAtPoint:(NSPoint)point;
- (GameTile *)tileNearestToPoint:(NSPoint)point;
- (NSDictionary *)validTilePositionsFromPoint:(NSPoint)point;

- (BOOL)validMove:(NSPoint)point;
- (BOOL)validDrop:(NSPoint)point;


- (void)playerMovedFrom:(NSPoint)fromPos to:(NSPoint)toPos;
- (void)playerFinishedMoving;
- (void)selectNextPlayer;

- (BOOL)playerCanMove;
- (void)movePlayer;


- (IBAction)newGame:(id)sender;
- (IBAction)pauseGame:(id)sender;

@end
