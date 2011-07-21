//
//  GameController.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import "GameController.h"
#import "GameView.h"
#include <stdlib.h>


@implementation GameController
@synthesize bluePlayer, goldPlayer, playingPlayer;
@synthesize ghostTileArray;
@synthesize boardPrefix;
@synthesize statusLabelString, movesLabelString;
@synthesize gameState, playingState;
@synthesize timeLabelString, gameTimer, gameStart;

- (id)init
{
  if (![super init]) {
    return nil;
  }
  [self setGameState:GameIdle];
  
  bluePlayer = [[GamePlayer alloc] initWithType:HumanPlayer andColor:BluePlayer];
  goldPlayer = [[GamePlayer alloc] initWithType:RobotPlayer andColor:GoldPlayer];
  ghostTileArray = [[NSMutableArray alloc] init];
  boardPrefix = [[NSString alloc] initWithString:@"Möbius"];
  
  errorSound = [[NSSound soundNamed:@"Error"] retain];
  removeSound = [[NSSound soundNamed:@"Remove"] retain];
  moveSound = [[NSSound soundNamed:@"Click"] retain];
  closeSound = [[NSSound soundNamed:@"Closed"] retain];
  
  return self;
}

- (void)awakeFromNib
{
  // populate the board selector with the boards
  [selectorPopup removeAllItems];
  NSArray *boardNames = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Boards" ofType:@"plist"]];
  [selectorPopup addItemsWithTitles:boardNames];
  self.boardPrefix = [boardNames objectAtIndex:[selectorPopup indexOfSelectedItem]];
  
  [gameView setBoardOpacity:1.0];
  self.timeLabelString = @"00:00";
  self.movesLabelString = @"Moves 0";
}

- (void)dealloc
{
  [errorSound release];
  [removeSound release];
  [moveSound release];
  [closeSound release];
  
  [boardPrefix release];
  
  [bluePlayer release];
  [goldPlayer release];
  [ghostTileArray release];
  [super dealloc];
}


- (BOOL)isGameSetup
{
  if (bluePlayer.isSetup && goldPlayer.isSetup)
    return YES;
  
  return NO;
}

- (void)setGameState:(int)theState
{
  gameState = theState;
  
  // Update the status label string
  if (gameState == GameIdle) {
    self.statusLabelString = @"";
  }
  else if (gameState == GamePaused) {
    self.statusLabelString = @"Game Paused";
  }
  else if (gameState == GameOver) {
    [gameButton setTitle:@"Reset Game"];
    if (playingState == Blue_Wins)
      self.statusLabelString = @"Blue Wins";
    else if (playingState == Gold_Wins)
      self.statusLabelString = @"Gold Wins";
    else
      self.statusLabelString = @"Game Over";
  }
  else {
    self.statusLabelString = [NSString stringWithFormat:@"%@'s Turn",[playingPlayer playerName]];
  }
}


- (NSDictionary *)validTilePositions
{
  NSString *fileName = [NSString stringWithFormat:@"%@_CoordMap",boardPrefix];
  return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"]];
}

- (GameTile *)tileAtPoint:(NSPoint)point
{
  NSArray *activeTiles = [bluePlayer activeTiles];
  for (GameTile *tile in activeTiles) {
    NSRect tileBounds = NSMakeRect(tile.pos.x-HALF_TILE_SIZE, tile.pos.y-HALF_TILE_SIZE, TILE_SIZE, TILE_SIZE);
    if (NSPointInRect(point,tileBounds)) {
      return tile;
    }
  }
  activeTiles = [goldPlayer activeTiles];
  for (GameTile *tile in activeTiles) {
    NSRect tileBounds = NSMakeRect(tile.pos.x-HALF_TILE_SIZE, tile.pos.y-HALF_TILE_SIZE, TILE_SIZE, TILE_SIZE);
    if (NSPointInRect(point,tileBounds)) {
      return tile;
    }
  }
  activeTiles = [self ghostTileArray];
  for (GameTile *tile in activeTiles) {
    NSRect tileBounds = NSMakeRect(tile.pos.x-HALF_TILE_SIZE, tile.pos.y-HALF_TILE_SIZE, TILE_SIZE, TILE_SIZE);
    if (NSPointInRect(point,tileBounds)) {
      return tile;
    }
  }

  return nil;
}

