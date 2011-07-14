//
//  GameController.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import "GameController.h"
#import "GameView.h"


@implementation GameController
@synthesize bluePlayer, goldPlayer, playingPlayer;
@synthesize ghostTileArray;
@synthesize gameState, playingState;
@synthesize timeLabelString, gameTimer, gameStart;

- (id)init
{
  if (![super init]) {
    return nil;
  }
  tilesCanJump = YES;
  ghostTiles = YES;
  gameState = GameIdle;
  
  bluePlayer = [[GamePlayer alloc] initWithType:HumanPlayer andColor:BluePlayer];
  goldPlayer = [[GamePlayer alloc] initWithType:RobotPlayer andColor:GoldPlayer];
  ghostTileArray = [[NSMutableArray alloc] init];
  
  return self;
}

- (void)awakeFromNib
{
  [gameView setBoardOpacity:1.0];
  self.timeLabelString = @"00:00";
}

- (void)dealloc
{
  [bluePlayer release];
  [goldPlayer release];
  [ghostTileArray release];
  [super dealloc];
}


- (BOOL)tilesCanJump
{
  return tilesCanJump;
}

- (BOOL)isGameSetup
{
  if (bluePlayer.isSetup && goldPlayer.isSetup)
    return YES;
  
  return NO;
}

- (NSString*)movesLabelString
{
  return [NSString stringWithFormat:@"Moves %i",bluePlayer.moves+goldPlayer.moves];
}

- (NSString*)statusLabelString
{
  if (gameState == GameIdle)
    return @"";
  if (gameState == GamePaused)
    return @"Game Paused";
  if (gameState == GameOver) {
    if (playingState == Blue_Wins)
      return @"Blue Wins";
    else if (playingState == Gold_Wins)
      return @"Gold Wins";
    else
      return @"Game Over";
  }

  return [NSString stringWithFormat:@"%@'s Turn",[playingPlayer playerName]];
}


- (NSDictionary *)validTilePositions
{
  return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CoordMap" ofType:@"plist"]];
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

- (NSDictionary *)validTilePositionsFromPoint:(NSPoint)point
{
  NSDictionary *tilePositions;
  NSMutableDictionary *positions = [[NSMutableDictionary alloc] init];
  BOOL fromStoneQuarry = NSEqualPoints(point, gameView.viewCenter);
  
  // Return an dictionary consisting of the tile positions that can be moved to from the specified position
  if (fromStoneQuarry || [playingPlayer tilesCanJump])
    tilePositions = [self validTilePositions];
  else
    tilePositions = [[self validTilePositions] objectForKey:[NSString stringWithFormat:@"%i, %i",(int)point.x,(int)point.y]];

  for (NSString *string in tilePositions) {
    if ([self tileAtPoint:NSPointFromString(string)])
      continue;
    [positions setObject:string forKey:string];
  }
  
  return positions; //returns all spots that are empty and valid
}

- (BOOL)validMove:(NSPoint)point
{
  if (![self tileAtPoint:point])
    return NO;
  
  if (![playingPlayer isSetup]) {
    NSRect quarry = NSMakeRect(250-HALF_TILE_SIZE, 250-HALF_TILE_SIZE, TILE_SIZE, TILE_SIZE);
    if (NSPointInRect(point,quarry))
      return YES;
  }
  else {
    return YES;
  }
  
  return NO;
}

- (BOOL)validDrop:(NSPoint)point
{
  return NO;
}


- (BOOL)removeTileAtPoint:(NSPoint)point
{
  GameTile *aTile = [self tileAtPoint:point];
  
  if (aTile.type == [playingPlayer tileType] || aTile.type == GhostTile)
    return NO;
  
  // Remove Tile
  [playingPlayer setState:0];
  return YES;
}


- (void)playerMovedFrom:(NSPoint)fromPos to:(NSPoint)toPos;
{
  [self willChangeValueForKey:@"statusLabelString"];
  [self willChangeValueForKey:@"movesLabelString"];
  playingPlayer.moves += 1;
  
  BOOL fromQuarry = NSEqualPoints(fromPos, gameView.viewCenter);
  
  if (![playingPlayer isSetup] && fromQuarry)
    playingPlayer.placedTileCount += 1;
  
  NSSound *popSound = [NSSound soundNamed:@"Pop"];
	[popSound play];
  
  // We closed a mill so now we get to remove a enemy stone
  //if (![playingPlayer didCloseMill:toPos])
    [self playerFinishedMoving];
  [self didChangeValueForKey:@"statusLabelString"];
  [self didChangeValueForKey:@"movesLabelString"];
}

- (void)playerFinishedMoving
{
  [self selectNextPlayer];
  
  if (![self playerCanMove]) {
    gameState = GameOver;
    [pauseButton setEnabled:NO];
    [pauseButton setTransparent:YES];
      [self.gameTimer invalidate];
      self.gameTimer = nil;
    if ([playingPlayer color] == BluePlayer)
      playingState = Gold_Wins;
    else if ([playingPlayer color] == GoldPlayer)
      playingState = Blue_Wins;
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
    [self movePlayer];
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
}

- (BOOL)playerCanMove
{
  BOOL canMove = NO;
  for (GameTile *aTile in playingPlayer.activeTiles) {
    if ([[self validTilePositionsFromPoint:aTile.pos] count] > 0) {
      canMove = YES;
    }
  }
  // Check if the player could move from the quarry
  if (!playingPlayer.isSetup && !canMove)
    if ([[self validTilePositionsFromPoint:gameView.viewCenter] count] > 0)
      canMove = YES;

  return canMove;
}

- (void)movePlayer
{

}

- (void)addTemporaryStones
{
  /// Temporary active tiles
  GameTile *tile = [[GameTile alloc] init];  
  [tile setPos:NSMakePoint(310,310)];
  [tile setType:GhostTile];
  [self.ghostTileArray addObject:tile];
  [tile release];
}


#pragma mark -
#pragma mark Actions

- (IBAction)newGame:(id)sender
{
  [self willChangeValueForKey:@"movesLabelString"];
  [self willChangeValueForKey:@"statusLabelString"];
  [goldPlayer reset];
  [bluePlayer reset];
  [ghostTileArray removeAllObjects];
  [self.gameTimer invalidate];
  self.gameTimer = nil;
  
  if (gameState != GamePaused && gameState == GameIdle) {
    gameState = GameRunning;
    [gameButton setTitle:@"End Game"];
    [pauseButton setEnabled:YES];
    [pauseButton setTransparent:NO];
    [pauseButton setState:0];
    [ghostCheck setEnabled:NO];
    [jumpCheck setEnabled:NO];
    
    playingPlayer = bluePlayer;
    
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
    gameState = GameIdle;
    [gameButton setTitle:@"Start Game"];
    [pauseButton setEnabled:NO];
    [pauseButton setTransparent:YES];
    [ghostCheck setEnabled:YES];
    [jumpCheck setEnabled:YES];
  }
  [self didChangeValueForKey:@"movesLabelString"];
  [self didChangeValueForKey:@"statusLabelString"];
  [gameView setNeedsDisplay:YES];
}

- (IBAction)pauseGame:(id)sender
{
  [self willChangeValueForKey:@"statusLabelString"];
  
  if (sender != pauseButton) {
    if (gameState == GameRunning)
      gameState = GamePaused;
    [pauseButton setState:1];
  }
  else {
    // Toggle game state
    if (gameState == GameRunning) {
      gameState = GamePaused;
    }
    else if (gameState == GamePaused) {
      gameState = GameRunning;
    }
  }
  
  [self didChangeValueForKey:@"statusLabelString"];
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
