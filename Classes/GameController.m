//
//  GameController.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the New BSD license.
//

#import "GameController.h"


@implementation GameController
@synthesize humanPlayer;
@synthesize robotPlayer;
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
  
  /// Temporary active tiles
  GameTile *tile = [[GameTile alloc] init];
  [tile setPos:NSMakePoint(130,130)];
  [tile setType:PlayerTile];
  [humanPlayer.activeTiles addObject:tile];
  [tile release];
  
  tile = [[GameTile alloc] init];
  [tile setPos:NSMakePoint(250,310)];
  [tile setType:PlayerTile];
  [humanPlayer.activeTiles addObject:tile];
  [tile release];
      
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
  ///
  
  // Add tile pool tile
  tile = [[GameTile alloc] init];
  [tile setPos:NSMakePoint(250,250)];
  [tile setType:PlayerTile];
  [robotPlayer.activeTiles addObject:tile];
  [tile release];
    
  return self;
}

- (BOOL)tilesCanJump
{
  return tilesCanJump;
}

- (BOOL)gameIsSetup
{
  if (humanPlayer.isSetup && robotPlayer.isSetup)
    return YES;
  
  return NO;
}

- (NSString*)totalMoves
{
  return [NSString stringWithFormat:@"Moves %i",humanPlayer.moves];
}

- (NSDictionary *)validTilePositions
{
  return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CoordMap" ofType:@"plist"]];
  
//  NSString *tiles = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TileMap" ofType:@"csv"]
//                                              encoding:NSUTF8StringEncoding
//                                                 error:nil];
//  
//  NSArray *tilePositions = [tiles componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
//  NSMutableArray *tilePositionArray = [[NSMutableArray alloc] init];
//  
//  for (NSString *position in tilePositions) {
//    if (![position isEqualToString:@""]) //ignore empty lines
//      [tilePositionArray addObject:position];
//  }
//  return tilePositionArray;
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
  // Return an dictionary consisting of the tile positions that can be moved to from the specified position
  NSDictionary *tilePositions = [[self validTilePositions] objectForKey:[NSString stringWithFormat:@"%i, %i",(int)point.x,(int)point.y]];
  NSMutableDictionary *positions = [[NSMutableDictionary alloc] init];
  for (NSString *string in tilePositions) {
    if ([self tileAtPoint:NSPointFromString(string)])
      continue;
    [positions setObject:string forKey:string];
  }

  return positions; //returns all spots that are empty and valid
}


- (void)playerMoved:(int)moveType;
{
  NSLog(@"Game state: %i",gameState);
  [self willChangeValueForKey:@"totalMoves"];
  humanPlayer.moves += 1;
	[self didChangeValueForKey:@"totalMoves"];
  
  if (!humanPlayer.isSetup && ![self tileAtPoint:NSMakePoint(250,250)]) {
    if (humanPlayer.placedTileCount != 9)
      humanPlayer.placedTileCount += 1;
    
    // Add tile to tile pool
    GameTile *tile = [[GameTile alloc] init];
    [tile setPos:NSMakePoint(250,250)];
    [tile setType:PlayerTile];
    [robotPlayer.activeTiles addObject:tile];
    [tile release];
  }
}

- (void)playerFinishedMoving
{
  
}


@end