- (GameTile *)tileNearestToPoint:(NSPoint)point
{
  //GameTile *tile = [[GameTile alloc] init];
  //return tile;
  return nil;
}

- (NSDictionary *)validTilePositionsFromPoint:(NSPoint)point player:(GamePlayer *)thePlayer
{
  NSDictionary *tilePositions;
  NSMutableDictionary *positions = [[NSMutableDictionary alloc] init];
  BOOL fromStoneQuarry = NSEqualPoints(point, gameView.viewCenter);
  
  // Return an dictionary consisting of the tile positions that can be moved to from the specified position
  if (fromStoneQuarry || [thePlayer tilesCanJump])
    tilePositions = [self validTilePositions];
  else
    tilePositions = [[self validTilePositions] objectForKey:[NSString stringWithFormat:@"%i, %i",(int)point.x,(int)point.y]];

  for (NSString *string in tilePositions) {
    if ([self tileAtPoint:NSPointFromString(string)])
      continue;
    [positions setObject:string forKey:string];
  }
  
  // return all spots that are empty and valid
  return [positions autorelease];
}

- (NSDictionary *)tilePositionsFromPoint:(NSPoint)point player:(GamePlayer *)thePlayer;
{
  NSDictionary *tilePositions;
  NSMutableDictionary *positions = [[NSMutableDictionary alloc] init];
  
  tilePositions = [[self validTilePositions] objectForKey:[NSString stringWithFormat:@"%i, %i",(int)point.x,(int)point.y]];
  
  for (NSString *string in tilePositions) {
    GameTile *aTile = [self tileAtPoint:NSPointFromString(string)];
    if (aTile != nil && aTile.type == [thePlayer tileType])
      [positions setObject:string forKey:string];
  }
  
  // return all spots that have a tile which the current player owns
  return [positions autorelease];
}

// Should return an angle relative to a vertical line
- (int)offsetDirectionFromPoint:(NSPoint)fromPos toPoint:(NSPoint)toPos
{
  //return atan2f(toPos.y-fromPos.y,toPos.x-fromPos.x);
  
  int returnValue = 0;
  if (fromPos.x < toPos.x)
    returnValue = 1; // Right
  else if (fromPos.x > toPos.x)
    returnValue = 4; // Left
  
  if (fromPos.y < toPos.y)
    returnValue = 6; // Up
  else if (fromPos.y > toPos.y)
    returnValue = 8; // Down
  return returnValue;
}

- (int)oppositeOffsetDirection:(int)offsetDir
{
  //return ((offsetDir + 180) % 360);
  
  if (offsetDir == 1)
    return 4;
  if (offsetDir == 4)
    return 1;
  if (offsetDir == 8)
    return 6;
  if (offsetDir == 6)
    return 8;
  return 0;
}

- (BOOL)validMove:(NSPoint)point player:(GamePlayer *)thePlayer;
{
  if (![self tileAtPoint:point])
    return NO;
  
  if (![thePlayer isSetup]) {
    NSRect quarry = NSMakeRect(250-HALF_TILE_SIZE, 250-HALF_TILE_SIZE, TILE_SIZE, TILE_SIZE);
    if (NSPointInRect(point,quarry))
      return YES;
  }
  else {
    return YES;
  }
  
  return NO;
}

