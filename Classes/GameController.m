//
//  GameController.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameController.h"


@implementation GameController
@synthesize humanPlayer;
@synthesize robotPlayer;


- (id)init
{
  if (![super init]) {
    return nil;
  }
  tilesCanJump = YES;
  ghostTiles = YES;
  gameIsRunning = NO;
  gameIsSetup = NO;
  
  humanPlayer = [[GamePlayer alloc] init];
  [humanPlayer setType:HumanPlayer];
  
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
  ///
    
  robotPlayer = [[GamePlayer alloc] init];
  [robotPlayer setType:RobotPlayer];
  
  /// Temporary active tiles
  tile = [[GameTile alloc] init];
  [tile setPos:NSMakePoint(130,250)];
  [tile setType:RobotTile];
  [robotPlayer.activeTiles addObject:tile];
  [tile release];
  ///
  
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

- (NSArray *)validTilePositions
{
  NSString *tiles = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TileMap" ofType:@"csv"]
                                              encoding:NSUTF8StringEncoding
                                                 error:nil];
  
  NSArray *tilePositions = [tiles componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  NSMutableArray *tilePositionArray = [[NSMutableArray alloc] init];
  
  for (NSString *position in tilePositions) {
    if (![position isEqualToString:@""]) //ignore empty lines
      [tilePositionArray addObject:position];
  }
  return tilePositionArray;
}

- (GameTile *)tileAtPoint:(NSPoint)point
{
  // Untested
  NSArray *activeTiles = [humanPlayer activeTiles];
  for (GameTile *tile in activeTiles) {
    NSRect tileBounds = NSMakeRect(tile.pos.x-TileSize/2, tile.pos.y-TileSize/2, TileSize, TileSize);
    if (NSPointInRect(point,tileBounds)) {
      return tile;
    }
  }
  activeTiles = [robotPlayer activeTiles];
  for (GameTile *tile in activeTiles) {
    NSRect tileBounds = NSMakeRect(tile.pos.x-TileSize/2, tile.pos.y-TileSize/2, TileSize, TileSize);
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



@end
