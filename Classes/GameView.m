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

- (void)initGameBoard
{  
  CALayer *layer = [CALayer layer];
	layer.bounds = NSRectToCGRect(self.bounds);
	layer.anchorPoint = CGPointZero;
	layer.position = CGPointZero;
  layer.contents = [NSImage imageNamed:@"Board"];
	
	[self setLayer:layer];
	[self setWantsLayer:YES];
  
	// reset the layers
	for (CALayer *layer in self.layer.sublayers) {
		[layer removeFromSuperlayer];
	}
	
  NSArray *validTilePositions = [game validTilePositions];
  for (NSString *position in validTilePositions) {
    NSArray *positionArray = [position componentsSeparatedByString:@","];
    int xPos = [[positionArray objectAtIndex:0] integerValue];
    int yPos = [[positionArray objectAtIndex:1] integerValue];
    
    CALayer *subLayer = [CALayer layer];
    subLayer.anchorPoint = CGPointZero;
    subLayer.position = CGPointMake(xPos,yPos);
    subLayer.bounds = CGRectMake(0, 0, 29, 29);    
    //subLayer.contents = [NSImage imageNamed:@"Ghost Stone"];
    //subLayer.opacity = 0.5;
    
    [self.layer addSublayer:subLayer];
  }
  
  CALayer *subLayer = [CALayer layer];
  subLayer.anchorPoint = CGPointZero;
  subLayer.position = CGPointMake(236,236);
  subLayer.bounds = CGRectMake(0, 0, 29, 29);    
  subLayer.contents = [NSImage imageNamed:@"Blue Stone"];
  [self.layer addSublayer:subLayer];
  
  [validTilePositions release];
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
	
	dragging = YES;
	
	if (!clickedTile)
		return;
  		
  // Start dragging the tile
	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	[pasteboard declareTypes:[NSArray arrayWithObjects:KBStoneMillPasteboardType, nil] owner:nil];
	[pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:clickedTile] forType:KBStoneMillPasteboardType];
	
	NSImage *image = clickedTile.image;
	
	// Remove tile from playing board
	
  // Drag tile to different location
	NSPoint dragPoint = NSMakePoint(pointInView.x - image.size.width*0.5, pointInView.y - image.size.height*0.5);
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
