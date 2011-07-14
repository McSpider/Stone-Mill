//
//  GameView.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import "GameView.h"
#import <QuartzCore/QuartzCore.h>


@implementation GameView
@synthesize viewCenter;
@synthesize boardOpacity;


- (id)initWithFrame:(NSRect)frame {
  if (![super initWithFrame:frame]) {
    return nil;
  }
  
  viewCenter = NSMakePoint(250,250);
  boardOpacity = 0.0f;
  
  return self;
}

- (void)dealloc
{
  [super dealloc];
}


- (void)drawRect:(NSRect)dirtyRect
{
  // Drawing code here.

  // Draw board background
  [[NSImage imageNamed:@"Board"] drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:boardOpacity];
  
  // Draw stone quarry - Only if the player hasn't placed all tiles yet
  if (![game.playingPlayer isSetup] && (game.gameState != GameIdle && game.gameState != GameOver)){
    NSPoint center = NSMakePoint(250-57/2,250-57/2);
    [[NSImage imageNamed:@"Quarry"] drawAtPoint:center fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
  }
  
  // Draw valid location indicators
  if (dragging || mouseDown && activeTile) {
    for (NSString *point in validDropPositions) {
      NSPoint zonePos = NSPointFromString(point);
      zonePos = NSMakePoint(zonePos.x-15/2, zonePos.y-15/2);
      [[NSImage imageNamed:@"Drop Zone"] drawAtPoint:zonePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
  }
  
  // Draw Tiles
  NSArray *activeTiles = [game.bluePlayer activeTiles];
  for (GameTile *tile in activeTiles) {
    if (!tile.active) {
      NSPoint tilePos = NSMakePoint(tile.pos.x-HALF_TILE_SIZE, tile.pos.y-HALF_TILE_SIZE);
      [tile.image drawAtPoint:tilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
  }
  activeTiles = [game.goldPlayer activeTiles];
  for (GameTile *tile in activeTiles) {
    if (!tile.active) {
      NSPoint tilePos = NSMakePoint(tile.pos.x-HALF_TILE_SIZE, tile.pos.y-HALF_TILE_SIZE);
      [tile.image drawAtPoint:tilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
  }
  activeTiles = [game ghostTileArray];
  for (GameTile *tile in activeTiles) {
    if (!tile.active) {
      NSPoint tilePos = NSMakePoint(tile.pos.x-HALF_TILE_SIZE, tile.pos.y-HALF_TILE_SIZE);
      [tile.image drawAtPoint:tilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
  }
  
  // Draw Selected/Dragged Tile
  if (activeTile) {
    NSPoint activeTilePos = NSMakePoint(activeTile.pos.x-HALF_TILE_SIZE, activeTile.pos.y-HALF_TILE_SIZE);
    [activeTile.image drawAtPoint:activeTilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
  }
  
  // Draw Messages
  if ([game gameState] == GamePaused) {
    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.4] set];
    NSRectFillUsingOperation([self bounds], NSCompositeSourceOver);
    
    NSPoint msgPos = NSMakePoint(250-175/2, 250-85/2);
    [[NSImage imageNamed:@"Game_Paused"] drawAtPoint:msgPos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
  }
}


- (void)mouseDown:(NSEvent *)theEvent
{
  if (game.gameState == GameIdle || game.gameState == GamePaused || game.gameState == GameOver)
    return;
  
	NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  bool validMove = [game validMove:pointInView];
  if (!validMove)
    return;
  
  if ([game.playingPlayer state] == 1)
    return;
  
  mouseDown = YES;
	dragging = NO;
  
  // Find the clicked tile
	activeTile = [[game tileAtPoint:pointInView] retain];
  if (activeTile) {
    [activeTile setOldPos:[activeTile pos]];
    [activeTile setActive:YES];
    
    if (![game.playingPlayer tilesCanJump])
      validDropPositions = [game validTilePositionsFromPoint:[activeTile oldPos]];
    else validDropPositions = [game validTilePositions];
    
    // Don't drag ghost tiles or other computer tiles
    if ([activeTile type] != [game.playingPlayer tileType]) {
      mouseDown = NO;
      [activeTile setActive:NO];
      [activeTile release];
      activeTile = nil;
    }
  }

  [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
  if (game.gameState == GameIdle || game.gameState == GamePaused)
    return;
  
  NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  if (!activeTile)
		return;
	dragging = YES;
  
  // Don't drag over view bounds
  if (pointInView.y > NSMaxY([self bounds]) - VIEW_PADDING)
		pointInView.y = NSMaxY([self bounds]) - VIEW_PADDING;
  if (pointInView.y < NSMinY([self bounds]) + VIEW_PADDING)
		pointInView.y = NSMinY([self bounds]) + VIEW_PADDING;
	if (pointInView.x < NSMinX([self bounds]) + VIEW_PADDING)
		pointInView.x = NSMinX([self bounds]) + VIEW_PADDING;
	if (pointInView.x > NSMaxX([self bounds]) - VIEW_PADDING)
		pointInView.x = NSMaxX([self bounds]) - VIEW_PADDING;
  
  // Start dragging the tile
  [activeTile setPos:pointInView];
  
  [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
  if (game.gameState == GameIdle || game.gameState == GamePaused)
    return;
  
  mouseDown = NO;
  
  NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  if ([game.playingPlayer state] == 1) {
    if (![game playerRemoveTileAtPoint:pointInView])
      NSLog(@"Can't remove selected tile!");//[self displayError];
    [self setNeedsDisplay:YES];
    return;
  }

  if (!activeTile)
    return;
      
  if (dragging) {    
    BOOL validDrop = NO;
    for (NSString *point in validDropPositions) {
      NSPoint pos = NSPointFromString(point);
      NSRect detectionRect = NSMakeRect(pos.x-HALF_TILE_SIZE, pos.y-HALF_TILE_SIZE, TILE_SIZE, TILE_SIZE);
      if (NSPointInRect(pointInView, detectionRect)) {
        // Drop the dragged tile
        [activeTile setPos:pos];
        [activeTile incrementAge];
        [game playerMovedFrom:[activeTile oldPos] to:pos];
        validDrop = YES;
        break;
      }
    }
    [validDropPositions release];
    
    // Put it back where it came from
    if (!validDrop)
      [activeTile setPos:[activeTile oldPos]];
  }
    
  [activeTile setActive:NO];
  [activeTile release];
  activeTile = nil;
  
  dragging = NO;
  [self setNeedsDisplay:YES];
}


@end
