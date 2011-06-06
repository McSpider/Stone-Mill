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
  
  //Draw board background
  [[NSImage imageNamed:@"Board"] drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
  
//  NSArray *validTilePositions = [game validTilePositions];
//  for (NSString *position in validTilePositions) {
//    NSArray *positionArray = [position componentsSeparatedByString:@","];
//    int xPos = [[positionArray objectAtIndex:0] integerValue];
//    int yPos = [[positionArray objectAtIndex:1] integerValue];
//    
//    NSPoint tilePos = NSMakePoint(xPos-TileSize/2, yPos-TileSize/2);
//    [[NSImage imageNamed:@"Ghost Stone"] drawAtPoint:tilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];    
//  }
//  [validTilePositions release];

  
  // Draw Active Tiles
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
  
  // Draw Tile Pool - Only if the player hasn't placed all tiles yet
  if (![game.humanPlayer placedTileCount] >= 9){
    NSPoint tilePos = NSMakePoint(250-TileSize/2,250-TileSize/2);
    [[NSImage imageNamed:@"Blue_Inactive"] drawAtPoint:tilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
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
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint mouseDownPoint = [mouseDownEvent locationInWindow];
  NSPoint pointInView = [self convertPoint:[mouseDownEvent locationInWindow] fromView:nil];
	NSPoint mouseDragPoint = [theEvent locationInWindow];
	float dragDistance = hypot(mouseDownPoint.x - mouseDragPoint.x, mouseDownPoint.y - mouseDragPoint.y);
	if (dragDistance < 0)
		return;
  
  if (!clickedTile)
		return;
  [clickedTile setActive:YES];
	
	dragging = YES;
	  		
  // Start dragging the tile
	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	[pasteboard declareTypes:[NSArray arrayWithObjects:KBStoneMillPasteboardType, nil] owner:nil];
	[pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:clickedTile] forType:KBStoneMillPasteboardType];
	
	NSImage *image = clickedTile.image;
	
	// Remove tile from playing board
	
  // Drag tile to different location
	NSPoint dragPoint = NSMakePoint(pointInView.x - TileSize*0.5, pointInView.y - TileSize*0.5);
	[self dragImage:image
               at:dragPoint
           offset:NSZeroSize
            event:mouseDownEvent
       pasteboard:pasteboard
           source:self
        slideBack:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if (dragging) {
		NSPoint mouseDownPoint = [mouseDownEvent locationInWindow];
		NSPoint pointInView = [self convertPoint:mouseDownPoint fromView:nil];
		
    GameTile *tile = [game tileAtPoint:pointInView];
    if (!tile)
      return;
    
    // Drop the dragged tile
	}
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation
{

}



@end
