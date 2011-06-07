//
//  GameView.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the New BSD license.
//

#import "GameView.h"
#import <QuartzCore/QuartzCore.h>

NSString * const KBStoneMillPasteboardType = @"com.mcspider.millstone";


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
  
  // Draw Tile Pool - Only if the player hasn't placed all tiles yet
  if ([game.humanPlayer placedTileCount] < 9){
    NSPoint center = NSMakePoint(250-57/2,250-57/2);
    [[NSImage imageNamed:@"Pool"] drawAtPoint:center fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    NSPoint tilePos = NSMakePoint(250-HalfTileSize,250-HalfTileSize);
    [[NSImage imageNamed:@"Blue_Inactive"] drawAtPoint:tilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
  }
  
  // Draw valid location indicators
  if (dragging) {
    NSArray *posArray = [game validTilePositionsFromPoint:[activeTile oldPos]];
    for (NSString *string in posArray) {
      NSPoint zonePos = NSPointFromString(string);
      zonePos = NSMakePoint(zonePos.x-15/2, zonePos.y-15/2);
      [[NSImage imageNamed:@"Drop Zone"] drawAtPoint:zonePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
    [posArray release];
  }
  
  // Draw Tiles
  NSArray *activeTiles = [game.humanPlayer activeTiles];
  for (GameTile *tile in activeTiles) {
    if (!tile.active) {
      NSPoint tilePos = NSMakePoint(tile.pos.x-HalfTileSize, tile.pos.y-HalfTileSize);
      [tile.image drawAtPoint:tilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
  }
  activeTiles = [game.robotPlayer activeTiles];
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
}


- (void)mouseMoved:(NSEvent *)theEvent
{
  NSPoint mouseMovePoint = [theEvent locationInWindow];
  NSPoint pointInView = [self convertPoint:mouseMovePoint fromView:nil];
  
  GameTile *nearestTile = [game tileNearestToPoint:pointInView];
  if (!nearestTile)
    return;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	dragging = NO;
  
  // Find the clicked tile
	NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	activeTile = [[game tileAtPoint:pointInView] retain];
  if (activeTile) {
    [activeTile setOldPos:[activeTile pos]];
    [activeTile setActive:YES];
    // Don't drag ghost tiles or other computer tiles
    if ([activeTile type] == GhostTile || [activeTile type] == RobotTile) {
      // Currently the just poof, that is wrong they should stay
      [activeTile setActive:NO];
      [activeTile release];
      activeTile = nil;
    }
  }

  [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint mouseDragPoint = [theEvent locationInWindow];
  NSPoint pointInView = [self convertPoint:mouseDragPoint fromView:nil];
  
  if (!activeTile)
		return;
	
	dragging = YES;
	  		
  // Start dragging the tile
  [activeTile setPos:pointInView];
  
  
  [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
  if (!activeTile)
    return;
  
  NSPoint mouseUpPoint = [theEvent locationInWindow];
  NSPoint pointInView = [self convertPoint:mouseUpPoint fromView:nil];
  
  if (dragging) {
    // Check validitity of position for drop
    NSArray *posArray = [game validTilePositionsFromPoint:[activeTile oldPos]];
    
    BOOL validDrop = NO;
    for (NSString *string in posArray) {
      NSPoint point = NSPointFromString(string);
      NSRect detectionRect = NSMakeRect(point.x-HalfTileSize, point.y-HalfTileSize, TileSize, TileSize);
      if (NSPointInRect(pointInView, detectionRect)) {
        // Drop the dragged tile
        [activeTile setPos:point];
        validDrop = YES;
        break;
      }
    }
    [posArray release];
    
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
