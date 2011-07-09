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
  float boardOpacity;
  
  IBOutlet GameController *game;
}

@property (nonatomic, readonly) NSPoint viewCenter;
@property float boardOpacity;


@end
