//
//  GameView.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import <Cocoa/Cocoa.h>
#import "GameController.h"

#define VIEW_PADDING (50)


@interface GameView : NSView {
  GameTile *activeTile;
  NSDictionary *validDropPositions;
	BOOL dragging;
  BOOL mouseDown;
  
  NSPoint viewCenter;  
  IBOutlet GameController *game;
  
  CALayer *boardLayer;
  CALayer *messageLayer;
}

@property (nonatomic, readonly) NSPoint viewCenter;
@property (nonatomic, retain) CALayer *boardLayer;
@property (nonatomic, retain) CALayer *messageLayer;

- (void)fadeInLayer:(CALayer *)aLayer;

@end
