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
@synthesize boardLayer, messageLayer;


- (id)initWithFrame:(NSRect)frame {
  if (![super initWithFrame:frame]) {
    return nil;
  }
  
  viewCenter = NSMakePoint(250,250);
  
  CALayer *mainLayer = [CALayer layer];
  mainLayer.bounds = NSRectToCGRect(self.bounds);
	mainLayer.anchorPoint = CGPointZero;
	mainLayer.position = CGPointZero;
	
  // Uncomment to enable CA layer drawing
  //[self setLayer:mainLayer];
  [self setWantsLayer:YES];

  boardLayer = [[CALayer alloc] init];
  boardLayer.bounds = NSRectToCGRect(self.bounds);
	boardLayer.anchorPoint = CGPointZero;
	boardLayer.position = CGPointZero;
	boardLayer.contents = [NSImage imageNamed:@"Board"];
  [mainLayer addSublayer:boardLayer];
  
  CALayer *gridLayer = [CALayer layer];
  gridLayer.bounds = NSRectToCGRect(self.bounds);
	gridLayer.anchorPoint = CGPointZero;
	gridLayer.position = CGPointZero;
  [boardLayer addSublayer:gridLayer];
  
  messageLayer = [[CALayer alloc] init];
  messageLayer.bounds = NSRectToCGRect(self.bounds);
	messageLayer.anchorPoint = CGPointZero;
	messageLayer.position = CGPointZero;
  messageLayer.backgroundColor = CGColorCreateGenericGray(0.0, 0.4);
  messageLayer.opacity = 0.0;
  [mainLayer addSublayer:messageLayer];  
  
  return self;
}

- (void)dealloc
{
  [messageLayer release];
  [boardLayer release];
  [super dealloc];
}


#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)dirtyRect
{
  // Drawing code here.

  // Draw board background
  [[NSImage imageNamed:@"Board"] drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  
  // Draw board grid
  NSString *boardName = [NSString stringWithFormat:@"%@_Mill",game.boardPrefix];
  [[NSImage imageNamed:boardName] drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  
  // Draw stone quarry - Only if the player hasn't placed all tiles yet
  if (![game isGameSetup] && (game.gameState != GameIdle && game.gameState != GameOver)){
    NSPoint center = NSMakePoint(250-57/2,250-57/2);
    [[NSImage imageNamed:@"Quarry"] drawAtPoint:center fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
  }
  
  // Draw valid location indicators
  if ((dragging || mouseDown) && activeTile) {
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
  
  // Draw Selected/Dragged Stone - (draw it here so that its above all other stones when dragged)
  if (activeTile) {
    NSPoint activeTilePos = NSMakePoint(((int)activeTile.pos.x)-HALF_TILE_SIZE, ((int)activeTile.pos.y)-HALF_TILE_SIZE);
    [activeTile.image drawAtPoint:activeTilePos fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
  }
  
  // Draw Messages
  if ([game gameState] == GamePaused || [game gameState] == GameOver) {
    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.4] set];
    NSRectFillUsingOperation([self bounds], NSCompositeSourceOver);
    
    [[NSImage imageNamed:@"Arrow"] drawAtPoint:NSMakePoint(445, 379) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];    
  }
}

- (void)fadeInLayer:(CALayer *)aLayer
{
  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
  anim.duration = 0.8f;
  anim.fromValue = [NSNumber numberWithFloat:0];
  anim.toValue = [NSNumber numberWithFloat:1];
  anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  anim.delegate = self;
  [aLayer addAnimation:anim forKey:@"animateOpacity"];
  [aLayer setOpacity:1.0];
}


#pragma mark -
#pragma mark Animation delegate messages

- (void)animationDidStop:(CABasicAnimation *)theAnimation finished:(BOOL)flag
{

}


#pragma mark -
#pragma mark Mouse delegate messages

- (void)mouseDown:(NSEvent *)theEvent
{
  if (game.gameState == GameIdle || game.gameState == GamePaused || game.gameState == GameOver)
    return;
  
	NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  bool validMove = [game validMove:pointInView player:game.playingPlayer];
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
    
    validDropPositions = [[game allTilePositionsFromPoint:[activeTile oldPos] player:game.playingPlayer] retain];
    
    // Don't drag ghost tiles or other computer tiles
    if ([activeTile type] != [game.playingPlayer tileType] || [game.playingPlayer type] == RobotPlayer) {
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
    if (![game removeTileAtPoint:pointInView player:game.playingPlayer])
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
