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
  Game_Draw,
  Gold_Wins,
  Blue_Wins
} PlayingState;


@class GameView;

@interface GameController : NSObject {
  IBOutlet NSPopUpButton *selectorPopup;
  IBOutlet NSButton *gameButton;
  IBOutlet NSButton *pauseButton;
  IBOutlet NSButton *ghostCheck;
  IBOutlet NSButton *jumpCheck;
  IBOutlet NSButton *playersCheck;
  
  int gameState;
  int playingState;
  NSString *boardPrefix;

  NSTimeInterval timeLimit;
  NSTimeInterval playingTime;
  float moveRate;
    
  GamePlayer *bluePlayer;
  GamePlayer *goldPlayer;
  GamePlayer *playingPlayer;
  
  NSString * movesLabelString;
  NSString * statusLabelString;
  
  NSSound *errorSound;
  NSSound *removeSound;
  NSSound *moveSound;
  NSSound *closeSound;
  
  NSMutableArray *ghostTileArray;
  IBOutlet GameView *gameView;
  
  NSDate * gameStart;
  NSString * timeLabelString;
  NSTimer * gameTimer;
}

@property (nonatomic, readonly) GamePlayer *bluePlayer;
@property (nonatomic, readonly) GamePlayer *goldPlayer;
@property (nonatomic, assign) GamePlayer *playingPlayer;
@property (nonatomic, retain) NSString * boardPrefix;
@property (nonatomic, retain) NSString * movesLabelString;
@property (nonatomic, retain) NSString * statusLabelString;
@property (nonatomic, retain) NSMutableArray *ghostTileArray;
@property int gameState, playingState;
@property (nonatomic, retain) NSString * timeLabelString;
@property (nonatomic, retain) NSTimer * gameTimer;
@property (nonatomic, retain) NSDate * gameStart;

- (BOOL)isGameSetup;

- (NSDictionary *)validTilePositions;
- (GameTile *)tileAtPoint:(NSPoint)point;
- (GameTile *)tileNearestToPoint:(NSPoint)point;
- (NSDictionary *)validTilePositionsFromPoint:(NSPoint)point player:(GamePlayer *)thePlayer;
- (NSDictionary *)tilePositionsFromPoint:(NSPoint)point player:(GamePlayer *)thePlayer;
- (int)offsetDirectionFromPoint:(NSPoint)fromPos toPoint:(NSPoint)toPos;

- (NSArray *)closableMillsForPlayer:(GamePlayer *)thePlayer;

- (BOOL)validMove:(NSPoint)point player:(GamePlayer *)thePlayer;
- (BOOL)removeTileAtPoint:(NSPoint)point player:(GamePlayer *)thePlayer;

- (void)playerMovedFrom:(NSPoint)fromPos to:(NSPoint)toPos;
- (BOOL)isMill:(NSPoint)aPoint player:(GamePlayer *)thePlayer;
- (void)playerFinishedMoving;
- (void)selectNextPlayer;

- (BOOL)playerCanMove:(GamePlayer *)thePlayer;
- (void)moveForPlayer:(GamePlayer *)thePlayer;
- (void)removeOldGhosts;


- (IBAction)newGame:(id)sender;
- (IBAction)pauseGame:(id)sender;
- (IBAction)changeBoard:(id)sender;

@end
