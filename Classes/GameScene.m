//
//  GameScene.m
//  StoneMill
//
//  Created by Ben K on 12/01/09.
//  All code is provided under the MIT license.
//

#import "GameScene.h"
#include <math.h>

@implementation GameScene
@synthesize layer;

+ (id)scene
{
	CCScene *scene = [CCScene node];
	GameSceneLayer *layer = [GameSceneLayer node];
	[scene addChild:layer];
  
	return scene;
}

- (id)init
{
	if ((self = [super init])) {
		self.layer = [GameSceneLayer node];
		[self addChild:layer];
	}
	return self;
}

@end


@implementation GameSceneLayer

@synthesize viewCenter, viewFrame;
@synthesize boardLayout, stoneQuarry, messageOverlay;
@synthesize game;


#pragma mark -
#pragma mark Initialization & Cleanup

- (id)init
{  
  if (![super init]) {
    return nil;
  }
  
  self.isKeyboardEnabled = YES;
  self.isMouseEnabled = YES;
  
  viewCenter = NSMakePoint(250,250);
  viewFrame = NSMakeRect(0, 0, 501, 501);
  
  // Draw something
  CCSprite *woodBG = [CCSprite spriteWithFile:@"Background_S.png"];
	woodBG.position = ccp(250.5, 250.5);
	[self addChild:woodBG z:-3];
  
  
  //Board
  CCSprite *board = [CCSprite spriteWithFile:@"Board.png"];
	board.position = ccp(250.5, 250.5);
	[self addChild:board z:-2];
  
  boardLayout = [[CCSprite alloc] initWithFile:@"Regular_Mill.png"];
  boardLayout.position = ccp(250.5, 250.5);
  [self addChild:boardLayout z:-1];
  
  stoneQuarry = [[CCSprite alloc] initWithFile:@"Quarry.png"];
  stoneQuarry.position = ccp(250.5, 250.5);
  [stoneQuarry setVisible:NO];
  [self addChild:stoneQuarry z:-1];
    
  
  messageOverlay = [CCSprite spriteWithFile:@"Background_S.png"];
	messageOverlay.position = ccp(250.5, 250.5);
  [messageOverlay setColor:ccc3(0, 0, 0)];
  [messageOverlay setOpacity:75];
  [messageOverlay setVisible:NO];
	[self addChild:messageOverlay z:256];
  
  CCSprite *arrow = [CCSprite spriteWithFile:@"Arrow.png"];
  arrow.position = ccp(468, 390.5);
  arrow.opacity = 255;
  [messageOverlay addChild:arrow z:256];

  
  [self scheduleUpdateWithPriority:0];
  
  return self;
}

- (void)dealloc
{
  [boardLayout release];
  [stoneQuarry release];
  [messageOverlay release];
	[super dealloc];
}


- (void)update:(ccTime)deltaTime
{

}


- (void)cleanupSprite:(CCSprite* )inSprite
{
  [self removeChild:inSprite cleanup:YES];
}


#pragma mark -
#pragma mark Mouse delegate messages

- (BOOL)ccMouseUp:(NSEvent *)theEvent
{
  CGPoint location = [[CCDirector sharedDirector] convertEventToGL: theEvent];
  NSPoint pointInView = NSPointFromCGPoint(location);
  
  if (game.gameState == GameIdle || game.gameState == GamePaused)
    return NO;
  
  mouseDown = NO;
  
  if ([game.playingPlayer state] == 1) {
    if (![game removeTileAtPoint:pointInView player:game.playingPlayer])
      NSLog(@"Can't remove selected tile!");//[self displayError];
    return NO;
  }
  
  if (!activeTile)
    return NO;
  
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
    [boardLayout removeAllChildrenWithCleanup:YES];
    [validDropPositions release];
    
    // Put it back where it came from
    if (!validDrop)
      [activeTile moveToPos:[activeTile oldPos] animate:YES];
  }
  
  [activeTile setActive:NO];
  [activeTile release];
  activeTile = nil;
  
  dragging = NO;
  
  return YES;
}

- (void)showValidDropPositions
{
  // Draw valid location indicators
  for (NSString *point in validDropPositions) {
    NSPoint zonePos = NSPointFromString(point);
    CCSprite *drop = [CCSprite spriteWithFile:@"Drop Zone.png"];
    drop.position = ccp(zonePos.x+0.5, zonePos.y+0.5);
    [boardLayout addChild:drop z:1];
  }
}

- (BOOL)ccMouseDown:(NSEvent *)theEvent
{
  CGPoint location = [[CCDirector sharedDirector] convertEventToGL: theEvent];
  NSPoint pointInView = NSPointFromCGPoint(location);
  
  if (game.gameState == GameIdle || game.gameState == GamePaused || game.gameState == GameOver)
    return NO;
  
  bool validMove = [game validMove:pointInView player:game.playingPlayer];
  if (!validMove)
    return NO;
  
  if ([game.playingPlayer state] == 1)
    return NO;
  
  mouseDown = YES;
	dragging = NO;
  
  // Find the clicked tile
	activeTile = [[game tileAtPoint:pointInView] retain];
  if (activeTile) {
    [activeTile setOldPos:[activeTile pos]];
    [activeTile setActive:YES];
    
    validDropPositions = [[game allTilePositionsFromPoint:[activeTile oldPos] player:game.playingPlayer] retain];
    [self showValidDropPositions];
    
    // Don't drag ghost tiles or other computer tiles
    if ([activeTile type] != [game.playingPlayer tileType] || [game.playingPlayer type] == RobotPlayer) {
      mouseDown = NO;
      [activeTile setActive:NO];
      [activeTile release];
      activeTile = nil;
    }
  }
  
  return YES;
}

- (BOOL)ccMouseDragged:(NSEvent *)theEvent
{
  CGPoint location = [[CCDirector sharedDirector] convertEventToGL: theEvent];
  NSPoint pointInView = NSPointFromCGPoint(location);
    
  if (game.gameState == GameIdle || game.gameState == GamePaused)
    return NO;
  
  if (!activeTile)
		return NO;
	dragging = YES;
  
  // Don't drag over view bounds
  if (pointInView.y > NSMaxY(viewFrame) - VIEW_PADDING)
		pointInView.y = NSMaxY(viewFrame) - VIEW_PADDING;
  if (pointInView.y < NSMinY(viewFrame) + VIEW_PADDING)
		pointInView.y = NSMinY(viewFrame) + VIEW_PADDING;
	if (pointInView.x < NSMinX(viewFrame) + VIEW_PADDING)
		pointInView.x = NSMinX(viewFrame) + VIEW_PADDING;
	if (pointInView.x > NSMaxX(viewFrame) - VIEW_PADDING)
		pointInView.x = NSMaxX(viewFrame) - VIEW_PADDING;
  
  // Pixel perfection
  pointInView = NSMakePoint((int)pointInView.x, (int)pointInView.y);
  
  // Start dragging the tile
  [activeTile setPos:pointInView];
  
  return YES;
}


@end
