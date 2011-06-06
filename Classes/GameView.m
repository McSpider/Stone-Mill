//
//  GameView.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
    NSPoint tilePos = NSMakePoint(250-TileSize/2,250-TileSize/2);
    [[NSImage imageNamed:@"Blue_Inactive"] drawAtPoint:tilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
  } 
  
  // Draw Tiles
  NSArray *activeTiles = [game.humanPlayer activeTiles];
  for (GameTile *tile in activeTiles) {
    NSPoint tilePos = NSMakePoint(tile.pos.x-TileSize/2, tile.pos.y-TileSize/2);
    [tile.image drawAtPoint:tilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];    
  }
  activeTiles = [game.robotPlayer activeTiles];
  for (GameTile *tile in activeTiles) {
    NSPoint tilePos = NSMakePoint(tile.pos.x-TileSize/2, tile.pos.y-TileSize/2);
    [tile.image drawAtPoint:tilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];    
  }
  
  // Draw Selected/Dragged Tile
  
  // Draw valid location indicators
  if (dragging) {
    
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
	[theEvent retain];
	[mouseDownEvent release];
	mouseDownEvent = theEvent;
	dragging = NO;
  
  // Find the clicked tile
	NSPoint pointInView = [self convertPoint:[mouseDownEvent locationInWindow] fromView:nil];
  [clickedTile release];
	clickedTile = [[game tileAtPoint:pointInView] retain];
  [clickedTile setOldPos:[clickedTile pos]];
  [clickedTile setActive:YES];
  if ([clickedTile type] == GhostTile)
    clickedTile = nil;

  [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint mouseDownPoint = [mouseDownEvent locationInWindow];
	NSPoint mouseDragPoint = [theEvent locationInWindow];
  NSPoint pointInView = [self convertPoint:mouseDragPoint fromView:nil];
	float dragDistance = hypot(mouseDownPoint.x - mouseDragPoint.x, mouseDownPoint.y - mouseDragPoint.y);
	if (dragDistance < 0)
		return;
  
  if (!clickedTile)
		return;
	
	dragging = YES;
	  		
  // Start dragging the tile
  [clickedTile setPos:pointInView];
  
  
  [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
  if (!clickedTile)
    return;
  
  NSPoint mouseUpPoint = [theEvent locationInWindow];
  NSPoint pointInView = [self convertPoint:mouseUpPoint fromView:nil];
  
  [clickedTile setActive:NO];
  if (dragging) {
    // Check validitity of position for drop
    NSArray *posArray = [[game validTilePositionsFromPoint:[clickedTile oldPos]] retain];
    NSLog(@"%@",posArray);
    int index;
    for (index = 0; index < [posArray count]; index++) {
      NSPoint point = NSPointFromString([posArray objectAtIndex:index]);
      NSRect detectionRect = NSMakeRect(point.x-TileSize/2, point.y-TileSize/2, TileSize, TileSize);
      if (NSPointInRect(pointInView, detectionRect)) {
        // Drop the dragged tile
        [clickedTile setPos:point];
        [posArray release];
        [self display];
        return;
      }
    }
    [posArray release];
    
    // Put it back where it came from
    [clickedTile setPos:[clickedTile oldPos]];
  }
  
  [self setNeedsDisplay:YES];
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation
{

}



@end