- (BOOL)removeTileAtPoint:(NSPoint)point player:(GamePlayer *)thePlayer
{
  GameTile *aTile = [self tileAtPoint:point];
  if (!aTile)
    return NO;
  
  if (aTile.type == [thePlayer tileType] || aTile.type == GhostTile) {
    [errorSound play];
    return NO;
  }
  
  // get the opponent player
  GamePlayer *aPlayer = ((thePlayer == bluePlayer)?goldPlayer:bluePlayer);
  
  BOOL allMills = YES;
  // Check if all tiles are in a mill and if they are either call it a draw, or allow removal of selected tile
  for (GameTile *aTile in aPlayer.activeTiles) {
    if (![self isMill:aTile.pos player:aPlayer])
      allMills = NO;
  }
  // Check if tile is in a mill, and return NO if it's
  if ([self isMill:aTile.pos player:aPlayer] && !allMills) {
    [errorSound play];
    return NO;
  }
  
  // Remove Tile
  if (aTile.type == BlueTile)
    [bluePlayer.activeTiles removeObject:aTile];
  else if (aTile.type == GoldTile)
    [goldPlayer.activeTiles removeObject:aTile];
  
  [removeSound play];
  
  [thePlayer setState:0];
  if (playingPlayer.type == RobotPlayer) {
    [self performSelector:@selector(playerFinishedMoving) withObject:nil afterDelay:0.2];
    return YES;
  }
  
  [self playerFinishedMoving];
  return YES;
}


- (void)playerMovedFrom:(NSPoint)fromPos to:(NSPoint)toPos;
{
  playingPlayer.moves += 1;
  self.movesLabelString = [NSString stringWithFormat:@"Moves %i",(bluePlayer.moves + goldPlayer.moves)];
    
  // Increment the age of all stones
  for (GameTile *theTile in ghostTileArray) {
    [theTile setAge:theTile.age + 1];
  }
  for (GameTile *theTile in bluePlayer.activeTiles) {
    [theTile setAge:theTile.age + 1];
  }
  for (GameTile *theTile in goldPlayer.activeTiles) {
    [theTile setAge:theTile.age + 1];
  }
  
  // Add a ghost
  if ([playingPlayer tilesCanJump] && [ghostCheck state]) {
    GameTile *tile = [[GameTile alloc] init];  
    [tile setPos:fromPos];
    [tile setType:GhostTile];
    [self.ghostTileArray addObject:tile];
    [tile release];
  }
    
  BOOL fromQuarry = NSEqualPoints(fromPos, gameView.viewCenter);
    
  if (![playingPlayer isSetup] && fromQuarry)
    playingPlayer.placedTileCount += 1;
  
  // If we closed a mill we get to remove a enemy stone
  if ([self isMill:toPos player:playingPlayer]) {
    NSLog(@"Closed Mill");
    [closeSound play];
    [playingPlayer setState:1];
    [self removeOldGhosts];
    return;
  }

  [moveSound play];
  if (playingPlayer.type == RobotPlayer) {
    [self performSelector:@selector(playerFinishedMoving) withObject:nil afterDelay:0.2];
    return;
  }
  
  [self playerFinishedMoving];
}

- (BOOL)isMill:(NSPoint)aPoint player:(GamePlayer *)thePlayer;
{
  BOOL stone1 = NO; // First Stone, always returns YES if there's an adjacent stone to the starting position X O
  BOOL stone2 = NO; // Second Stone, returns true if there's a stone adjacent and in the same direction as the second position X O 0
  BOOL stone3 = NO; // Third Stone, returns true if there's a stone adjacent and in the opposite direction as starting position 0 X O
  
  // Try to build a row of 3 stones which include our starting position
  NSDictionary *tilePositions1 = [self tilePositionsFromPoint:aPoint player:thePlayer];
  for (NSString *thePos1 in tilePositions1) {
    // Store direction we are moving
    int direction1 = [self offsetDirectionFromPoint:aPoint toPoint:NSPointFromString(thePos1)];
    NSLog(@"Stone %i to the original pos",direction1);
    stone1 = YES;
    
    // We are moving a certain direction now keep going that way
    NSDictionary *tilePositions2 = [self tilePositionsFromPoint:NSPointFromString(thePos1) player:thePlayer];
    for (NSString *thePos2 in tilePositions2) {
      int direction2 = [self offsetDirectionFromPoint:NSPointFromString(thePos1) toPoint:NSPointFromString(thePos2)];
      NSLog(@"%i",direction2);
      if (direction2 != direction1)
        continue;
      NSLog(@"Stone %i to the second pos",direction2);
      stone2 = YES;
      break;
    }
    // Also try going the opposite direction from the original position
    for (NSString *thePos1 in tilePositions1) {
      int direction2 = [self offsetDirectionFromPoint:aPoint toPoint:NSPointFromString(thePos1)];
      if (direction2 != [self oppositeOffsetDirection:direction1])
        continue;
      NSLog(@"Stone opposite %i to the original pos",direction2);
      stone3 = YES;
      break;
    }
    if (stone1 && (stone2 || stone3)) {
      // Exit loop we found a mill
      break;
    }
    else {
      // Didn't find a full match, reset booleans
      stone1 = NO;
      stone2 = NO;
      stone3 = NO;
    }
  }

  NSLog(@"%i,%i,%i",(stone1?1:0),(stone2?1:0),(stone3?1:0));
  return (stone1 && (stone2 || stone3));
}

