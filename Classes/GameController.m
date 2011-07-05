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
@synthesize humanPlayer, robotPlayer, playingPlayer;
@synthesize gameState, playingState;


- (id)init
{
  if (![super init]) {
    return nil;
  }
  tilesCanJump = YES;
  ghostTiles = YES;
  gameState = GameIdle;
  
  humanPlayer = [[GamePlayer alloc] init];
  [humanPlayer setType:HumanPlayer];
  
  robotPlayer = [[GamePlayer alloc] init];
  [robotPlayer setType:RobotPlayer];
    
  return self;
}

- (void)dealloc
{
  [humanPlayer release];
  [robotPlayer release];
  [super dealloc];
}


- (BOOL)tilesCanJump
{
  return tilesCanJump;
}

- (BOOL)isGameSetup
{
  if (humanPlayer.isSetup && robotPlayer.isSetup)
    return YES;
  
  return NO;
}

- (NSString*)movesLabelString
{
  return [NSString stringWithFormat:@"Moves %i",humanPlayer.moves];
}

- (NSString*)timeLabelString
{
  return [NSString stringWithFormat:@"Time 00:00"];
}

- (NSString*)statusLabelString
{
  if (gameState == GameIdle)
    return @"Game Idle";
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
  // Untested
  NSArray *activeTiles = [humanPlayer activeTiles];
  for (GameTile *tile in activeTiles) {
    NSRect tileBounds = NSMakeRect(tile.pos.x-HalfTileSize, tile.pos.y-HalfTileSize, TileSize, TileSize);
    if (NSPointInRect(point,tileBounds)) {
      return tile;
    }
  }
  activeTiles = [robotPlayer activeTiles];
  for (GameTile *tile in activeTiles) {
    NSRect tileBounds = NSMakeRect(tile.pos.x-HalfTileSize, tile.pos.y-HalfTileSize, TileSize, TileSize);
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
  BOOL fromStoneQuarry = NSEqualPoints(point, NSMakePoint(250,250));
  
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
    NSRect quarry = NSMakeRect(250-HalfTileSize, 250-HalfTileSize, TileSize, TileSize);
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


- (void)playerMoved:(int)moveType;
{
  [self willChangeValueForKey:@"movesLabelString"];
  humanPlayer.moves += 1;
	[self didChangeValueForKey:@"movesLabelString"];
  
  if (humanPlayer.placedTileCount < 9 && moveType == 0)
    humanPlayer.placedTileCount += 1;
  
  if (!humanPlayer.isSetup && ![self tileAtPoint:NSMakePoint(250,250)]) {
    // Replace stone quarry stone
    GameTile *tile = [[GameTile alloc] init];
    [tile setPos:NSMakePoint(250,250)];
    [tile setType:PlayerTile];
    [robotPlayer.activeTiles addObject:tile];
    [tile release];
  }
  
  NSSound *popSound = [NSSound soundNamed:@"Pop"];
	[popSound play];
}

- (void)playerFinishedMoving
{
  
}

- (void)addTemporaryStones
{
  /// Temporary active tiles
  GameTile *tile = [[GameTile alloc] init];  
  tile = [[GameTile alloc] init];
  [tile setPos:NSMakePoint(130,250)];
  [tile setType:RobotTile];
  [robotPlayer.activeTiles addObject:tile];
  [tile release];
  
  tile = [[GameTile alloc] init];
  [tile setPos:NSMakePoint(310,310)];
  [tile setType:GhostTile];
  [robotPlayer.activeTiles addObject:tile];
  [tile release];
}


#pragma mark -
#pragma mark Actions

- (IBAction)newGame:(id)sender
{
  [self willChangeValueForKey:@"statusLabelString"];
  if (gameState != GamePaused && (gameState == GameIdle || gameState == GameOver)) {
    gameState = GameRunning;
    [gameButton setTitle:@"End Game"];
    [pauseButton setEnabled:YES];
    [ghostCheck setEnabled:NO];
    [jumpCheck setEnabled:NO];
    
    playingPlayer = humanPlayer;
    
    // Add stone quarry
    GameTile *tile = [[GameTile alloc] init];  
    [tile setPos:NSMakePoint(250,250)];
    [tile setType:PlayerTile];
    [robotPlayer.activeTiles addObject:tile];
    [tile release];
    
    [self addTemporaryStones];
  }
  else if (gameState == GameRunning || gameState == GamePaused) {
    gameState = GameOver;
    [gameButton setTitle:@"Start Game"];
    [pauseButton setTitle:@"Pause"];
    [pauseButton setEnabled:NO];
    [ghostCheck setEnabled:YES];
    [jumpCheck setEnabled:YES];
    
    [robotPlayer.activeTiles removeAllObjects];
    [humanPlayer.activeTiles removeAllObjects];
  }
  [self didChangeValueForKey:@"statusLabelString"];
  [gameView setNeedsDisplay:YES];
}

- (IBAction)pauseGame:(id)sender
{
  [self willChangeValueForKey:@"statusLabelString"];
  if (gameState == GameRunning) {
    gameState = GamePaused;
    [pauseButton setTitle:@"Resume"];
  }
  else if (gameState == GamePaused) {
    gameState = GameRunning;
    [pauseButton setTitle:@"Pause"];
  }
  [self didChangeValueForKey:@"statusLabelString"];
  [gameView setNeedsDisplay:YES];
}


@end
