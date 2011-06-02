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
  NSString *tiles = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TileMap" ofType:@"csv"]
                                             encoding:NSUTF8StringEncoding
                                                error:nil];

  NSArray *tilePositionArray = [tiles componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  
  CALayer *layer = [CALayer layer];
	layer.bounds = NSRectToCGRect(self.bounds);
	layer.anchorPoint = CGPointZero;
	layer.position = CGPointZero; //CGPointMake(NSMidX(self.bounds), NSMidY(self.bounds));
  layer.contents = [NSImage imageNamed:@"Board"];
	
	[self setLayer:layer];
	[self setWantsLayer:YES];
  
	// reset the layers
	for (CALayer *layer in self.layer.sublayers) {
		[layer removeFromSuperlayer];
	}
	
  for (NSString *position in tilePositionArray) {
    if ([position isEqualToString:@""])
      continue;
    NSArray *positionArray = [position componentsSeparatedByString:@","];
    NSLog(@"%@",positionArray);
    int xPos = [[positionArray objectAtIndex:0] integerValue];
    int yPos = [[positionArray objectAtIndex:1] integerValue];
    
    CALayer *subLayer = [CALayer layer];
    subLayer.anchorPoint = CGPointZero;
    subLayer.position = CGPointMake(xPos,yPos);
    subLayer.bounds = CGRectMake(0, 0, 29, 29);
    subLayer.contents = [NSImage imageNamed:@"Ghost Stone"];
    
    [self.layer addSublayer:subLayer];     
  }
}

- (GameTile *)tileAtPoint:(NSPoint)point
{
  return nil;
}




- (void)mouseDown:(NSEvent *)theEvent
{
	[theEvent retain];
	[mouseDownEvent release];
	mouseDownEvent = theEvent;
	dragging = NO;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint mouseDownPoint = [mouseDownEvent locationInWindow];
	NSPoint mouseDragPoint = [theEvent locationInWindow];
	float dragDistance = hypot(mouseDownPoint.x - mouseDragPoint.x, mouseDownPoint.y - mouseDragPoint.y);
	if (dragDistance < 3)
		return;
	
	dragging = YES;
	
	// Find the clicked tile
	NSPoint pointInView = [self convertPoint:mouseDownPoint fromView:nil];
	GameTile *tile = [self tileAtPoint:pointInView];
	if (!tile)
		return;
		
	NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	[pasteboard declareTypes:[NSArray arrayWithObjects:KBStoneMillPasteboardType, nil] owner:nil];
	[pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:tile] forType:KBStoneMillPasteboardType];
	
	NSImage *image = tile.image;
	
	// Remove tile from playing board
	
	NSPoint dragPoint = NSMakePoint(pointInView.x - image.size.width*0.5, pointInView.y - image.size.height*0.5);
	
	[self dragImage:image
               at:dragPoint
           offset:NSZeroSize
            event:mouseDownEvent
       pasteboard:pasteboard
           source:self
        slideBack:NO];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if (!dragging) {
		NSPoint mouseDownPoint = [mouseDownEvent locationInWindow];
		NSPoint pointInView = [self convertPoint:mouseDownPoint fromView:nil];
		
    GameTile *tile = [self tileAtPoint:pointInView];
		//[delegate inventoryView:self selectedItemAtIndex:itemIndex];
	}
}


@end
