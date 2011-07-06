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


- (id)initWithFrame:(NSRect)frame {
  if (![super initWithFrame:frame]) {
    return nil;
  }
  
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
  [[NSImage imageNamed:@"Board"] drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
  
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
      NSPoint tilePos = NSMakePoint(tile.pos.x-HalfTileSize, tile.pos.y-HalfTileSize);
      [tile.image drawAtPoint:tilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
  }
  activeTiles = [game.goldPlayer activeTiles];
  for (GameTile *tile in activeTiles) {
    if (!tile.active) {
      NSPoint tilePos = NSMakePoint(tile.pos.x-HalfTileSize, tile.pos.y-HalfTileSize);
      [tile.image drawAtPoint:tilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
  }
  activeTiles = [game ghostTileArray];
  for (GameTile *tile in activeTiles) {
    if (!tile.active) {
      NSPoint tilePos = NSMakePoint(tile.pos.x-HalfTileSize, tile.pos.y-HalfTileSize);
      [tile.image drawAtPoint:tilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
  }
  
  // Draw Selected/Dragged Tile
  if (activeTile) {
    NSPoint activeTilePos = NSMakePoint(activeTile.pos.x-HalfTileSize, activeTile.pos.y-HalfTileSize);
    [activeTile.image drawAtPoint:activeTilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
  }
  
  // Draw Messages
}


- (void)mouseDown:(NSEvent *)theEvent
{
  if (game.gameState == GameIdle || game.gameState == GamePaused)
    return;
  
	NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  bool validMove = [game validMove:pointInView];
  if (!validMove)
    return;
  
  mouseDown = YES;
	dragging = NO;
  
  // Find the clicked tile
	activeTile = [[game tileAtPoint:pointInView] retain];
  if (activeTile) {
    [activeTile setOldPos:[activeTile pos]];
    [activeTile setActive:YES];
    
    validDropPositions = [game validTilePositionsFromPoint:[activeTile oldPos]];
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
  
	NSPoint mouseDragPoint = [theEvent locationInWindow];
  NSPoint pointInView = [self convertPoint:mouseDragPoint fromView:nil];
  
  if (!activeTile)
		return;
	dragging = YES;
  
  // Don't drag over view bounds
  if (pointInView.y > NSMaxY([self bounds]) - ViewPadding)
		pointInView.y = NSMaxY([self bounds]) - ViewPadding;
  if (pointInView.y < NSMinY([self bounds]) + ViewPadding)
		pointInView.y = NSMinY([self bounds]) + ViewPadding;
	if (pointInView.x < NSMinX([self bounds]) + ViewPadding)
		pointInView.x = NSMinX([self bounds]) + ViewPadding;
	if (pointInView.x > NSMaxX([self bounds]) - ViewPadding)
		pointInView.x = NSMaxX([self bounds]) - ViewPadding;
  
  // Start dragging the tile
  [activeTile setPos:pointInView];
  
  [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
  if (game.gameState == GameIdle || game.gameState == GamePaused)
    return;
  
  mouseDown = NO;
  if (!activeTile)
    return;
  
  BOOL fromQuarry = NSEqualPoints([activeTile oldPos], NSMakePoint(250, 250));
  
  NSPoint mouseUpPoint = [theEvent locationInWindow];
  NSPoint pointInView = [self convertPoint:mouseUpPoint fromView:nil];
  
  if (dragging) {    
    BOOL validDrop = NO;
    //BOOL validDrop = [game validDrop:pointInView];
    for (NSString *point in validDropPositions) {
      NSPoint pos = NSPointFromString(point);
      NSRect detectionRect = NSMakeRect(pos.x-HalfTileSize, pos.y-HalfTileSize, TileSize, TileSize);
      if (NSPointInRect(pointInView, detectionRect)) {
        // Drop the dragged tile
        [activeTile setPos:pos];
        [activeTile incrementAge];
        [game playerMoved:(fromQuarry ? 0 : 1)];
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
