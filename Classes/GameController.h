//
//  GameController.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import <Cocoa/Cocoa.h>
#import "GamePlayer.h"

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


@class GameScene;
@class GameSceneLayer;

@interface GameController : NSObject {
  IBOutlet NSWindow *mainWindow;
  IBOutlet MacGLView *glView;

  IBOutlet NSPopUpButton *selectorPopup;
  IBOutlet NSButton *gameButton;
  IBOutlet NSButton *pauseButton;
  IBOutlet NSButton *ghostCheck;
  IBOutlet NSButton *jumpCheck;
  IBOutlet NSButton *playersCheck;
  IBOutlet NSButton *muteButton;
  
  IBOutlet NSSlider *blueSmartnessSlider;
  IBOutlet NSSlider *goldSmartnessSlider;
  
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
  GameScene *gameScene;
  
  NSDate *gameStartTime;
  NSDate *gameStart;
  NSString *timeLabelString;
  NSTimer *gameTimer;
  NSMutableArray *timeArray;
}

@property (nonatomic, readonly) GamePlayer *bluePlayer;
@property (nonatomic, readonly) GamePlayer *goldPlayer;
@property (nonatomic, assign) GamePlayer *playingPlayer;
@property (nonatomic, retain) NSString *boardPrefix;
@property (nonatomic, retain) NSString *movesLabelString;
@property (nonatomic, retain) NSString *statusLabelString;
@property (nonatomic, retain) NSMutableArray *ghostTileArray;
@property (nonatomic) int gameState, playingState;
@property (nonatomic) float moveRate;
@property (nonatomic, retain) NSString *timeLabelString;
@property (nonatomic, retain) NSTimer *gameTimer;
@property (nonatomic, retain) NSDate *gameStartTime;
@property (nonatomic, retain) NSDate *gameStart;

@property (nonatomic, assign) GameScene *gameScene;

- (BOOL)isGameSetup;

- (NSDictionary *)validTilePositions;
- (NSArray *)activeTilePositions;
- (GameTile *)tileAtPoint:(NSPoint)point;
- (NSDictionary *)allTilePositionsFromPoint:(NSPoint)point player:(GamePlayer *)thePlayer;
- (NSDictionary *)playerTilePositionsFromPoint:(NSPoint)point player:(GamePlayer *)thePlayer;
- (int)offsetDirectionFromPoint:(NSPoint)fromPos toPoint:(NSPoint)toPos;

- (NSArray *)closableMillsForPlayer:(GamePlayer *)thePlayer;

- (BOOL)validMove:(NSPoint)point player:(GamePlayer *)thePlayer;
- (void)addTile:(GameTile *)aTile forPlayer:(GamePlayer *)thePlayer;
- (BOOL)removeTileAtPoint:(NSPoint)point player:(GamePlayer *)thePlayer;
- (BOOL)canRemoveGameTile:(GameTile *)aTile player:(GamePlayer *)thePlayer;

- (void)playerMovedFrom:(NSPoint)fromPos to:(NSPoint)toPos;
- (BOOL)isMill:(NSPoint)aPoint player:(GamePlayer *)thePlayer;
- (void)playerFinishedMoving;
- (void)selectNextPlayer;

- (BOOL)playerCanMove:(GamePlayer *)thePlayer;
- (void)moveForPlayer:(GamePlayer *)thePlayer;
- (void)moveRandomTileForPlayer:(GamePlayer *)thePlayer;
- (void)removeRandomTileForPlayer:(GamePlayer *)thePlayer;
- (void)removeOldGhosts;
- (void)resetPlayer:(GamePlayer *)thePlayer;
- (void)resetGhostTiles;

- (BOOL)randomProbability:(int)input;


- (IBAction)newGame:(id)sender;
- (IBAction)pauseGame:(id)sender;
- (IBAction)changeBoard:(id)sender;
- (IBAction)setPlayerSmartness:(id)sender;

@end