- (void)playerFinishedMoving
{
  [self selectNextPlayer];
  
  [self removeOldGhosts];
  
  if (![self playerCanMove:playingPlayer] || [playingPlayer hasLost]) {
    [pauseButton setEnabled:NO];
    [pauseButton setTransparent:YES];
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    if ([playingPlayer color] == BluePlayer)
      playingState = Gold_Wins;
    else if ([playingPlayer color] == GoldPlayer)
      playingState = Blue_Wins;
    [self setGameState:GameOver];
    return;
  }
  
  if (!playingPlayer.isSetup && ![self tileAtPoint:gameView.viewCenter]) {
    // Replace stone quarry stone
    GameTile *tile = [[GameTile alloc] init];
    [tile setPos:gameView.viewCenter];
    [tile setType:[playingPlayer tileType]];
    [playingPlayer.activeTiles addObject:tile];
    [tile release];
  }
  if (playingPlayer.type == RobotPlayer)
    [self performSelector:@selector(movePlayer:) withObject:playingPlayer afterDelay:0.2]; //[self movePlayer:playingPlayer];
  [gameView setNeedsDisplay:YES];
}

- (void)selectNextPlayer
{
  switch (playingPlayer.color) {
    case BluePlayer:
      playingPlayer = goldPlayer;
      break;
    case GoldPlayer:
      playingPlayer = bluePlayer;
      break;
    default:
      playingPlayer = bluePlayer;
      break;
  }
  self.statusLabelString = [NSString stringWithFormat:@"%@'s Turn",[playingPlayer playerName]];
}

- (BOOL)playerCanMove:(GamePlayer *)thePlayer;
{
  BOOL canMove = NO;
  for (GameTile *aTile in thePlayer.activeTiles) {
    if ([[self validTilePositionsFromPoint:aTile.pos player:thePlayer] count] > 0) {
      canMove = YES;
    }
  }
  // Check if the player could move from the quarry
  if (!thePlayer.isSetup && !canMove)
    if ([[self validTilePositionsFromPoint:gameView.viewCenter player:thePlayer] count] > 0)
      canMove = YES;
  
  // Check if the player can jump and there are empty spots
  if (thePlayer.tilesCanJump && [jumpCheck state])
    if ([[self validTilePositions] count] > 0)
      canMove = YES;

  return canMove;
}

- (void)movePlayer:(GamePlayer *)thePlayer
{
  if (thePlayer.state == 0) {
    // get all the tiles we can move
    if (![thePlayer isSetup]) {
      NSDictionary *validMoves = [self validTilePositionsFromPoint:gameView.viewCenter player:thePlayer];
      GameTile *aTile = [self tileAtPoint:gameView.viewCenter];
      if (aTile && validMoves != 0) {
        [aTile setOldPos:[aTile pos]];
        [aTile setPos:NSPointFromString([[validMoves allValues] objectAtIndex:(arc4random() % [validMoves count])])];
        [self playerMovedFrom:[aTile oldPos] to:[aTile pos]];
      }
    }
    else {
      for (GameTile *aTile in thePlayer.activeTiles) {
        NSDictionary *validMoves = [self validTilePositionsFromPoint:[aTile pos] player:thePlayer];
        if (validMoves && [validMoves count] != 0) {
          [aTile setOldPos:[aTile pos]];
          [aTile setPos:NSPointFromString([[validMoves allValues] objectAtIndex:(arc4random() % [validMoves count])])];
          [self playerMovedFrom:[aTile oldPos] to:[aTile pos]];
          break;
        }
      }
    }
  }
  if (thePlayer.state == 1) {
    for (NSString *string in [self validTilePositions]) {
      if ([self removeTileAtPoint:NSPointFromString(string) player:thePlayer])
        break;
    }
  }
  [gameView setNeedsDisplay:YES];
}

