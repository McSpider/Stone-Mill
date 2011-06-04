//
//  GameController.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameController.h"


@implementation GameController


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
  [humanPlayer setColor:Blue];
  
  ///
  GameTile *tile = [[GameTile alloc] init];
  [tile setPos:NSMakePoint(116,116)];
  [tile setType:SMPlayerTile];
  [humanPlayer.activeTiles addObject:tile];
  [tile release];
  ///
  
  robotPlayer = [[GamePlayer alloc] init];
  [robotPlayer setType:RobotPlayer];
  [robotPlayer setColor:Gold];
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
    NSRect tileBounds = NSMakeRect(tile.pos.x, tile.pos.y, 29, 29);
    if (NSPointInRect(point,tileBounds)) {
      return tile;
    }
  }
  activeTiles = [robotPlayer activeTiles];
  for (GameTile *tile in activeTiles) {
    NSRect tileBounds = NSMakeRect(tile.pos.x, tile.pos.y, 29, 29);
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
