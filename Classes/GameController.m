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
@synthesize moveRate;
@synthesize timeLabelString, gameTimer, gameStart;


#pragma mark -
#pragma mark Initialization

- (id)init
{
  if (![super init]) {
    return nil;
  }
  [self setGameState:GameIdle];
  
  bluePlayer = [[GamePlayer alloc] initWithType:HumanPlayer andColor:BluePlayer];
  goldPlayer = [[GamePlayer alloc] initWithType:RobotPlayer andColor:GoldPlayer];
  ghostTileArray = [[NSMutableArray alloc] init];
  boardPrefix = [[NSString alloc] initWithString:@"Mobius"];
  moveRate = 0.1;
  
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
  CALayer *gridLayer = [[gameView.boardLayer sublayers] objectAtIndex:0];
  gridLayer.contents = [NSImage imageNamed:[NSString stringWithFormat:@"%@_Mill",self.boardPrefix]];
    
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


#pragma mark -
#pragma mark Functions

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

- (NSArray *)activeTilePositions
{
  NSMutableArray *tileArray = [NSMutableArray arrayWithArray:[goldPlayer activeTiles]];
  [tileArray addObjectsFromArray:[bluePlayer activeTiles]];
  [tileArray addObjectsFromArray:ghostTileArray];
  return [NSArray arrayWithArray:tileArray];
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

- (NSDictionary *)allTilePositionsFromPoint:(NSPoint)point player:(GamePlayer *)thePlayer
{
  NSDictionary *tilePositions;
  NSMutableDictionary *positions = [[NSMutableDictionary alloc] init];
  BOOL fromStoneQuarry = NSEqualPoints(point, gameView.viewCenter);
  
  // Return an dictionary consisting of the tile positions that can be moved to from the specified position
  if (fromStoneQuarry || ([thePlayer tilesCanJump] && [jumpCheck state]))
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

- (NSDictionary *)playerTilePositionsFromPoint:(NSPoint)point player:(GamePlayer *)thePlayer;
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

// Should return an angle (in degrees) relative to the zero axis
- (int)offsetDirectionFromPoint:(NSPoint)fromPos toPoint:(NSPoint)toPos
{
  return atan2f(toPos.y-fromPos.y,toPos.x-fromPos.x) * 180 / 3.14;
}

- (int)oppositeOffsetDirection:(int)offsetDir
{
  return ((offsetDir + 180) % 360);
}


// Semi works now :/
- (NSArray *)closableMillsForPlayer:(GamePlayer *)thePlayer
{
  NSMutableArray *closableMills1 = [[NSMutableArray alloc] init];
  // Return all mills that can be closed by thePlayer, does not return blocked ones
  
	// Try to build a row of 2 stones and one blank
  for (GameTile *aTile in thePlayer.activeTiles) {
    NSString * stoneOne = NSStringFromPoint(aTile.pos);
    NSString * stoneTwo = nil;
    NSString * keyStone = nil; // The location that would/could close the mill
		    
		NSDictionary *tilePositions2 = [[self validTilePositions] objectForKey:[NSString stringWithFormat:@"%i, %i",(int)aTile.pos.x,(int)aTile.pos.y]];
		for (NSString *thePos2 in tilePositions2) {
			// Store direction we are moving
			int direction1 = [self offsetDirectionFromPoint:aTile.pos toPoint:NSPointFromString(thePos2)];

			if ([self tileAtPoint:NSPointFromString(thePos2)]) {
				// We have a tile, check if the 3rd position is empty
				stoneTwo = thePos2;
								
				NSDictionary *tilePositions3 = [[self validTilePositions] objectForKey:thePos2];
				for (NSString *thePos3 in tilePositions3) {
					int direction2 = [self offsetDirectionFromPoint:NSPointFromString(thePos2) toPoint:NSPointFromString(thePos3)];
					if (direction2 != direction1)
						continue;
					
					if (![self tileAtPoint:NSPointFromString(thePos3)]) {
						keyStone = thePos3;
					}
				}
			}
			else {
				// We don't have a tile, check if the 3rd position is one		
				NSDictionary *tilePositions3 = [self playerTilePositionsFromPoint:NSPointFromString(thePos2) player:thePlayer];
				for (NSString *thePos3 in tilePositions3) {
					int direction2 = [self offsetDirectionFromPoint:NSPointFromString(thePos2) toPoint:NSPointFromString(thePos3)];
					if (direction2 != direction1)
						continue;
					
					stoneTwo = thePos3;
					keyStone = thePos2;
				}
			}
      if (stoneOne != nil && stoneTwo != nil && keyStone != nil) {
				[closableMills1 addObject:[NSArray arrayWithObjects:stoneOne, stoneTwo, keyStone, nil]];
      } else {
        // Didn't find a full match, reset values
				stoneOne = nil;
        stoneTwo = nil;
        keyStone = nil;
			}
    }
  }
  
	NSMutableArray *closableMills2 = [[NSMutableArray alloc] init];
	// Remove all duplicates (And shift filtered mills into closableMills2)
	for (NSArray *aArray in closableMills1) {
		// Fill Me
	}
	
	NSMutableArray *closableMills = [[NSMutableArray alloc] init];
  // Reparse array to return Stone and Position
  for (NSArray *halfMill in closableMills1) {
		NSString *stone = [halfMill objectAtIndex:2];
		NSDictionary *positions = [self playerTilePositionsFromPoint:NSPointFromString(stone) player:thePlayer];
		for (NSString *position in positions) {
			if (NSEqualPoints(NSPointFromString(position), NSPointFromString([halfMill objectAtIndex:0])) ||
					NSEqualPoints(NSPointFromString(position), NSPointFromString([halfMill objectAtIndex:1]))) {
				continue;
			}
			NSLog(@"Stone: %@", stone); // Move to
			NSLog(@"Position: %@", position); // Move from
			
			// Contains Stone, Pos and Mill data (Move Stone to Pos)
			[closableMills addObject:[NSArray arrayWithObjects:stone, position, halfMill, nil]];
		}

	}
  
  // Return results
	[closableMills1 release];
	[closableMills2 release];
  return [closableMills autorelease];	
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
    if ([thePlayer type] != RobotPlayer) if (![muteButton state]) [errorSound play];
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
    if ([thePlayer type] != RobotPlayer) if (![muteButton state]) [errorSound play];
    return NO;
  }
  
  // Remove Tile
  if (aTile.type == BlueTile)
    [bluePlayer.activeTiles removeObject:aTile];
  else if (aTile.type == GoldTile)
    [goldPlayer.activeTiles removeObject:aTile];
  
  if (![muteButton state]) [removeSound play];
  
  [thePlayer setState:0];
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
    if (![muteButton state]) [closeSound play];
    [playingPlayer setState:1];
    [self removeOldGhosts];
    
    if (playingPlayer.type == RobotPlayer)
      [self performSelector:@selector(moveForPlayer:) withObject:playingPlayer afterDelay:moveRate];
    return;
  }

  if (![muteButton state]) [moveSound play];
  [self playerFinishedMoving];
}

- (BOOL)isMill:(NSPoint)aPoint player:(GamePlayer *)thePlayer;
{
  BOOL stone1 = NO; // First Stone, always returns YES if there's an adjacent stone to the starting position X O
  BOOL stone2 = NO; // Second Stone, returns true if there's a stone adjacent and in the same direction as the second position X O 0
  BOOL stone3 = NO; // Third Stone, returns true if there's a stone adjacent and in the opposite direction as starting position 0 X O
  
  // Try to build a row of 3 stones which include our starting position
  NSDictionary *tilePositions1 = [self playerTilePositionsFromPoint:aPoint player:thePlayer];
  for (NSString *thePos1 in tilePositions1) {
    // Store direction we are moving
    int direction1 = [self offsetDirectionFromPoint:aPoint toPoint:NSPointFromString(thePos1)];
    stone1 = YES;
    
    // We are moving a certain direction now keep going that way
    NSDictionary *tilePositions2 = [self playerTilePositionsFromPoint:NSPointFromString(thePos1) player:thePlayer];
    for (NSString *thePos2 in tilePositions2) {
      int direction2 = [self offsetDirectionFromPoint:NSPointFromString(thePos1) toPoint:NSPointFromString(thePos2)];
      if (direction2 != direction1)
        continue;
      stone2 = YES;
      break;
    }
    // Also try going the opposite direction from the original position
    for (NSString *thePos1 in tilePositions1) {
      int direction2 = [self offsetDirectionFromPoint:aPoint toPoint:NSPointFromString(thePos1)];
      if (direction2 != [self oppositeOffsetDirection:direction1])
        continue;
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
    [self performSelector:@selector(moveForPlayer:) withObject:playingPlayer afterDelay:moveRate];
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
    if ([[self allTilePositionsFromPoint:aTile.pos player:thePlayer] count] > 0) {
      canMove = YES;
    }
  }
  // Check if the player could move from the quarry
  if (!thePlayer.isSetup && !canMove)
    if ([[self allTilePositionsFromPoint:gameView.viewCenter player:thePlayer] count] > 0)
      canMove = YES;
  
  // Check if the player can jump and there are empty spots
  if (thePlayer.tilesCanJump && [jumpCheck state])
    if ([[self validTilePositions] count] > 0)
      canMove = YES;

  return canMove;
}

- (void)moveForPlayer:(GamePlayer *)thePlayer
{
  if (gameState == GamePaused)
    return;
  
	// get the opponent players closeable mills
  GamePlayer *opponentPlayer = ((thePlayer == bluePlayer)?goldPlayer:bluePlayer);
	NSArray *blockableMills = [[self closableMillsForPlayer:opponentPlayer] copy];
	
  if (thePlayer.state == 0) {
		// get all the mills we can close
		NSArray *closableMills = [[self closableMillsForPlayer:playingPlayer] copy];
		NSLog(@"Closable Mills:\n%@",closableMills);
    
    // get all the tiles we can move
    if (![thePlayer isSetup]) {
			if ([closableMills count] != 0 && [self randomProbability:thePlayer.smartness]) {
				// Close a random closable mill
				GameTile *aTile = [self tileAtPoint:gameView.viewCenter];
				if (aTile) {
					[aTile setOldPos:[aTile pos]];
					[aTile setPos:NSPointFromString([[closableMills objectAtIndex:(arc4random() % [closableMills count])] objectAtIndex:0])];
					[self playerMovedFrom:[aTile oldPos] to:[aTile pos]];
				}
			}
			else if ([blockableMills count] != 0 && [self randomProbability:thePlayer.smartness]) {
				// Block a random blockable mill
				GameTile *aTile = [self tileAtPoint:gameView.viewCenter];
				if (aTile) {
					[aTile setOldPos:[aTile pos]];
					[aTile setPos:NSPointFromString([[blockableMills objectAtIndex:(arc4random() % [blockableMills count])] objectAtIndex:0])];
					[self playerMovedFrom:[aTile oldPos] to:[aTile pos]];
				}
			}
			else {
				// Move a random stone
				NSDictionary *validMoves = [self allTilePositionsFromPoint:gameView.viewCenter player:thePlayer];
				GameTile *aTile = [self tileAtPoint:gameView.viewCenter];
				if (aTile && validMoves != 0) {
					[aTile setOldPos:[aTile pos]];
					[aTile setPos:NSPointFromString([[validMoves allValues] objectAtIndex:(arc4random() % [validMoves count])])];
					[self playerMovedFrom:[aTile oldPos] to:[aTile pos]];
				}
			}
    }
    else {
			if ([closableMills count] != 0 && [self randomProbability:thePlayer.smartness]) {
				// Close a random closable mill
				NSArray *moveData = [closableMills objectAtIndex:(arc4random() % [closableMills count])];
				GameTile *aTile = [self tileAtPoint:NSPointFromString([moveData objectAtIndex:1])];
				NSPoint moveTo = NSPointFromString([moveData objectAtIndex:0]);
				[aTile setOldPos:[aTile pos]];
				[aTile setPos:moveTo];
				[self playerMovedFrom:[aTile oldPos] to:[aTile pos]];
			}
			else if ([blockableMills count] != 0 && [self randomProbability:thePlayer.smartness]) {
				// Block a random blockable mill (if possible)
				//for (NSArray *aArray in blockableMills) {
				//	NSDictionary *possibleMoves = [self playerTilePositionsFromPoint:NSPointFromString([aArray objectAtIndex:1]) player:thePlayer];
				//}
				// Block a random blockable mill
				NSArray *moveData = [blockableMills objectAtIndex:(arc4random() % [blockableMills count])];
				GameTile *aTile = [self tileAtPoint:NSPointFromString([moveData objectAtIndex:1])];
				NSPoint moveTo = NSPointFromString([moveData objectAtIndex:0]);
				[aTile setOldPos:[aTile pos]];
				[aTile setPos:moveTo];
				[self playerMovedFrom:[aTile oldPos] to:[aTile pos]];
			}
			else {
				// Move a random stone
	      NSMutableArray *moves = [[NSMutableArray alloc] init];
				for (GameTile *aTile in thePlayer.activeTiles) {
					NSDictionary *validMoves = [self allTilePositionsFromPoint:[aTile pos] player:thePlayer];
					if (validMoves && [validMoves count] != 0) {
						[moves addObject:[NSArray arrayWithObjects:aTile, validMoves, nil]];          
					}
				}
				
				if ([moves count] > 0){
					NSArray *moveData = [moves objectAtIndex:(arc4random() % [moves count])];
					GameTile *aTile = [moveData objectAtIndex:0];
					NSDictionary *validMoves = [moveData objectAtIndex:1];
					[aTile setOldPos:[aTile pos]];
					[aTile setPos:NSPointFromString([[validMoves allValues] objectAtIndex:(arc4random() % [validMoves count])])];
					[self playerMovedFrom:[aTile oldPos] to:[aTile pos]];
				}
				[moves release];
			}
    }
		[closableMills release];
  }
  else if (thePlayer.state == 1) {
		//if ([blockableMills count] != 0 && [self randomProbability:thePlayer.smartness]) {
    // Destroy random oponents closable mill
		//}
		//else {
    // Remove a random stone
    GamePlayer *aPlayer = ((thePlayer == bluePlayer)?goldPlayer:bluePlayer);
    BOOL tileRemoved = NO;
    while (tileRemoved != YES) {
      GameTile *aTile = [aPlayer.activeTiles objectAtIndex:(arc4random() % [aPlayer.activeTiles count])];
      if ([self removeTileAtPoint:aTile.pos player:thePlayer])
        tileRemoved = YES;
    }
		//}
  }
	[blockableMills release];
	
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

// Input a percentage probablilty outputs YES or NO
- (BOOL)randomProbability:(int)input
{
	if (((arc4random() % 99) + 1) <= input)
		return YES;
	return NO;
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
    [playersCheck setEnabled:NO];
    
    playingPlayer = bluePlayer;
    
    // Set the player types
    if ([playersCheck state] == NSOffState) {
      [bluePlayer setType:RobotPlayer];
      [goldPlayer setType:RobotPlayer];
    }
    else if ([playersCheck state] == NSMixedState) {
      [bluePlayer setType:HumanPlayer];
      [goldPlayer setType:RobotPlayer];
    }
    else {
      [bluePlayer setType:HumanPlayer];
      [goldPlayer setType:HumanPlayer];
    }
    
    [self setGameState:GameRunning];
    
    // Add stone quarry
    GameTile *tile = [[GameTile alloc] init];  
    [tile setPos:gameView.viewCenter];
    [tile setType:BlueTile];
    [playingPlayer.activeTiles addObject:tile];
    [tile release];
    
    self.gameStart = [NSDate date];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(updateTimer)
                                                    userInfo:nil
                                                      repeats:TRUE];
    // If the starting player is a robot move
    if (playingPlayer.type == RobotPlayer)
      [self performSelector:@selector(moveForPlayer:) withObject:playingPlayer afterDelay:moveRate];
  }
  else if (gameState == GameRunning || gameState == GamePaused || gameState == GameOver) {
    [self setGameState:GameIdle];
    [gameButton setTitle:@"New Game"];
    [selectorPopup setEnabled:YES];
    [pauseButton setEnabled:NO];
    [pauseButton setTransparent:YES];
    [ghostCheck setEnabled:YES];
    [jumpCheck setEnabled:YES];
    [playersCheck setEnabled:YES];
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
      
      // If the active player is a robot move
      if (playingPlayer.type == RobotPlayer)
        [self performSelector:@selector(moveForPlayer:) withObject:playingPlayer afterDelay:moveRate];
    }
  }  
  [gameView setNeedsDisplay:YES];
}

- (IBAction)changeBoard:(id)sender
{
  NSArray *boardNames = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Boards" ofType:@"plist"]];
  self.boardPrefix = [boardNames objectAtIndex:[sender indexOfSelectedItem]];
  CALayer *gridLayer = [[gameView.boardLayer sublayers] objectAtIndex:0];
  gridLayer.contents = [NSImage imageNamed:[NSString stringWithFormat:@"%@_Mill",self.boardPrefix]];
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