- (void)removeOldGhosts
{
  // Remove ghost stones older that 1 turn
  int index = 0;
  for (index = ghostTileArray.count - 1; index >= 0; index--)  {
    GameTile *theTile = [ghostTileArray objectAtIndex:index];
    if ([theTile age] >= 1)
      [ghostTileArray removeObjectAtIndex:index];
  }
}

- (void)addTemporaryStones
{
  /// Temporary active tiles
  GameTile *tile = [[GameTile alloc] init];  
  [tile setPos:NSMakePoint(310,310)];
  [tile setType:GhostTile];
  // Make this tile unremovable used to test
  //[tile setAge:-2000];
  [self.ghostTileArray addObject:tile];
  [tile release];
}


#pragma mark -
#pragma mark Actions

- (IBAction)newGame:(id)sender
{
  [goldPlayer reset];
  [bluePlayer reset];
  [ghostTileArray removeAllObjects];
  [self.gameTimer invalidate];
  self.gameTimer = nil;
  self.timeLabelString = @"00:00";
  self.movesLabelString = @"Moves 0";
  
  if (gameState != GamePaused && gameState == GameIdle) {
    [gameButton setTitle:@"End Game"];
    [selectorPopup setEnabled:NO];
    [pauseButton setEnabled:YES];
    [pauseButton setTransparent:NO];
    [pauseButton setState:0];
    [ghostCheck setEnabled:NO];
    [jumpCheck setEnabled:NO];
    
    playingPlayer = bluePlayer;
    [self setGameState:GameRunning];
    
    // Add stone quarry
    GameTile *tile = [[GameTile alloc] init];  
    [tile setPos:gameView.viewCenter];
    [tile setType:BlueTile];
    [playingPlayer.activeTiles addObject:tile];
    [tile release];
    
    [self addTemporaryStones];
    self.gameStart = [NSDate date];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(updateTimer)
                                                    userInfo:nil
                                                      repeats:TRUE];
  }
  else if (gameState == GameRunning || gameState == GamePaused || gameState == GameOver) {
    [self setGameState:GameIdle];
    [gameButton setTitle:@"Start Game"];
    [selectorPopup setEnabled:YES];
    [pauseButton setEnabled:NO];
    [pauseButton setTransparent:YES];
    [ghostCheck setEnabled:YES];
    [jumpCheck setEnabled:YES];
  }

  [gameView setNeedsDisplay:YES];
}

- (IBAction)pauseGame:(id)sender
{  
  if (sender != pauseButton) {
    if (gameState == GameRunning)
      [self setGameState:GamePaused];
    [pauseButton setState:1];
  }
  else {
    // Toggle game state
    if (gameState == GameRunning) {
      [self setGameState:GamePaused];
    }
    else if (gameState == GamePaused) {
      [self setGameState:GameRunning];
    }
  }  
  [gameView setNeedsDisplay:YES];
}

- (IBAction)changeBoard:(id)sender
{
  NSArray *boardNames = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Boards" ofType:@"plist"]];
  self.boardPrefix = [boardNames objectAtIndex:[sender indexOfSelectedItem]];
  [gameView setNeedsDisplay:YES];
}


- (void)updateTimer
{
	NSAutoreleasePool * pool0 = [[NSAutoreleasePool alloc] init];
	// determine seconds between now and gameStart
	NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:self.gameStart];
	NSInteger minutes = ((NSInteger)((CGFloat)seconds/60.0f));
  self.timeLabelString = [NSString stringWithFormat:@"%02d:%02d",
                          minutes,
                          ((NSInteger)seconds) - (minutes*60)];
	[pool0 release];
}


@end
